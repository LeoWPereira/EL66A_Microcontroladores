--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--           		     Actel Corporation           		                  --
--                             www.actel.com				                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--        VHDL Design :  Smart Card Reader                                    --
--         Design     :  ACTEL Smart Card Reader IP                           --
--         File name  :  top_module_smart_card_reader.vhd                     --
--                                                                            --
--------------------------------------------------------------------------------
-- Description: This design describes one of possible systems for interfacing -- 
-- Smart Card using Smart Card Reader ip. This module is the top level entity --
-- which instantiates Smart Card Reader ip and the 8051 microcontroller system.-
-- 8051 sends command, address, data and controls all the transaction with    --
-- Smart Card through Smart Card Reader.                                      --
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

use IEEE.STD_LOGIC_1164.all; 
use IEEE.STD_LOGIC_arith.all;
use IEEE.STD_LOGIC_unsigned.all;

library proasic3;
use proasic3.all;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               E N T I T Y                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

entity top_module_smart_card_reader is    
    Port ( nreset 	    : in std_logic;
           clk 			: in std_logic;
           card_clk 	: out std_logic;
           card_rst	 	: out std_logic;
           card_io 		: inout std_logic;
           rxd          : in  std_logic;
           txd          : out std_logic;
           TCK          : in  std_logic; 
           TMS          : in  std_logic;
           TDI          : in  std_logic;
           TDO          : out std_logic;
           TRSTB        : in  std_logic
          );

end top_module_smart_card_reader;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                         A R C H I T E C T U R E                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture top_module_smart_card_reader_arch of top_module_smart_card_reader is

component smart_card_reader 
    Port ( nreset 	: in std_logic;
           clk 				: in std_logic;
           WR : in std_logic;
           RD : in std_logic;
           CS : in std_logic;
           addr       : in  std_logic_vector(2 downto 0);
           card_clk 			: out std_logic;
           card_rst	 		: out std_logic;
           card_io 			: inout std_logic;
           data_in          : in  std_logic_vector(7 downto 0);
           data_out         : out std_logic_vector(7 downto 0)
          );
end component;

-------------------------------------------------------
----------8051 component-------------------------------
------------------------------------------------------

