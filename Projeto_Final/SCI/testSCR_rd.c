/*******************************************************************************/   
// Author       : B. VASU DEV   
// Group        : BHILAI BLUES   
// Date         : 19th-March-2007   
// PRG          : SMART CARD READER Project Module to Read the Data   
/*******************************************************************************/   
   
   
   
#include <c51.h>   
#include <kb.h>   
   
// Function Prototype   
void Sconfig();   
void Send_Char(unsigned char);   
void Send(unsigned char *);   
void Chk_Card(unsigned char);   
unsigned char Chk_ACK(unsigned char *,unsigned char *);   
void Read(unsigned char ,unsigned char );   
void Write(unsigned char ,unsigned char ,unsigned char *);   
void Read_Data(void);   
void Write_Data(void);   
void Conv(unsigned char *,unsigned char);   
void Conv_In(unsigned char *pt);   
   
//----------------------------------------------------------------------   
// Variable Declaration   
unsigned char ccount=0;   
unsigned char echo=0,Fread=0;   
   
xdata unsigned char SDt[50],PDt[20];   
   
// Macros Defined    
#define RollNoAd    10   
#define NameAd      20   
#define BranchAd    35   
#define PwdAd       50   
   
   
//----------------------------------------------------------------------   
// Main Function Starts from here   
//----------------------------------------------------------------------   
void main()   
{   
     
   
 Sconfig();   
 ClrLCD();   
 lprintf("Vasu",1,1);   
   
 lprintf("CardNotInsterted",1,1);    
 Chk_Card(1);                       //Check for the Card Insertition   
    
 Read(RollNoAd,10);              //Writing 5 characters in 20h     
 lprintf(PDt,2,1);   
 Delay(200);   
 Read(NameAd,15);                //Writing 5 characters in 20h     
 lprintf(PDt,2,1);   
 Delay(200);   
 Read(PwdAd,4);              //Writing 5 characters in 20h     
 lprintf(PDt,2,1);   
 Delay(200);   
      
 while(1);   
}       // Main Ends Here   
   
   
   
/*---------------------------------------------------------------*/   
// Function to Check the Presence of Card   
void Chk_Card(unsigned char st)   
{   
  uc rply[2][5]={"#81","#80"};   
   
  do   
 {   
   Send("#01!");   
   while(!echo);   
    echo=0;   
 }while(!Chk_ACK(SDt,rply[st]));   
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
while(!Chk_ACK(SDt,"#83"));   
//lprintf(Dt);   
   
 Send("#10");   
 Conv(str,ad);   
 Send(str);   
 Conv(str,nb);   
 Send(str);   
 Send("!");   
 while(!echo);   
 echo=0;   
 Conv_In(SDt+7);     // Decoding the incoming data   
// ClrLCD();   
// lprintf(PDt,1,1);     // Printing the decoded data   
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
while(!Chk_ACK(SDt,"#83"));   
//lprintf(Dt);   
   
 Send("#11");   
 Conv(str,ad);   
 Send(str);   
 Conv(str,nd+1);   
 Send(str);   
 Send("ffffff");   
   
 while(*st)   
 {   
  Conv(str,*st);   
  Send(str);   
  st++;   
 }   
 Conv(str,'\0');   
 Send(str);   
 Send("!");   
   
 while(!echo);   
 echo=0;   
//lprintf(SDt);   
}   
   
   
/*----------------------------------------------------------------*/   
void Read_Data(void)   
{   
   unsigned char pwd[10],rep=3;   
      
   Fread=1;   
   
   Read(RollNoAd,10);                  
   ClrLCD();   
   lprintf("Roll No.: ",1,1);   
   lprintf(PDt,2,1);   
   Delay(100);     
   Read(NameAd,15);   
   ClrLCD();   
   lprintf("Name: ",1,1);   
   lprintf(PDt,2,1);   
   Delay(100);   
   Read(BranchAd,15);                  
   ClrLCD();   
   lprintf("Branch: ",1,1);   
   lprintf(PDt,2,1);   
   Delay(100);     
   Read(PwdAd,4);                  
    ClrLCD();   
    lprintf("Enter Password  ",1,1);   
    pwd[0]=Get_Key(0);   
    pwd[1]=Get_Key(0);   
    pwd[2]=Get_Key(0);         
    pwd[3]=Get_Key(0);   
    pwd[4]='\0';   
    if(Chk_ACK(pwd,PDt))   
    {      
      ClrLCD();   
      lprintf("Access Premited ",1,1);   
      lprintf("Thank U         ",2,1);     
    }   
    else   
    {   
      ClrLCD();    
      lprintf("Wrong Pwd       ",1,1);   
      lprintf("Remove Card     ",2,1);     
      Delay(100);   
    }   
}   
/*----------------------------------------------------------------*/   
void Write_Data(void)   
{   
   
   
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
   SDt[ccount++]=ch;   
    if(ch=='!')   
   {   
    echo=1;   
    SDt[ccount]='\0';   
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