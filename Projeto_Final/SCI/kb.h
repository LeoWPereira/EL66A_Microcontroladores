/******************************************************************************************/ 
// Author		: B. VASU DEV 
// Group		: MIC BLUES 
// Date			: 15-02-06 
// PRG			: This Header File consist of AT-Keyboard Functions	 (Finally Tested )				  
/*******************************************************************************************/ 
/* 
NOTE: 
	1. Please Check the Keyboard connection again and again.... 
    2. Data Pin is connected to P3.4 and  clk is connected to P3_3. 
*/ 
 
 
 
//---------------------------------------------------------------------------------------------------- 
// Including of Header Files 
//#include <c51.h> 
 
 
//---------------------------------------------------------------------------------------------------- 
// Device Mapping  
#define KB_DATA  P3_4 
 
 
//---------------------------------------------------------------------------------------------------- 
//Global Variable Declaration 
xdata unsigned char dt _at_ 00; 
unsigned char kbit; 
unsigned char ByteC=0; 
xdata unsigned char mbit _at_ 20; 
unsigned char bcount=0; 
unsigned char fkey=0; 
unsigned char fCaps=0; 
unsigned char dtbak;	 
 
 
//---------------------------------------------------------------------------------------------------- 
// Functions Prototype Declaration 
void Disp_Hex(unsigned char ); 
unsigned char Get_Char(unsigned char ); 
unsigned char Get_Key(unsigned char); 
void GetStr(unsigned char *); 
 
 
 
//---------------------------------------------------------------------------------------------------- 
// Interrupt Subroutine connected to Keyboard Clock Pin 
//---------------------------------------------------------------------------------------------------- 
Ex_Int1() interrupt 2 using 1 
{ 
     bcount++;  
	 if(bcount>=2 && bcount<=9)		// Push  the Data Bits in to the dt variable 
	 { 
	  kbit = KB_DATA; 
	  dt = dt | (mbit * kbit); 
  	  mbit=mbit<<1; 
	 } 
	 else 
	  if(bcount==33)				// When Last Bit received from the Keyboard 
	  { 
		if(dt==0x58)		// Checking for Shift Key 
		{  
		 fCaps=~fCaps; 
		} 
		else 
		{ 
         fkey=1; 
		} 
		mbit=1; 
		bcount=0; 
	  } 
} 
//---------------------------------------------------------------------------------------------------- 
 
 
	   
/*  
// This is the Main Program  
void main() 
{ 
 unsigned char st[20]; 
 lprintf("Enter Ur name: "); 
 GetStr(st); 
 LCD_Cmd(0xc0); 
 lprintf(st); 
  
 while(1); 
} 						// Here Our Main Programm Ends 
 
*/ 
 
 
 
/************************************   Functions ***********************************************/ 
 
//---------------------------------------------------------------------------------------------------- 
// Function to Read a String From AT-Keyboard 
//---------------------------------------------------------------------------------------------------- 
void GetStr(unsigned char *p) 
{ 
 unsigned char ct;  
 
 while(1) 
 { 
   ct=Get_Key(1);  
   if(ct==0x0d) 
     break; 
   *p=ct; 
    p++; 
 }		// Reads the Characters untill Enter is Pressed 
  *p='\0';							// Add the Null character at the end of the String 
 
// EA=0;								// Disable the Serial Interrupts 
// EX1=0; 
// IT1=0; 
} 
 
 
 
//---------------------------------------------------------------------------------------------------- 
// This function displays and returns the char pressed on keyboard 
//---------------------------------------------------------------------------------------------------- 
unsigned char Get_Key(unsigned char echo) 
{ 
 unsigned char c; 
 
 // Enabling the Ketboard Interrups  
 dt=0; 
 mbit = 1; 
 EA=1; 
 EX1=1; 
 IT1=1; 
  
 
 while(1) 
 {  
 	if(fkey) 
   { 
    // Disp_Hex(dt);		// To Display the Scan Code while Testing the KB 
	 c=Get_Char(dt); 
	 if(echo) 
	  LCD_Data(c); 
	 dtbak=dt; 
	 dt=0; 
	 fkey=0; 
	 break; 
   } 
 } 
 return  c; 
} 
 
 
//---------------------------------------------------------------------------------------------------- 
// This function Display the Hex Scancode recived from the AT-Keyboard 
//---------------------------------------------------------------------------------------------------- 
/* 
void Disp_Hex(unsigned char ch) 
{ 
 unsigned char fd; 
 
 fd = ch & 0xf0; 
 fd = fd>>4; 
  
 if(fd<10) 
  fd+=0x30; 
 else 
  fd+=0x37; 
 LCD_Data(fd); 
 
 
 fd= ch & 0x0f; 
 if(fd<10) 
  fd+=0x30; 
 else 
  fd+=0x37; 
 LCD_Data(fd); 
} 
*/ 
 
//---------------------------------------------------------------------------------------------------- 
// This function takes the Scancode and returns the Character mapped on the Keyboard 
//---------------------------------------------------------------------------------------------------- 
unsigned char Get_Char(unsigned char dt ) 
{ 
xdata unsigned char scode1[]={ 
	     //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f    
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','~',' ',    
          ' ',' ',' ',' ',' ','Q','1',' ',' ',' ','Z','S','A','W','2',' ',   
          ' ','C','X','D','E','4','3',' ',' ',' ','V','F','T','R','5',' ',    
          ' ','N','B','H','G','Y','6',' ',' ',' ','M','J','U','7','8',' ',   
          ' ','<','K','I','O','0','9',' ',' ','>','?','L',':','P','_',' ',   
          ' ',' ','"',' ','[','+',' ',' ',' ',' ',0x0d,']',' ','/',' ',' ',   
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',0x1b,' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
}; 
 
xdata unsigned char scode2[]={ 
	     //0   1   2   3   4   5   6   7   8   9   a   b   c   d   e   f    
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ','~',' ',    
          ' ',' ',' ',' ',' ','q','1',' ',' ',' ','z','s','a','w','2',' ',   
          ' ','c','x','d','e','4','3',' ',' ',' ','v','f','t','r','5',' ',    
          ' ','n','b','h','g','y','6',' ',' ',' ','m','j','u','7','8',' ',   
          ' ','<','k','i','o','0','9',' ',' ','>','?','l',':','p','_',' ',   
          ' ',' ','"',' ','[','+',' ',' ',' ',' ',0x0D,']',' ','/',' ',' ',   
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ', 
          ' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',  
}; 
 
if(fCaps) 
 return scode1[dt]; 
else 
 return scode2[dt]; 
} 
//---------------------------------------------------------------------------------------------------- 