component CORE8051
	generic (
	-- set this to 1 to instantiate OCI logic
	USE_OCI			: integer := 1;
	-- set this to 1 to use ProASIC+ UJTAG macro for OCI logic
	USE_UJTAG	: integer := 1;
	-- TRACE_DEPTH
	-- no trace:  Set value to 0
	-- 256 depth: Set value to 8
	TRACE_DEPTH	: integer := 0;
	-- TRIG_NUM
	-- no triggers:  set value to 0
	--  1 trigger:   set value to 1
	--  2 triggers:  set value to 2
	--  4 triggers:  set value to 4  
	TRIG_NUM	: integer := 0;
	-- set this to 1 to make nrsto an output from here
	NRSTOUT			: integer := 1;
	-- set this to 1 to enable flip-flop optimizations (default is 0)
	EN_FF_OPTS		: integer := 0
	);
	port (
    -- Control signal inputs
    nreset       : in  std_logic;  -- Asynch.act.low reset input
    clk          : in  std_logic;  -- Main clock input
    clkcpu       : in  std_logic;  -- CPU Clock input
    clkper       : in  std_logic;  -- Peripheral Clock input
    -- Port inputs
    port0i       : in  std_logic_vector(7 downto 0);
    port1i       : in  std_logic_vector(7 downto 0);
    port2i       : in  std_logic_vector(7 downto 0);
    port3i       : in  std_logic_vector(7 downto 0);
    -- External interrupt/Port alternate signals
    int0         : in  std_logic;  -- External interrupt 0
    int1         : in  std_logic;  -- External interrupt 1
    int0a        : in  std_logic;  -- External interrupt 0a
    int1a        : in  std_logic;  -- External interrupt 1a
    int2         : in  std_logic;  -- External interrupt 2
    int3         : in  std_logic;  -- External interrupt 3
    int4         : in  std_logic;  -- External interrupt 4
    int5         : in  std_logic;  -- External interrupt 5
    int6         : in  std_logic;  -- External interrupt 6 
    int7         : in  std_logic;  -- External interrupt 7
    -- Serial/Port alternate signals
    rxd0i        : in  std_logic;  -- Serial 0 receive data
    -- Timer/Port alternate signals
    t0           : in std_logic;  -- Timer 0 external input
    t1           : in std_logic;  -- Timer 1 external input
    -- Control signal outputs for external logic
    nrsto        : out std_logic;  -- buffered reset driver
    nrsto_nc     : inout std_logic;-- this must be a no-connect at top-level
	-- clock gating signals to control external AND gates
    clkcpu_en    : out std_logic;  -- CPU Clock enable to external gate
    clkper_en    : out std_logic;  -- Peripheral Clock enable to external gate
    -- MOVX Instruction
    movx         : out std_logic;
    -- Port outputs
    port0o       : out std_logic_vector(7 downto 0);
    port1o       : out std_logic_vector(7 downto 0);
    port2o       : out std_logic_vector(7 downto 0);
    port3o       : out std_logic_vector(7 downto 0);
    -- Serial/Port alternate signals
    rxd0o        : out std_logic;  -- Serial 0 receive clock
    txd0         : out std_logic;  -- Serial 0 transmit data
    -- External Memory interface 
    mempsacki    : in  std_logic;
    memacki      : in  std_logic;
    memdatai     : in  std_logic_vector( 7 downto 0);
    mempsacko    : out std_logic;  -- Program store acknowledge
    memdatao     : out std_logic_vector( 7 downto 0);
    memaddr      : out std_logic_vector(15 downto 0);
    mempsrd      : out std_logic;  -- Program store read enable
    memwr        : out std_logic;  -- Memory write enable
    memrd        : out std_logic;  -- Memory read enable
    -- Internal Memory interface (R0-R7,etc.)
    ramdatai     : in  std_logic_vector(7 downto 0);
    ramdatao     : out std_logic_vector(7 downto 0);
    ramaddr      : out std_logic_vector(7 downto 0);
    ramwe        : out std_logic;  -- Data file write enable
    ramoe        : out std_logic;  -- Data file output enable
    -- Special function register interface (external peripherals)
    sfrdatai     : in  std_logic_vector(7 downto 0);
    sfrdatao     : out std_logic_vector(7 downto 0);
    sfraddr      : out std_logic_vector(6 downto 0);
    sfrwe        : out std_logic;  -- SFR write enable
    sfroe        : out std_logic;   -- SFR output enable
    ----------------------------------------------------------------------
    -- On Chip Instrumentation (OCI) related signals
    ----------------------------------------------------------------------
    -- JTAG signals for OCI
    TCK          : in  std_logic; -- this should be tied high if OCI unused
    TMS          : in  std_logic;
    TDI          : in  std_logic;
    TDO          : out std_logic;
    TRSTB        : in  std_logic; -- this should be tied high if OCI unused
    -- Break bus for OCI (connect to bidirectional pad at top-level)
    BreakIn      : in  std_logic; -- this input must be grounded if unused
    BreakOut     : out std_logic;
    -- debugger code memory bank support, if banking not used, ground these
    membank      : in  std_logic_vector(3 downto 0);
    -- Debug mode program storage write signal
    dbgmempswr   : out std_logic;
    -- Trigger output
    TrigOut      : out std_logic;
    -- Auxilliary output
    AuxOut       : out std_logic;
    -- OCI signals for external RAM(s)
    TraceA       : out std_logic_vector(7 downto 0);
    TraceDI      : out std_logic_vector(19 downto 0);
    TraceDO      : in  std_logic_vector(19 downto 0);
    TraceWr      : out std_logic
    );
end component;



