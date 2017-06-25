-- Version: 8.3 8.3.0.22

library ieee;
use ieee.std_logic_1164.all;
library igloo;
use igloo.all;

entity Ram8kx8 is 
    port( WD : in std_logic_vector(7 downto 0); RD : out 
        std_logic_vector(7 downto 0);WEN, REN : in std_logic; 
        WADDR : in std_logic_vector(12 downto 0); RADDR : in 
        std_logic_vector(12 downto 0);WCLK, RCLK : in std_logic
        ) ;
end Ram8kx8;


architecture DEF_ARCH of  Ram8kx8 is

    component BUFF
        port(A : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component OR2
        port(A, B : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component MX2
        port(A, B, S : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component INV
        port(A : in std_logic := 'U'; Y : out std_logic) ;
    end component;

    component RAM4K9
    generic (MEMORYFILE:string := "");

        port(ADDRA11, ADDRA10, ADDRA9, ADDRA8, ADDRA7, ADDRA6, 
        ADDRA5, ADDRA4, ADDRA3, ADDRA2, ADDRA1, ADDRA0, ADDRB11, 
        ADDRB10, ADDRB9, ADDRB8, ADDRB7, ADDRB6, ADDRB5, ADDRB4, 
        ADDRB3, ADDRB2, ADDRB1, ADDRB0, DINA8, DINA7, DINA6, 
        DINA5, DINA4, DINA3, DINA2, DINA1, DINA0, DINB8, DINB7, 
        DINB6, DINB5, DINB4, DINB3, DINB2, DINB1, DINB0, WIDTHA0, 
        WIDTHA1, WIDTHB0, WIDTHB1, PIPEA, PIPEB, WMODEA, WMODEB, 
        BLKA, BLKB, WENA, WENB, CLKA, CLKB, RESET : in std_logic := 
        'U'; DOUTA8, DOUTA7, DOUTA6, DOUTA5, DOUTA4, DOUTA3, 
        DOUTA2, DOUTA1, DOUTA0, DOUTB8, DOUTB7, DOUTB6, DOUTB5, 
        DOUTB4, DOUTB3, DOUTB2, DOUTB1, DOUTB0 : out std_logic) ;
    end component;

    component DFN1
        port(D, CLK : in std_logic := 'U'; Q : out std_logic) ;
    end component;

    component VCC
        port( Y : out std_logic);
    end component;

    component GND
        port( Y : out std_logic);
    end component;

    signal WEAP, WEBP, ADDRA_FF2_0_net, ADDRB_FF2_0_net, 
        ENABLE_ADDRA_0_net, ENABLE_ADDRA_1_net, 
        ENABLE_ADDRB_0_net, ENABLE_ADDRB_1_net, BLKA_EN_0_net, 
        BLKB_EN_0_net, BLKA_EN_1_net, BLKB_EN_1_net, 
        QX_TEMPR0_0_net, QX_TEMPR1_0_net, QX_TEMPR0_1_net, 
        QX_TEMPR1_1_net, QX_TEMPR0_2_net, QX_TEMPR1_2_net, 
        QX_TEMPR0_3_net, QX_TEMPR1_3_net, QX_TEMPR0_4_net, 
        QX_TEMPR1_4_net, QX_TEMPR0_5_net, QX_TEMPR1_5_net, 
        QX_TEMPR0_6_net, QX_TEMPR1_6_net, QX_TEMPR0_7_net, 
        QX_TEMPR1_7_net, VCC_1_net, GND_1_net : std_logic ;
    begin   

    VCC_2_net : VCC port map(Y => VCC_1_net);
    GND_2_net : GND port map(Y => GND_1_net);
    BUFF_ENABLE_ADDRB_0_inst : BUFF
      port map(A => RADDR(12), Y => ENABLE_ADDRB_0_net);
    ORB_GATE_0_inst : OR2
      port map(A => ENABLE_ADDRB_0_net, B => WEBP, Y => 
        BLKB_EN_0_net);
    ORA_GATE_0_inst : OR2
      port map(A => ENABLE_ADDRA_0_net, B => WEAP, Y => 
        BLKA_EN_0_net);
    MX2_RD_4_inst : MX2
      port map(A => QX_TEMPR0_4_net, B => QX_TEMPR1_4_net, S => 
        ADDRB_FF2_0_net, Y => RD(4));
    INV_ENABLE_ADDRB_1_inst : INV
      port map(A => RADDR(12), Y => ENABLE_ADDRB_1_net);
    MX2_RD_6_inst : MX2
      port map(A => QX_TEMPR0_6_net, B => QX_TEMPR1_6_net, S => 
        ADDRB_FF2_0_net, Y => RD(6));
    MX2_RD_3_inst : MX2
      port map(A => QX_TEMPR0_3_net, B => QX_TEMPR1_3_net, S => 
        ADDRB_FF2_0_net, Y => RD(3));
    Ram8kx8_R1C5 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(5), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_5_net);
    BFF1_0_inst : DFN1
      port map(D => RADDR(12), CLK => RCLK, Q => ADDRB_FF2_0_net);
    BUFF_ENABLE_ADDRA_0_inst : BUFF
      port map(A => WADDR(12), Y => ENABLE_ADDRA_0_net);
    MX2_RD_5_inst : MX2
      port map(A => QX_TEMPR0_5_net, B => QX_TEMPR1_5_net, S => 
        ADDRB_FF2_0_net, Y => RD(5));
    MX2_RD_2_inst : MX2
      port map(A => QX_TEMPR0_2_net, B => QX_TEMPR1_2_net, S => 
        ADDRB_FF2_0_net, Y => RD(2));
    Ram8kx8_R1C2 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(2), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_2_net);
    INV_ENABLE_ADDRA_1_inst : INV
      port map(A => WADDR(12), Y => ENABLE_ADDRA_1_net);
    MX2_RD_1_inst : MX2
      port map(A => QX_TEMPR0_1_net, B => QX_TEMPR1_1_net, S => 
        ADDRB_FF2_0_net, Y => RD(1));
    Ram8kx8_R1C1 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(1), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_1_net);
    Ram8kx8_R0C6 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(6), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_6_net);
    Ram8kx8_R0C0 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(0), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_0_net);
    WEBUBBLEB : INV
      port map(A => REN, Y => WEBP);
    Ram8kx8_R1C4 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(4), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_4_net);
    MX2_RD_7_inst : MX2
      port map(A => QX_TEMPR0_7_net, B => QX_TEMPR1_7_net, S => 
        ADDRB_FF2_0_net, Y => RD(7));
    Ram8kx8_R0C3 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(3), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_3_net);
    ORB_GATE_1_inst : OR2
      port map(A => ENABLE_ADDRB_1_net, B => WEBP, Y => 
        BLKB_EN_1_net);
    ORA_GATE_1_inst : OR2
      port map(A => ENABLE_ADDRA_1_net, B => WEAP, Y => 
        BLKA_EN_1_net);
    Ram8kx8_R0C7 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(7), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_7_net);
    Ram8kx8_R1C6 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(6), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_6_net);
    Ram8kx8_R0C2 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(2), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_2_net);
    MX2_RD_0_inst : MX2
      port map(A => QX_TEMPR0_0_net, B => QX_TEMPR1_0_net, S => 
        ADDRB_FF2_0_net, Y => RD(0));
    AFF1_0_inst : DFN1
      port map(D => WADDR(12), CLK => WCLK, Q => ADDRA_FF2_0_net);
    Ram8kx8_R0C5 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(5), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_5_net);
    Ram8kx8_R0C4 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(4), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_4_net);
    Ram8kx8_R1C7 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(7), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_7_net);
    WEBUBBLEA : INV
      port map(A => WEN, Y => WEAP);
    Ram8kx8_R0C1 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(1), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_0_net, BLKB => BLKB_EN_0_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR0_1_net);
    Ram8kx8_R1C3 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(3), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_3_net);
    Ram8kx8_R1C0 : RAM4K9
      port map(ADDRA11 => WADDR(11), ADDRA10 => WADDR(10), 
        ADDRA9 => WADDR(9), ADDRA8 => WADDR(8), ADDRA7 => 
        WADDR(7), ADDRA6 => WADDR(6), ADDRA5 => WADDR(5), 
        ADDRA4 => WADDR(4), ADDRA3 => WADDR(3), ADDRA2 => 
        WADDR(2), ADDRA1 => WADDR(1), ADDRA0 => WADDR(0), 
        ADDRB11 => RADDR(11), ADDRB10 => RADDR(10), ADDRB9 => 
        RADDR(9), ADDRB8 => RADDR(8), ADDRB7 => RADDR(7), 
        ADDRB6 => RADDR(6), ADDRB5 => RADDR(5), ADDRB4 => 
        RADDR(4), ADDRB3 => RADDR(3), ADDRB2 => RADDR(2), 
        ADDRB1 => RADDR(1), ADDRB0 => RADDR(0), DINA8 => 
        GND_1_net, DINA7 => GND_1_net, DINA6 => GND_1_net, 
        DINA5 => GND_1_net, DINA4 => GND_1_net, DINA3 => 
        GND_1_net, DINA2 => GND_1_net, DINA1 => GND_1_net, 
        DINA0 => WD(0), DINB8 => GND_1_net, DINB7 => GND_1_net, 
        DINB6 => GND_1_net, DINB5 => GND_1_net, DINB4 => 
        GND_1_net, DINB3 => GND_1_net, DINB2 => GND_1_net, 
        DINB1 => GND_1_net, DINB0 => GND_1_net, WIDTHA0 => 
        GND_1_net, WIDTHA1 => GND_1_net, WIDTHB0 => GND_1_net, 
        WIDTHB1 => GND_1_net, PIPEA => GND_1_net, PIPEB => 
        GND_1_net, WMODEA => GND_1_net, WMODEB => GND_1_net, 
        BLKA => BLKA_EN_1_net, BLKB => BLKB_EN_1_net, WENA => 
        GND_1_net, WENB => VCC_1_net, CLKA => WCLK, CLKB => RCLK, 
        RESET => VCC_1_net, DOUTA8 => OPEN , DOUTA7 => OPEN , 
        DOUTA6 => OPEN , DOUTA5 => OPEN , DOUTA4 => OPEN , 
        DOUTA3 => OPEN , DOUTA2 => OPEN , DOUTA1 => OPEN , 
        DOUTA0 => OPEN , DOUTB8 => OPEN , DOUTB7 => OPEN , 
        DOUTB6 => OPEN , DOUTB5 => OPEN , DOUTB4 => OPEN , 
        DOUTB3 => OPEN , DOUTB2 => OPEN , DOUTB1 => OPEN , 
        DOUTB0 => QX_TEMPR1_0_net);
