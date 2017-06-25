--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--           		     Actel Corporation           		                  --
--                             www.actel.com				                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--        VHDL Design :  Smart Card Reader                                    --
--         Design     :  ACTEL Smart Card Reader IP                           --
--         File name  :  smart_card_reader.vhd                                --
--                                                                            --
--------------------------------------------------------------------------------
-- Description: The data and commands to be written into Smart Card comes from--
-- the microcontroller at data_in port. The address arrived at the inputs of  --
-- Smart Card Reader (i.e, this module) in coded form to access different     --
-- register inside Smart Card Reader IP. The Smart Card Reader IP receives    --
-- data, acknowledgment and status bytes from Smart card and stores in the    --
-- internal register, which can be read by microcontroller from data_out port --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Modification History                                                       --
--                                                                            --
-- Initial revision                                                           --
--                                                                            --
-- Revision 1.0                                                               --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--IMPORTANT-READ THESE TERMS CAREFULLY BEFORE UTILIZING THE INFORMATION       --
--CONTAINED IN THIS DESIGN.  						      --
--YOU ARE HEREBY LICENSED TO USE THE DESIGN FILES AND DOCUMENTATION UNDER THE --
--FOLLOWING TERMS AND CONDITIONS:					      --
--USE									      --
--YOU MAY COPY AND USE THE DESIGN FILES AND DOCUMENTATION ONLY IN CONNECTION  --
--WITH ACTEL PRODUCTS, PURCHASED FROM ACTEL OR ITS AUTHORIZED DISTRIBUTORS.   --  
--NO SUPPORT/NO WARRANTY.  						      --
--THE DESIGN FILES AND DOCUMENTATION ARE PROVIDED WITHOUT SUPPORT OR WARRANTY --
--OF ANY KIND.  ACTEL IS NOT OBLIGATED TO PROVIDE UPDATES, BUG FIXES, OR      --
--TECHNICAL SUPPORT AND DISCLAIMS ALL WARRANTIES INCLUDING, WITHOUT	      --
--LIMITATION, THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR     --
--PURPOSE, AND WARRANTIES OF NON-INFRINGEMENT OF THE RIGHTS OF THIRD PARTIES  --
--(INCLUDING, WITHOUT LIMITATION, RIGHTS UNDER PATENT, COPYRIGHT, TRADE	      --
--SECRET, OR OTHER INTELLECTUAL PROPERTY RIGHTS). RECIPIENT ACCEPTS THE	      --
--DESIGN FILES AND DOCUMENTATION IN "AS-IS" CONDITION. 			      --
--EXPORT								      --
--YOU AGREE THAT YOU WILL NOT EXPORT THE DESIGN FILES OR DOCUMENTATION IN     --
--VIOLATION OF ANY UNITED STATES EXPORT CONTROL LAW OR THE EXPROT CONTROL LAW --
--OF ANY OTHER RELEVANT JURISDICTION.					      --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               L I B R A R Y                                --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL; 
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               E N T I T Y                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

entity smart_card_reader is
    Port ( 
           -- Asynch.active low reset input
           nreset 	  : in    std_logic;
           -- System clock input
           clk        : in    std_logic;
           -- Write enable signal
           WR         : in    std_logic;
           -- Read enable signal
           RD         : in    std_logic;
           -- Chip enable signal
           CS : in std_logic;
           -- Address signal for selecting IP register
           addr       : in    std_logic_vector(2 downto 0);
           -- Smart Card clock signal
           card_clk   : out   std_logic;
           -- Smart Card reset signal
           card_rst	  : out   std_logic;
           -- Smart Card IO bus
           card_io 	  : inout std_logic;
           -- 8-bit data from 8051 microcontroller
           data_in    : in    std_logic_vector(7 downto 0);
           -- 8-bit data to 8051 microcontroller
           data_out   : out   std_logic_vector(7 downto 0)

          );
end smart_card_reader;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                         A R C H I T E C T U R E                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture smart_card_reader_arch of smart_card_reader is
----------------------------------------------------------------------------
-- STATE MACHINE SIGNAL DECLARATION:
type StateType is (IDLE, Init, ClkEnable, WaitForData, ReadData, ProcessData, WriteCommand);
signal CurrentState, NextState : StateType;
----------------------------------------------------------------------------

signal io_rw				: std_logic;
signal clk_en				: std_logic;
signal counter_enable	: std_logic;
signal counter				: std_logic_vector(8 downto 0);
signal Bitcounter			: std_logic_vector(3 downto 0);
signal Bitcounter_clk	: std_logic;
signal Bytecounter		: std_logic_vector(7 downto 0);
signal Bytecounter_clk	: std_logic;
signal data					: std_logic_vector(9 downto 0);
signal data_mux			: std_logic_vector(9 downto 0);

component pll_48_1 
    port(POWERDOWN, CLKA : in std_logic;  LOCK, GLA, GLB : out 
        std_logic) ;
end component;


component dff_async_rst is
port (data, clk, reset : in std_logic;
q : out std_logic);
end component;

component dff is
port (data, clk : in std_logic;
q : out std_logic);
end component;



