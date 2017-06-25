--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--           		     Actel Corporation           		                  --
--                             www.actel.com				                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--        VHDL Design :  Smart Card Reader                                    --
--         Design     :  ACTEL Smart Card Reader IP                           --
--         File name  :  dff_async_rst.vhd                                              --
--                                                                            --
--------------------------------------------------------------------------------
-- Description: The is a FF with reset                                                  --
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
use IEEE.std_logic_1164.all;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               E N T I T Y                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

entity dff_async_rst is
port (data, clk, reset : in std_logic;
        q : out std_logic);
end dff_async_rst;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                         A R C H I T E C T U R E                            --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture behav of dff_async_rst is

begin

process (clk, reset) begin
    if (reset = '0') then
        q <= '0';
    elsif (clk'event and clk = '1') then
        q <= data;
    end if;

end process;

end behav;
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--                               END OF FILE                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

