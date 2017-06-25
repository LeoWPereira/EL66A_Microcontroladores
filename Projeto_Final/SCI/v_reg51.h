/*-------------------------------------------------------------------------- 
REG51.H 
 
Header file for generic 80C51 and 80C31 microcontroller. 
Copyright (c) 1988-1997 Keil Elektronik GmbH and Keil Software, Inc. 
All rights reserved. 
--------------------------------------------------------------------------*/ 
 
/*  BYTE Register  */ 
sfr P0   = 0x80; 
sfr P1   = 0x90; 
sfr P2   = 0xA0; 
sfr P3   = 0xB0; 
sfr PSW  = 0xD0; 
sfr ACC  = 0xE0; 
sfr B    = 0xF0; 
sfr SP   = 0x81; 
sfr DPL  = 0x82; 
sfr DPH  = 0x83; 
sfr PCON = 0x87; 
sfr TCON = 0x88; 
sfr TMOD = 0x89; 
sfr TL0  = 0x8A; 
sfr TL1  = 0x8B; 
sfr TH0  = 0x8C; 
sfr TH1  = 0x8D; 
sfr IE   = 0xA8; 
sfr IP   = 0xB8; 
sfr SCON = 0x98; 
sfr SBUF = 0x99; 
 
 
/*  BIT Register  */ 
/*  PSW   */ 
sbit CY   = 0xD7; 
sbit AC   = 0xD6; 
sbit F0   = 0xD5; 
sbit RS1  = 0xD4; 
sbit RS0  = 0xD3; 
sbit OV   = 0xD2; 
sbit P    = 0xD0; 
 
/*  TCON  */ 
sbit TF1  = 0x8F; 
sbit TR1  = 0x8E; 
sbit TF0  = 0x8D; 
sbit TR0  = 0x8C; 
sbit IE1  = 0x8B; 
sbit IT1  = 0x8A; 
sbit IE0  = 0x89; 
sbit IT0  = 0x88; 
 
/*  IE   */ 
sbit EA   = 0xAF; 
sbit ES   = 0xAC; 
sbit ET1  = 0xAB; 
sbit EX1  = 0xAA; 
sbit ET0  = 0xA9; 
sbit EX0  = 0xA8; 
 
/*  IP   */  
sbit PS   = 0xBC; 
sbit PT1  = 0xBB; 
sbit PX1  = 0xBA; 
sbit PT0  = 0xB9; 
sbit PX0  = 0xB8; 
 
/*  P3  */ 
sbit RD   = 0xB7; 
sbit WR   = 0xB6; 
sbit T1   = 0xB5; 
sbit T0   = 0xB4; 
sbit INT1 = 0xB3; 
sbit INT0 = 0xB2; 
sbit TXD  = 0xB1; 
sbit RXD  = 0xB0; 
 
/*  SCON  */ 
sbit SM0  = 0x9F; 
sbit SM1  = 0x9E; 
sbit SM2  = 0x9D; 
sbit REN  = 0x9C; 
sbit TB8  = 0x9B; 
sbit RB8  = 0x9A; 
sbit TI   = 0x99; 
sbit RI   = 0x98; 
 
 
sbit P0_1  = 0x80; 
sbit P0_0  = 0x81; 
sbit P0_2  = 0x82; 
sbit P0_3  = 0x83; 
sbit P0_4  = 0x84; 
sbit P0_5  = 0x85; 
sbit P0_6  = 0x86; 
sbit P0_7  = 0x87; 
 
 
 
sbit P1_0  = 0x90; 
sbit P1_1  = 0x91; 
sbit P1_2  = 0x92; 
sbit P1_3  = 0x93; 
sbit P1_4  = 0x94; 
sbit P1_5  = 0x95; 
sbit P1_6  = 0x96; 
sbit P1_7  = 0x97; 
 
 
sbit P2_0  = 0xa0; 
sbit P2_1  = 0xa1; 
sbit P2_2  = 0xa2; 
sbit P2_3  = 0xa3; 
sbit P2_4  = 0xa4; 
sbit P2_5  = 0xa5; 
sbit P2_6  = 0xa6; 
sbit P2_7  = 0xa7; 
 
sbit P3_0  = 0xb0; 
sbit P3_1  = 0xb1; 
sbit P3_2  = 0xb2; 
sbit P3_3  = 0xb3; 
sbit P3_4  = 0xb4; 
sbit P3_5  = 0xb5; 
sbit P3_6  = 0xb6; 
sbit P3_7  = 0xb7; 
 
sbit B_0  = 0xf0; 
sbit B_1  = 0xf1; 
sbit B_2  = 0xf2; 
sbit B_3  = 0xf3; 
sbit B_4  = 0xf4; 
sbit B_5  = 0xf5; 
sbit B_6  = 0xf6; 
sbit B_7  = 0xf7; 
 
 
 
typedef unsigned char uc; 
typedef unsigned int ui; 