----------------------
-- Program Ram8kx8 signals
----------------------
component Ram8kx8  
    port( WD : in std_logic_vector(7 downto 0); RD : out 
        std_logic_vector(7 downto 0);WEN, REN : in std_logic; 
        WADDR : in std_logic_vector(12 downto 0); RADDR : in 
        std_logic_vector(12 downto 0);WCLK, RCLK : in 
        std_logic) ;
end component;

----------------------
-- Data Ram256x8 signals
----------------------
component Ram256x8 
    port( WD : in std_logic_vector(7 downto 0); RD : out 
        std_logic_vector(7 downto 0);WEN, REN : in std_logic; 
        WADDR : in std_logic_vector(7 downto 0); RADDR : in 
        std_logic_vector(7 downto 0);WCLK, RCLK : in 
        std_logic) ;
end component;

constant  ASIZE  : integer := 13;

----------------------
-- internal signals
----------------------

-- Program Memory interface name directions relative to Core8051
signal memdatai		: std_logic_vector(7 downto 0);
signal memaddr		: std_logic_vector(15 downto 0);
signal memdatao : std_logic_vector(7 downto 0); 
signal dbgmempswr : std_logic;

--signal  dbgmempswr_sig : std_logic;

signal mempsrd		: std_logic;  -- Program store read enable

-- Internal Memory interface (R0-R7,etc.) name directions relative to Core8051
signal ramdatai		: std_logic_vector(7 downto 0);
signal ramdatao		: std_logic_vector(7 downto 0);
signal ramaddr		: std_logic_vector(7 downto 0);
signal ramwe	: std_logic;
signal ramoe		: std_logic;

-- misc. signals
signal nclk			: std_logic;
signal clk8051		: std_logic;
signal clk_divider	: std_logic_vector(1 downto 0);


signal zeroes		: std_logic_vector(31 downto 0);
signal ones			: std_logic_vector(31 downto 0);
signal GND_sig		: std_logic;
signal VCC_sig		: std_logic;

--external signals

--signal p0i, p1o     :  std_logic_vector(7 downto 0);
--signal not_reset :  std_logic;

signal ip_data : std_logic_vector(7 downto 0); 
signal mem_data : std_logic_vector(7 downto 0); 


signal    memwr        :  std_logic;  -- Memory write enable
signal    memrd        :  std_logic;  -- Memory read enable

signal    cs_sig        :  std_logic;  -- IP chip enable

--external signals

signal p0i     :  std_logic_vector(7 downto 0);
signal p1i     :  std_logic_vector(7 downto 0);
signal p2i     :  std_logic_vector(7 downto 0);
signal p3i     :  std_logic_vector(7 downto 0);

signal p0o     :  std_logic_vector(7 downto 0);
signal p1o     :  std_logic_vector(7 downto 0);
signal p2o     :  std_logic_vector(7 downto 0);
signal p3o     :  std_logic_vector(7 downto 0);

component CoreUART_cmp
    -- Port list
    port(
        -- Inputs
        BAUD_VAL : in std_logic_vector(7 downto 0);
        BIT8 : in std_logic;
        CLK : in std_logic;
        CSN : in std_logic;
        DATA_IN : in std_logic_vector(7 downto 0);
        ODD_N_EVEN : in std_logic;
        OEN : in std_logic;
        PARITY_EN : in std_logic;
        RESET_N : in std_logic;
        RX : in std_logic;
        WEN : in std_logic;
        -- Outputs
        DATA_OUT : out std_logic_vector(7 downto 0);
        OVERFLOW : out std_logic;
        PARITY_ERR : out std_logic;
        RXRDY : out std_logic;
        TX : out std_logic;
        TXRDY : out std_logic
    );
end component;

signal csn_s, oen_s, wen_s, overflow_f, parityerr_f, rxrdy_f, txrdy_f, rxd_s : std_logic;

signal data_oled, data_uart, data_in_s : std_logic_vector(7 downto 0);

signal oen1_s, oen2_s, wen1_s, wen2_s : std_logic;