signal LOCKc				: std_logic;
signal clock				: std_logic;

signal data_uc_o         : std_logic_vector(7 downto 0);
signal tx_rx_done_sig    : std_logic_vector(7 downto 0);
signal tx_rx_done_1sig   : std_logic_vector(7 downto 0);
signal data_uc_i         : std_logic_vector(7 downto 0);

signal card_rst_sig     : std_logic;
signal parity_even      : std_logic;
signal clr_tx_rx        : std_logic;
signal write_2en        : std_logic;
signal write_1en        : std_logic;
signal write_en_sig     : std_logic;
signal rst_reg          : std_logic;
signal write_en         : std_logic;
signal rst_write        : std_logic;
signal wr_ip_sig         : std_logic;
signal rd_ip_sig        : std_logic; 

signal clk12mhz,q_sig        : std_logic;

signal init_start,init_start_sig,n_init_start : std_logic;
signal wr_complete,wr_complete_sig,n_wr_complete_sig,wr_sig : std_logic;
signal rd_complete,rd_complete_sig,n_rd_complete_sig,rd_sig : std_logic;
signal cmd_reg         : std_logic_vector(7 downto 0);

begin

pll_48_1_inst : pll_48_1
      port map(
            CLKA      => clk,
            POWERDOWN => '1',
            LOCK      => LOCKc,
            GLA       => clock,
            GLB       => clk12mhz 
            );

inst1_d_FF : dff_async_rst
    port map(
            clk => init_start,
            data   => '1',
            reset  => n_init_start,
            q      => q_sig
            );

inst2_d_FF : dff
    port map(
            data   => q_sig,
            clk    => clock,
            q      => init_start_sig
            );

n_init_start <= not init_start_sig;
n_rd_complete_sig <= not rd_complete_sig;


inst3_d_FF : dff_async_rst
    port map(
            clk => rd_complete,
            data   => '1',
            reset  => n_rd_complete_sig,
            q      => rd_sig
            );

inst4_d_FF : dff
    port map(
            data   => rd_sig,
            clk    => clock,
            q      => rd_complete_sig
            );

init_start <= (addr(2) and addr(1) and (not addr(0)) and WR);
rd_complete <= (addr(2) and addr(1) and (addr(0)) and WR);

----------------------------------------------------------------------------
COMB: process(CurrentState, write_en_sig, Card_io, Bitcounter,addr,init_start_sig,rd_complete_sig)
begin
	case CurrentState is
		when IDLE =>
            if (init_start_sig = '1') then
				NextState <= Init;
            else
                NextState <= IDLE;
            end if;
                  
		when Init =>
			NextState <= ClkEnable;

		when ClkEnable =>
			    NextState <= WaitForData;

		when WaitForData =>
			if(Card_io = '0') then
				NextState <= ReadData;
			elsif (write_en_sig = '1') then
				Nextstate <= Processdata;
            elsif (rd_complete_sig = '1') then
				Nextstate <= IDLE;
            else
				Nextstate <= WaitForData;
			end if;

		when ReadData =>
			if (Bitcounter = 11)then 		
                NextState <= WaitForData;
			else
				NextState <= ReadData;	
			end if;

		when Processdata =>
				NextState <= WriteCommand;

		when WriteCommand =>
			if (Bitcounter = 11) then
                NextState <= WaitForData;
			else
				NextState <= WriteCommand;
			end if;

        when others =>
            NextState <= IDLE;            
	end case;
end process COMB;