end DEF_ARCH;

-- _Disclaimer: Please leave the following comments in the file, they are for internal purposes only._


-- _GEN_File_Contents_

-- Version:8.3.0.22
-- ACTGENU_CALL:1
-- BATCH:T
-- FAM:IGLOO
-- OUTFORMAT:VHDL
-- LPMTYPE:LPM_RAM
-- LPM_HINT:TWO
-- INSERT_PAD:NO
-- INSERT_IOREG:NO
-- GEN_BHV_VHDL_VAL:F
-- GEN_BHV_VERILOG_VAL:F
-- MGNTIMER:F
-- MGNCMPL:T
-- "DESDIR:E:/OLD_HD_BACKUP/01_Actel/03_Smart_Card/vhdl_proj/Final_8051/Igloo/with_uart/program_mem_8k/smart_card_reader/smartgen\Ram8kx8"
-- GEN_BEHV_MODULE:T
-- SMARTGEN_DIE:M1IS6X6M2LPLV
-- SMARTGEN_PACKAGE:fg484
-- WWIDTH:8
-- WDEPTH:8192
-- RWIDTH:8
-- RDEPTH:8192
-- CLKS:2
-- RESET_POLARITY:2
-- INIT_RAM:F
-- DEFAULT_WORD:0x00
-- WCLK_EDGE:RISE
-- RCLK_EDGE:RISE
-- WCLOCK_PN:WCLK
-- RCLOCK_PN:RCLK
-- PMODE2:0
-- DATA_IN_PN:WD
-- WADDRESS_PN:WADDR
-- WE_PN:WEN
-- DATA_OUT_PN:RD
-- RADDRESS_PN:RADDR
-- RE_PN:REN
-- WE_POLARITY:1
-- RE_POLARITY:1
-- PTYPE:1

-- _End_Comments_

