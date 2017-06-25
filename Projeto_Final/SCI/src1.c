#include <c51.h>   
   
// Function Prototype   
void Sconfig();   
void Send_Char(unsigned char);   
void Send(unsigned char *);   
   
   
//----------------------------------------------------------------------   
// Variable Declaration   
unsigned char ccount=0;   
unsigned char echo=0;   
unsigned char Dt[50];   
   
//----------------------------------------------------------------------   
// Main Function Starts from here   
//----------------------------------------------------------------------   
void main()   
{   
    
Sconfig();   
   
 lprintf("om sai1",1,1);   
   
    
 Send("#01!");   
    
   
 while(1)   
 {   
  if(echo)   
  {   
   lprintf(Dt,1,1);   
   echo=0;   
   ccount=0;   
  }   
 }   
   
 while(1);   
}   
   
   
   
   
void Sconfig()   
{   
  TMOD=0x20;   
  TH1=0xfd;   
  TL1=0xfd;   
  SCON=0x50;   
  TR1=1;   
   
  EA=1;   
  ES=1;   
}   
   
   
//----------------------------------------------------------------------   
// Fanction Sends a single character    
//----------------------------------------------------------------------   
void Send_Char(unsigned char dt)   
{   
 SBUF=dt;   
 while(!TI);   
 TI=0;   
}   
   
   
   
//----------------------------------------------------------------------   
// Fanction Sends string serially    
//----------------------------------------------------------------------   
void Send(unsigned char *str)   
{   
 while(*str)   
 {   
  Send_Char(*str);   
  str++;   
 }   
}   
   
   
   
//----------------------------------------------------------------------   
// Fanction Sends string serially    
//----------------------------------------------------------------------   
void Serial_INT(void) interrupt 4 using 2   
{   
  unsigned char ch;   
   
  if(RI)   
  {   
   ch=SBUF;   
   RI=0;   
   Dt[ccount++]=ch;   
   
   if(ch=='!')   
   {   
    echo=1;   
    Dt[ccount]='\0';   
   }   
  }     
}   