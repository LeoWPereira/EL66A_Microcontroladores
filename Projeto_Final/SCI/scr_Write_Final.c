/*******************************************************************************/   
// Author       : B. VASU DEV   
// Group        : BHILAI BLUES   
// Date         : 19th-March-2007   
// PRG          : SMART CARD READER Project Module to Read the Data   
/*******************************************************************************/   
   
   
   
#include <c51.h>   
   
// Function Prototype   
void Sconfig();   
void Send_Char(unsigned char);   
void Send(unsigned char *);   
void Chk_CardIns(void);   
unsigned char Chk_ACK(unsigned char *,unsigned char *);   
void Read(unsigned char ,unsigned char );   
void Write(unsigned char ,unsigned char ,unsigned char *);   
void Conv(unsigned char *,unsigned char);   
void Conv_In(unsigned char *pt);   
   
//----------------------------------------------------------------------   
// Variable Declaration   
unsigned char ccount=0;   
unsigned char echo=0;   
xdata unsigned char Dt[50],PDt[30];   
   
//----------------------------------------------------------------------   
// Main Function Starts from here   
//----------------------------------------------------------------------   
void main()   
{   
   
 Sconfig();   
 ClrLCD();   
 lprintf("Vasu",1,1);   
   
 lprintf("CardNotInsterted",1,1);    
 Chk_CardIns();                     //Check for the Card Insertition   
/*  
 Write(20,5,"UVXMZ");                //Writing 5 characters in 20h    
 lprintf("WritingCompleted",2,1);  
 */   
 Delay(1);   
 Read(20,5);                         //Reading 5 characters from 20h   
 lprintf("ReadingCompleted",2,1);   
    
 while(1);   
}       // Main Ends Here   
   
   
   
/*---------------------------------------------------------------*/   
// Function to Check the Presence of Card   
void Chk_CardIns()   
{   
  do   
 {   
   Send("#01!");   
   while(!echo);   
    echo=0;   
 }while(!Chk_ACK(Dt,"#80"));   
 lprintf("CARD Inserted...",1,1);   
}   
   
   
/*----------------------------------------------------------------*/   
// Function to Read the data from the Card   
void Read(unsigned char ad,unsigned char nb)   
{   
  unsigned char str[5];     
//Check for the Device Type   
do   
{   
 Send("#0203!");   
 while(!echo);   
 echo=0;   
}   
while(!Chk_ACK(Dt,"#83"));   
//lprintf(Dt);   
   
 Send("#10");   
 Conv(str,ad);   
 Send(str);   
 Conv(str,nb);   
 Send(str);   
 Send("!");   
 while(!echo);   
 echo=0;   
 Conv_In(Dt+7);      // Decoding the incoming data   
 ClrLCD();   
 lprintf(PDt,1,1);   // Printing the decoded data   
}   
   
   
   
/*----------------------------------------------------------------*/   
// Function to Write Data into the Card   
void Write(unsigned char ad,unsigned char nd,unsigned char *st)   
{   
  unsigned char str[4];   
    
do   
{   
 Send("#0203!");   
 while(!echo);   
 echo=0;   
}   
while(!Chk_ACK(Dt,"#83"));   
//lprintf(Dt);   
   
 Send("#11");   
 Conv(str,ad);   
 Send(str);   
 Conv(str,nd);   
 Send(str);   
 Send("ffffff");   
   
 while(*st)   
 {   
  Conv(str,*st);   
  Send(str);   
  st++;   
 }   
 Send("!");   
   
 while(!echo);   
 echo=0;   
//lprintf(Dt);   
}   
   
/*----------------------------------------------------------------*/   
// Function for Serial Configuration   
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
   
   
   
//--------------------------------------------------------------------------------   
// Serial Interrupt which receives characters serially and stores them in Dt array   
//---------------------------------------------------------------------------------   
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
    ccount=0;   
   }   
  }     
}   
    
   
/*----------------------------------------------------------------*/   
// Functin to compare two strings   
unsigned char Chk_ACK(unsigned char *str1,unsigned char *str2)   
{    
 unsigned char Flag=1;   
   
  while(*str1 && *str2)   
  {   
   if(*str1!=*str2)   
   {   
    Flag=0;   
    break;   
   }   
   str1++;   
   str2++;   
  }   
 return Flag;   
}   
   
/*----------------------------------------------------------------*/   
// Function to Convert a no. to String   
void Conv(unsigned char *st,unsigned char t)   
{   
 unsigned char r;   
   
 r=t>>4;    
   
 if(r<=9)        // First Digit   
  *st=r+0x30;   
 else   
  *st=r+0x37;   
   
 r=t & 0x0f;   
 st++;   
 if(r<=9)        // Second Digit   
  *st=r+0x30;   
 else   
  *st=r+0x37;   
   
 st++;   
 *st='\0';   
   
// lprintf(st);   
}   
   
/*---------------------------------------------------------------------*/   
// Decoding Functin :To Make a single char from two digit value received    
void Conv_In(unsigned char *pt)   
{   
    uc d0,d1,c=0;   
       
    while(*pt!='!')   
    {   
     if(*pt>0x39)   
        d1=(*pt)-0x37;   
     else   
        d1=(*pt)-0x30;     
   
      pt++;    
      if(*pt>0x39)   
        d0=(*pt)-0x37;   
      else   
        d0=(*pt)-0x30;     
      pt++;   
   
      d1=d1<<4;      
      PDt[c++]=d1+d0;   
    }     
    PDt[c]='\0';   
    Send(PDt);   
}    
/*----------------------------------------------------------------*/           