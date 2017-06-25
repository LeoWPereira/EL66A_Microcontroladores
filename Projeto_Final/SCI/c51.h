/*******************************************************************************/ 
// Author		: B. VASU DEV 
// Group		: BHILAI BLUES 
// Date			: 19th-Sep-2005 
// PRG			: This Header File consist of LCD Functions		 (Tested)				  
/*******************************************************************************/ 
 
 
 
#include<v_reg51.h> 
#include<intrins.h> 
 
// Device Mapping 
#define LCD_Port	P2 
#define LCD_RS		P1_0 
#define LCD_RW		P1_1 
#define LCD_EN		P1_2 
#define LCD_BP		P0_7			// LCD Busy Pin 
 
 
 
 
// Functions Prototype Declaration 
void lprintf(unsigned char *,unsigned char,unsigned char); 
void LCD_Init(); 
void LCD_Cmd(unsigned char); 
void LCD_Data(unsigned char); 
void Delay_10ms(); 
void Delay(int); 
void LCD_Busy(); 
void ClrLCD(); 
 
/*----------------------------------------------*/ 
// To Clear LCD 
/*----------------------------------------------*/ 
 
void ClrLCD() 
{ 
 LCD_Cmd(0x01); 
} 
 
/*----------------------------------------------*/ 
// Displaying String 
/*----------------------------------------------*/ 
// Displaying String 
void lprintf(char *str,unsigned char ln,unsigned char col) 
{ 
 static int li; 
 unsigned char line; 
 
 if(li==0) 
 { 
   li=1; 
   LCD_Init(); 
 } 
  
 switch(ln) 
 { 
  case 1: 
     line = 0x80; 
     break; 
  case 2: 
     line = 0xc0; 
     break; 
  case 3: 
     line = 0x94; 
     break; 
  case 4: 
     line = 0xD4; 
     break; 
 } 
  
 LCD_Cmd(line+col-1); 
 
 while(*str) 
 { 
	LCD_Data(*str); 
	str++; 
 } 
} 
 
 
/*----------------------------------------------*/ 
//LCD Initilization 
void LCD_Init() 
{ 
LCD_Cmd(0x30); 
LCD_Cmd(0x30); 
LCD_Cmd(0x30); 
LCD_Cmd(0x38); 
LCD_Cmd(0x06); 
LCD_Cmd(0x01); 
LCD_Cmd(0x0c); 
} 
/*----------------------------------------------*/ 
// LCD Command Run 
void LCD_Cmd(unsigned char cmd) 
{ 
LCD_Busy(); 
LCD_Port=cmd; 
P1_7=0; 
_nop_(); 
P1_7=1; 
LCD_RS=0; 
LCD_RW=0; 
LCD_EN=1; 
_nop_(); 
_nop_(); 
LCD_EN=0; 
} 
/*----------------------------------------------*/ 
//LCD Data Out Function 
void LCD_Data(unsigned char dt) 
{ 
LCD_Busy(); 
LCD_Port=dt; 
P1_7=0; 
_nop_(); 
P1_7=1; 
LCD_RS=1; 
LCD_RW=0; 
LCD_EN=1; 
_nop_(); 
_nop_(); 
LCD_EN=0; 
} 
 
/*----------------------------------------------*/ 
// LCD BUSY Check Function 
 
void LCD_Busy() 
{ 
/* 
	LCD_Port=0xff; 
	LCD_RS=0; 
	LCD_RW=1; 
	while(1) 
	{ 
	  LCD_EN=0; 
	  _nop_(); 
	  _nop_(); 
	  LCD_EN=1; 
	  if(!LCD_BP) 
       break; 
 
	 } 
 
Delay(1); 
*/ 
 
ui i; 
 
for(i=0; i<1000; i++); 
} 
 
/*/*----------------------------------------------*/ 
// Delay Function 
void Delay(int n) 
{ 
 while(n) 
 { 
  Delay_10ms();   
  n--; 
 } 
} 
 
 
void Delay_10ms() 
{ 
 int i; 
 for(i=0; i<1825; i++); 
} 