----------------------------------------------------------------------------
SEQ: process(clock,nreset)
begin
	if(nreset = '0') then
		CurrentState <= Idle;
	elsif (clock'event and clock = '1') then
		CurrentState <= NextState;
	end if;
end process SEQ;

----------------------------------------------------------------------------

with CurrentState select
	rst_write <= '1' when Processdata,
			 		'0' when others;

with CurrentState select
	card_rst_sig <= '0' when IDLE,
			 		'0' when Init,
					'0' when ClkEnable,
			 		rst_reg when others;

with CurrentState select
	clk_en   <= '0' when IDLE,
			 		'0' when Init,
			 		'1' when others;


with CurrentState select	
	io_rw	  <=  '0' when WriteCommand,
					'1' when others;

with CurrentState select	
	counter_enable	  <=  '1' when ReadData,
								'1' when WriteCommand,
								'0' when others;

----------------------------------------------------------------------------
--  9-bit counter, elementary time unit etu = 372 / f
----------------------------------------------------------------------------
process(counter_enable, clock)
begin
	if(counter_enable = '0') then
		counter <= (others=>'0');
	elsif (clock'event and clock = '1') then
		if (counter = 371) then
			counter <= (others=>'0');
		else 
			counter <= counter + 1;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
--  4-bit Bitcounter, counting bits in a character frame
----------------------------------------------------------------------------
Bitcounter_clk <= '1' when (counter = 371) else '0';
process(counter_enable, Bitcounter_clk)
begin
	if(counter_enable = '0') then
		Bitcounter <= (others=>'0');
	elsif (Bitcounter_clk'event and Bitcounter_clk = '1') then
		if (Bitcounter = 11) then
			Bitcounter <= (others=>'0');
		else 
			Bitcounter <= Bitcounter + 1;
		end if;
	end if;
end process;

----------------------------------------------------------------------------
--  8-bit Bytecounter, counting bytes in a command/response
----------------------------------------------------------------------------
Bytecounter_clk <= '1' when (Bitcounter = 11) else '0';
process(nreset, Bytecounter_clk)
begin
	if(nreset = '0') then
		Bytecounter <= (others=>'0');
	elsif (Bytecounter_clk'event and Bytecounter_clk = '1') then
		Bytecounter <= Bytecounter + 1;
	end if;
end process;

----------------------------------------------------------------------------
--  9 bit shifter
----------------------------------------------------------------------------
process(counter_enable, clock)
begin										  	
	if(counter_enable = '0')  then
		data <= (others=>'0');
	elsif (clock'event and clock = '1') then
		if ((counter = 186) and (io_rw = '1')) then	
			data <= data(8 downto 0) & Card_io;
		elsif ((bitcounter = 0) and (counter = 0) and (io_rw = '0')) then	 
			data <= data_mux;
		elsif ((counter = 371) and (io_rw = '0')) then
			data(9 downto 0) <= '1' & data(9 downto 1);
		else
			data <= data;
		end if;
	end if;
end process;


----------------------------------------------------------------------------
--  COMBINATORIAL SIGNALS
----------------------------------------------------------------------------
wr_ip_sig <= WR and CS ; 
rd_ip_sig <= RD and CS ;

parity_even <= (data_uc_o(0) xor data_uc_o(1) xor data_uc_o(2) xor data_uc_o(3) xor data_uc_o(4) xor data_uc_o(5) xor data_uc_o(6) xor data_uc_o(7)) ; 

data_mux(8 downto 1) <= data_uc_o ;
data_mux(0) <= '0' ;
data_mux(9) <= parity_even ;

process(clock,nreset)
begin
	if(nreset = '0') then
		write_1en <= '0';
		write_2en <= '0';
	elsif (clock'event and clock = '1') then
		write_1en <= write_en;
		write_2en <= write_1en;
	end if;
end process ;

write_en_sig <= '1' when (write_1en = '1' and write_2en = '0') else '0' ;

process(clk,nreset)
begin
	if(nreset = '0'  or clr_tx_rx = '1') then
		tx_rx_done_1sig <= (others=>'0');
	elsif (clk'event and clk = '1') then
      if(Bitcounter = 10 and counter = 370) then
		tx_rx_done_1sig <= x"01";
      end if;
	end if;
end process;

process(clk,nreset)
begin
	if(nreset = '0') then
		data_uc_i <= (others=>'0');
	elsif (clk'event and clk = '1') then
      if (Bitcounter = 9 and io_rw = '1' and counter = 188) then
		data_uc_i <= data(8 downto 1);
      end if;
   	end if;
end process ;

process(clock,nreset, clr_tx_rx)
begin
	if(nreset = '0' or clr_tx_rx = '1') then
		tx_rx_done_sig <= (others=>'0');
	elsif (clock'event and clock = '1') then
		tx_rx_done_sig <= tx_rx_done_1sig;
	end if;
end process ;

----------------------------------------------------------------------------
-- Reading, writing ip registers --
----------------------------------------------------------------------------

process(nreset, clk )
begin
      if ( nreset = '0' )then
        clr_tx_rx <= '0' ;
      elsif rising_edge (clk) then
         if (addr = 1 and wr_ip_sig = '1') then
              clr_tx_rx <= '1' ;
         else
              clr_tx_rx <= '0' ;
         end if;
      end if;
end process;

process(nreset, clk )
begin
      if ( nreset = '0' )then
        data_uc_o <=  (others => '0') ;
      elsif rising_edge (clk) then
         if (addr = 2 and wr_ip_sig = '1') then
              data_uc_o <= data_in;
         end if;
      end if;
end process;

process(nreset, clk )
begin
      if ( nreset = '0' or rst_write = '1' )then
        write_en  <= '0' ;
      elsif rising_edge (clk) then
         if (addr = 2 and wr_ip_sig = '1') then
           write_en  <= '1' ;
         end if;
      end if;
end process;

process(nreset, clk )
begin
      if ( nreset = '0' )then
        rst_reg   <=   '0' ;
      elsif rising_edge (clk) then
         if (addr = 5 and wr_ip_sig = '1') then
           rst_reg <= data_in(0); 
         end if;
      end if;
end process;

process(nreset, clk)
begin
      if ( nreset = '0' )then
        data_out  <=  (others => '0') ;
      elsif rising_edge (clk) then
         if (addr = 4 and rd_ip_sig = '1') then
            data_out <= tx_rx_done_sig  ;
         elsif (addr = 3 and rd_ip_sig = '1') then
            data_out <= data_uc_i ;
         end if;
      end if;
end process;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--   smart_card_reader output signals                                         --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

Card_clk <= clock and clk_en;
Card_io <= data(0) when (io_rw = '0') else 'Z';
card_rst <= card_rst_sig ;

end smart_card_reader_arch;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               END OF FILE                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------