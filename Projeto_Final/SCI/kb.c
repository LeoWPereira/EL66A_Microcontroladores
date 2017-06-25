/*******************************************************************************/   
// Author       : B. VASU DEV   
// Group        : MIC BLUES   
// Date         : 19th-Sep-2005   
// PRG          : This Header File consist of LCD Functions      (Tested)                   
/*******************************************************************************/   
   
#include <c51.h>   
   
   
// Device Mapping   
#define KB_Data  P3_2   
   
   
// Variable Declaration   
unsigned char dt=0;   
unsigned char dtbk=0;   
unsigned char cb=0;   
unsigned char ByteC=0;   
   
// Function Prototype   
void Disp_SCode();   
unsigned rorc(unsigned char );   
   
void main()   
{   
 lprintf("VasuRaj",1,1);   
 // Power On Initilizations    
 P3_0=1;    // +5 volts to 5 th Pin of the KB   
 P3_1=0;    // 0 Volts to 2nd Pin   
 KB_Data=1; // Configuring as Input   
 P3_3=1;    // Configuring as Input   
   
 EA=1;      // Enable the Interrupt 1 in Edge Trigerring Mode   
 EX1=1;   
 IT1=1;   
   
    
   
 while(1);   
}   
   
   
KB_Int() interrupt 2 using 1   
{   
//  unsigned char kbit;   
    cb++;   
       
    if(cb==10)   
    {    
     dt=0x1d;   
     Disp_SCode();   
    }   
    else   
     if(cb==11)   
     {   
      cb=0;   
      ByteC++;   
     }   
     else   
     {   
      CY=KB_Data;   
      dt=rorc(dt);   
     }   
}   
   
   
   
   
   
   
   
void Disp_SCode()       // Hex to ASCII Conversion   
{   
  unsigned char t;   
   
  t=dt;   
  t=t>>4;     // To Display 10th place Digit   
  t=t&0x0f;   
  if(t<10)   
    t+=0x30;   
  else    
    t+=0x37;   
   
  LCD_Data(t);   
     
  t=dt;       // To Display the lower digit    
  t=t&0x0f;   
  if(t<10)   
    t+=0x30;   
  else    
    t+=0x37;   
  LCD_Data(t);   
}   
   
unsigned rorc(unsigned char ad)   
{   
unsigned char tmp,cr=0,bk;   
bk=ad;                  // Backup of the number   
   
cr=CY;                  // Previous Carry is added after rotating Right    
ad=_iror_(ad,1);   
ad=ad&0x7f;   
if(cr)   
 ad=ad|0x80;   
   
tmp=bk&0x01;        // This is to Set the Carry Mannually Because irol don't Changes the Carry Flag   
   
if(tmp==0x01)   
  {   
   CY=1;   
   cr=1;   
  }   
  else    
   CY=0;   
   
   
return ad;   
}   