signal           dip_sw       : 	STD_LOGIC_VECTOR (7 downto 0);
signal           leds_out     : 	STD_LOGIC_VECTOR (7 downto 0);

begin


smart_card_reader_inst: smart_card_reader 
  Port map ( 
           nreset   => nreset,	
           clk      => clk,	
--           clk      => clk8051,	 
           WR       => memwr,
           RD       => memrd,
           CS       => cs_sig,
           addr     => memaddr(2 downto 0) ,    
           card_clk => card_clk,
           card_rst => card_rst,
           card_io  => card_io,
           data_in  => memdatao, 
           data_out => ip_data
          );

--cs_sig <= memwr or memrd;
cs_sig <= '1';

-------------------------------------------------------
-----------8051 instantiation--------------------------
-------------------------------------------------------

process(clk, memrd, ip_data, mem_data)
begin
      if rising_edge (clk) then
         if (memrd = '1') then
              memdatai <= ip_data;
         else
              memdatai <= mem_data;
         end if;
      end if;
end process;

--------------------------------
-- initialize signals
--------------------------------
	GND_sig		<= '0';
	VCC_sig		<= '1';
	zeroes		<= (others => '0');
	ones		<= (others => '1');

    p0i <=  dip_sw;

-----------------------------------------------------
-- instantiate Core8051 macro
-- (unused inputs connected to static values, unused
-- outputs left unconnected)
-----------------------------------------------------

process(clk, nreset)
begin
     if nreset = '0' then
        clk_divider <= (others => '0');
     elsif clk'event and clk = '1' then
        clk_divider <= clk_divider + 1 ;
     end if;
end process;

clk8051 <= clk_divider(1) ;
nclk<=not(clk_divider(1));

	CORE8051_inst : CORE8051
    generic map (
        USE_OCI                 => 1,
        USE_UJTAG               => 1,
        TRACE_DEPTH             => 0, 
        TRIG_NUM                => 0, 
        NRSTOUT                 => 1,
        EN_FF_OPTS              => 0

    )
	port map (
		nreset		=> nreset,
		nrsto		=> open,
		nrsto_nc	=> open,

		clk			=> clk8051,
		clkcpu		=> clk8051,
		clkper		=> clk8051,

		clkcpu_en	=> open,
		clkper_en	=> open,

		port0i		=> p0i,
		port1i		=> p1i,
		port2i		=> p2i,
		port3i		=> p3i,

		port0o		=> p0o,
		port1o		=> p1o,
		port2o		=> p2o,
		port3o		=> p3o,

		int0		=> GND_sig,
		int1		=> GND_sig,
		int0a		=> GND_sig,
		int1a		=> GND_sig,
		int2		=> GND_sig,
		int3		=> GND_sig,
		int4		=> GND_sig,
		int5		=> GND_sig,
		int6		=> GND_sig,
		int7		=> GND_sig,

		t0			=> GND_sig,
		t1			=> GND_sig,

		movx		=> open,
		rxd0o		=> open,
		txd0		=> open,
		rxd0i		=> GND_sig,

          -- code/ xdata memory
		dbgmempswr	=> dbgmempswr ,  

		mempsacki	=> VCC_sig,
		memacki		=> VCC_sig,
		memdatai	=> memdatai,
		mempsacko	=> open,
		memdatao	=> memdatao ,  
		memaddr		=> memaddr,
		mempsrd		=> mempsrd,
		memwr		=> memwr,
		memrd		=> memrd,
  
    -- data memory       
		ramdatai	=> ramdatai,
		ramdatao	=> ramdatao,
		ramaddr		=> ramaddr,
		ramwe		=> ramwe,
		ramoe		=> ramoe,

   -- sfr export bus
		sfrdatai	=> zeroes(7 downto 0),
		sfrdatao	=> open,
		sfraddr		=> open,
		sfrwe		=> open,
		sfroe		=> open,

   -- JTAG interface for OCI
		TCK			=> TCK,
		TMS			=> TMS,
		TDI			=> TDI,
		TDO			=> TDO,
		TRSTB		=> TRSTB,

		BreakIn		=> GND_sig,
		BreakOut	=> open,
		membank		=> zeroes(3 downto 0),

		TrigOut		=> open,
		AuxOut		=> open,
		TraceA		=> open,
		TraceDI		=> open,
		TraceDO		=> zeroes(19 downto 0),
		TraceWr		=> open

	);

----------------------
-- Program Ram8kx8 inst
----------------------
Ram8kx8_inst: Ram8kx8  
    port map
    (  
      WD     => memdatao,
      RD     => mem_data,
      WEN    => dbgmempswr, 
      REN   => mempsrd,
      WADDR  => memaddr(ASIZE-1 downto 0),
      RADDR  => memaddr(ASIZE-1 downto 0),
      WCLK   => clk8051, 
      RCLK   => nclk 
     ) ;
----------------------
-- Data Ram256x8 inst
----------------------
Ram256x8_inst: Ram256x8 
    port map
    ( 
      WD    => ramdatao,
      RD    => ramdatai,
      WEN   => ramwe, 
      REN   => ramoe,
      WADDR => ramaddr,
      RADDR => ramaddr,
      WCLK  => clk8051, 
      RCLK  => nclk 
     ) ;

----------------------------------
-- UART inst
----------------------------------

--clk_24m <= clk_divider(0) ;

process (nreset, clk) 
begin
        if (nreset = '0') then
            csn_s <= '1';
        elsif rising_edge (clk) then
            csn_s <= '0';
        end if;
end process ;

process (nreset, clk, rxd) 
begin
        if (nreset = '0') then
            rxd_s <= '1';
        elsif rising_edge (clk) then
            rxd_s <= rxd;
        end if;
end process ;


CoreUART_cmp_inst: CoreUART_cmp 
    port map(
        -- Inputs
        BAUD_VAL   => x"4E", --x"81",
        BIT8       => '1',
        CLK        => clk8051,
        CSN        => csn_s,
        DATA_IN    => data_in_s,
        ODD_N_EVEN => '0',
        OEN        => oen_s,
        PARITY_EN  => '0',
        RESET_N    => nreset,
        RX         => rxd_s,
        WEN        => wen_s,
        -- Outputs
        DATA_OUT   => data_uart,
        OVERFLOW   => overflow_f,
        PARITY_ERR => parityerr_f,
        RXRDY      => rxrdy_f,
        TX         => txd,
        TXRDY      => txrdy_f
    );


process (nreset, clk, oen_s, data_uart)
begin
    if (nreset = '0') then
        data_oled   <= (others => '0');
    elsif (clk'event and clk = '0') then
      if (oen_s = '0') then
        data_oled   <= data_uart ;
      end if;
    end if;
end process ;

process (nreset, clk8051)
begin
    if (nreset = '0') then
       oen1_s <= '1' ;
       oen2_s <= '1' ;
    elsif (clk8051'event and clk8051 = '0') then
       oen1_s <= p2o(0) ;
       oen2_s <= oen1_s ;
    end if;
end process ;

oen_s <= '0' when (oen1_s = '0' and oen2_s = '1') else '1' ;

process (nreset, clk8051)
begin
    if (nreset = '0') then
       wen1_s <= '1' ;
       wen2_s <= '1' ;
    elsif (clk8051'event and clk8051 = '0') then
       wen1_s <= p3o(0) ;
       wen2_s <= wen1_s ;
    end if;
end process ;

wen_s <= '0' when (wen1_s = '0' and wen2_s = '1') else '1' ;

p1i <= data_oled ;

p2i(0) <= rxrdy_f ;

p2i(7 downto 1) <= "0000000" ;

p3i(0) <= txrdy_f ;

p3i(7 downto 1) <= "0000000" ;

data_in_s <= p0o;

    leds_out <= p1o ;

end top_module_smart_card_reader_arch;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               END OF FILE                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------



