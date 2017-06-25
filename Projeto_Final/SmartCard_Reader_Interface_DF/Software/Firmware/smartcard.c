/*************************************************************************************
 * SmartCard
 *
 *Dexcel Electronics Designs PVT Ltd
 *
 * - File              : smartcard.c
 *
 * Description		:  . contains the functions for verifying the Actel Smart card IP core.
 *
 * (C) Copyright 2008 Dexcel Electronics Designs PVT Ltd.
 * $Revision: 1.2 $
 * $Date: Tuesday, December 08 2008 
 ************************************************************************************/
 
#include <reg51.h>
#include "header.h"

unsigned char Data_Rcv, Data_Type, Data_Rd=0;
unsigned char Flag_Counter=0;
unsigned char counter=0;
unsigned char Zone_Choice;

void Delay123(void)
{
	unsigned int count=65500, i=0;
	for(i=0;i<3;i++)
	{
		while(count)
		count--;
	}
	count=65500;
}

/**
  * This function reads data from UART
  *
  * @param ch: data needs to be transmitted.
  *
  * @return none	 
  */
void Uart_Tx(unsigned char ch)
{
	 while(!(P3 & 0x01));
	 P0 = ch; 
  	 P3 = 0x00;
	 P3 = 0x01; 
}

/**
  * This function Reads the data from user zone.
  *
  * @param none.
  *
  * @return data_rx: data read from UART	 
  */
unsigned char CheckUART()
{
	unsigned char data_rx;
	 while(!(P2 & 0x01));
	 P2 = 0x00;
	 P2 = 0x01;
	 data_rx=P1; 
	 return data_rx;
}


/**
  * This function writes the data to config zone.
  *
  * @param none.
  *
  * @return none	 
  */
void Write_ConfZone()
{
	int i;
	counter=0;
	
	/*Reset the card*/
    BaseAddress[5] = 1;			/*Reset Register*/
	for(i=0;i<8;i++)			/*Read 8 bytes of  Ack for Answer to Reset*/
	{
		CheckStatus();
	}
	Delay123();


	/*COMMAND TO UNLOCK CONFIG MEMORY*/		
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0xBA;
	CheckStatus(); 
	BaseAddress[2] = 0x07;
	CheckStatus(); 
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0x03;
	CheckStatus();  
		
	/*ACK OF UNLOCK CONFIG MEMORY*/	  
	CheckStatus();
    BaseAddress[2] = 0xB6;
	CheckStatus();	
    BaseAddress[2] = 0xA4;
	CheckStatus();	         
    BaseAddress[2] = 0x05;
    CheckStatus();
    CheckStatus();
    /*Read Ack*/
     CheckStatus();
               
	/* COMMAND TO WRITE 4 BYTE OF CARD MANUFACTURE CODE FROM ADDR 0X0B*/
	
	/*NOTE:
	 * since complete configuraion memory cannt be written, few locations are read only,
	 * hence only 4 bytes are written. 
	 * To write into any other location, pls refer data sheet of the smart card. 
	 * */
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0xB4;
	CheckStatus(); 
	BaseAddress[2] = 0x00;
	CheckStatus(); 
	BaseAddress[2] = 0x0B;
	CheckStatus();
	BaseAddress[2] = 0x04;
	CheckStatus(); 
	CheckStatus();  
	
	/*NOTE:
	 * All the byte location in conf memory is not accessible, so only 4 bytes of data 
	 * is written for verification from addr 0x0B.
	 * */

	 
	if(Flag_Counter)
	{
		for(i=0;i<4;i++)
		{
			BaseAddress[2] = counter++;		//count -> value wrritten into conf memory
	    	CheckStatus();
		}
	}
	else
	{
		for(i=0;i<4;i++)
		{
			BaseAddress[2] = Data_Rd;		//count -> value wrritten into conf memory
	    	CheckStatus();
		
		}
	}
     CheckStatus();
	 CheckStatus();
	 
	 /*Reset the card*/
	BaseAddress[5] = 0;
	Delay123(); 
	
}

/**
  * This function Reads the data from config zone.
  *
  * @param none.
  *
  * @return none	 
  */
void Read_ConfZone()
{
	int i; 
	unsigned char  buff[]="Readng conf data";	/*Data displayed on the hyperterminal*/
	char *p=buff;
	unsigned char ch;
	
	/*Reset the card*/
    BaseAddress[5] = 1;			/*Reset Register*/
	for(i=0;i<8;i++)			/*Read 8 bytes of  Ack for Answer to Reset*/
	{
		CheckStatus();
	}
	Delay123();


	/*COMMAND TO UNLOCK CONFIG MEMORY*/	
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0xBA;
	CheckStatus(); 
	BaseAddress[2] = 0x07;
	CheckStatus(); 
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0x03;
	CheckStatus(); 
	  
	/*ACK OF UNLOCK CONFIG MEMORY*/	 
	CheckStatus();
    BaseAddress[2] = 0xB6;
	CheckStatus();	
    BaseAddress[2] = 0xA4;
	CheckStatus();	         
    BaseAddress[2] = 0x05;
    CheckStatus();

    /*Read Ack*/
    CheckStatus();
    CheckStatus();
		 			
	/* COMMAND TO READ 4 BYTES OF CONFIGURATION MEMORY FROM ADDR 0X0B*/
	BaseAddress[2] = 0x00;
	CheckStatus();
	BaseAddress[2] = 0xB6;
	CheckStatus(); 
	BaseAddress[2] = 0x00;
	CheckStatus(); 
	BaseAddress[2] = 0x0B;
	CheckStatus(); 
	//BaseAddress[2] = 0xF0;
	BaseAddress[2] = 0x04;
	CheckStatus();
	CheckStatus();
	
	/*READ 4 BYTES OF DATA*/
	
	/*NOTE:
	 * Configuration memory block by default contains some data in few locations ,
	 * which is read only, for verification check 1st 4 block of data read is same
	 * as what was written. 
	 * */
	//for(i=0;i<240;i++)
	for(i=0;i<4;i++)
	{
		CheckStatus();
		ch	=  BaseAddress[3] ;
			Uart_Tx(ch);
	}
	
	CheckStatus(); 
    CheckStatus();
    
    /*Reset the card*/
	BaseAddress[5] = 0;
	Delay123(); 
	
	//BaseAddress[6]=0x01;				//Read signal completed for hardware
	// changed for testing
	BaseAddress[7]=0x01;				//Read signal completed for hardware
}

/**
  * This function writes data user zone.
  *
  * @param none.
  *
  * @return none	 
  */

void Write_UserZone()
{
	int i;
	int Zone=0;
	counter=0;

	/*Reset the card*/
	BaseAddress[5] = 1;		/*Reset Register*/
	for(i=0;i<8;i++)		/*Read 8 bytes of  Ack for Answer to Reset*/
	{
		CheckStatus();
	}
	Delay123();
		
		
	/*WRITE DATA TO ALL THE 16 ZONES */
	for(Zone=0;Zone<16;Zone++)
	{
	
	/*COMMAND TO SET USER ZONE MEMORY*/
	    BaseAddress[2] = 0x00;
		CheckStatus();
	 	BaseAddress[2] = 0xB4; 
    	CheckStatus();
	  	BaseAddress[2] = 0x03; 
     	CheckStatus();
     	BaseAddress[2] = Zone;  ///contains Zone number 
	   	CheckStatus();
	    BaseAddress[2] = 0x00;  
	    for(i=0;i<4;i++)
		{
			CheckStatus();
		}
		
	/*COMMAND TO WRITE TO USER ZONE */
	  	BaseAddress[2] = 0x00;
  	 	CheckStatus();
        BaseAddress[2] = 0xB0; 
  		CheckStatus();
        BaseAddress[2] = 0x00; 
        CheckStatus();
        BaseAddress[2] = 0x00; 
  		CheckStatus();
        BaseAddress[2] = 0x10;  
        CheckStatus();
        CheckStatus();				//To read Ack
      
		/*WRITE 16 BYTES OF DATA FROM 1 TO 16*/
		
		/*NOTE:
		* Data written into the user memory is a counter value from 1 to 16
	 	* In order to write a different value , replace count to a data value to be written
	 	* */

		if(Flag_Counter)
		{
			for(i=0;i<16;i++)
			{
				BaseAddress[2]=counter++;	//count -> value wrritten into user memory
				if(counter==0xff)
				counter=0;
				CheckStatus();
			}
		}
		else
		{
			for(i=0;i<16;i++)
			{
				BaseAddress[2] =Data_Rd;	//count -> value wrritten into user memory
				CheckStatus();
			}
		}
		CheckStatus();
	    CheckStatus();
	}
	 /*Reset the card*/
	BaseAddress[5] = 0;
	Delay123();
}

/**
  * This function Reads the data from user zone.
  *
  * @param none.
  *
  * @return none	 
  */
void Read_UserZone()
{
	unsigned short Zone=0;
	int  i;
	unsigned char ch;
	
	/*Reset the card*/
	BaseAddress[5] = 1;		/*Reset Register*/			
	for(i=0;i<8;i++)		/*Read 8 bytes of  Ack for Answer to Reset*/
	{
		CheckStatus();
	}
	Delay123();
	
	/*READ DATA FROM ALL THE 16 ZONES */
	for(Zone=0;Zone<16;Zone++)
	{
		
		/*COMMAND TO SET USER ZONE MEMORY*/
		BaseAddress[2] = 0x00;
		CheckStatus();
	 	BaseAddress[2] = 0xB4; 
		 CheckStatus();
	  	BaseAddress[2] = 0x03; 
	 	CheckStatus();
	 	BaseAddress[2] = Zone;  	//contains Zone number 
	   	CheckStatus();
	    BaseAddress[2] = 0x00;  
	   	for(i=0;i<4;i++)
		{
			CheckStatus();
		}

		/*COMMAND TO READ USER ZONE */
		BaseAddress[2] = 0x00;
		CheckStatus();
		BaseAddress[2] = 0xB2; 
		CheckStatus();
		BaseAddress[2] = 0x03; 
		CheckStatus();
		BaseAddress[2] = 0x00; 
		CheckStatus();
		BaseAddress[2] = 0x10;				//number of bytes to read, each zone is 16 bytes
		CheckStatus();
		CheckStatus();
		
		/*READ 16 BYTES OF DATA & TRANSMIT IT TO SERIAL PORT*/
		for(i=0;i<16;i++)
		{
			CheckStatus();
			ch	=  BaseAddress[3];
			Uart_Tx(ch);
		}
		CheckStatus();
	 	CheckStatus();
	}

	/*Reset the card*/
	BaseAddress[5] = 0;
	Delay123();
	BaseAddress[7]=0x01;				//Read signal completed for hardware
}

void Delay()
{
	unsigned int count=65500, i=0;
	for(i=0;i<5;i++)
	{
		while(count)
		count--;
	}
	count=65500;
	
}

/**
  * This function Initialises the SmartCard by resetting the registers & reading the Ack signal
  *
  * @param None.
  *
  * @return 1 if pass, else return 0.	 
  */

int Init_Card()
{
	unsigned char ch;

	BaseAddress[5]=0x01;				//Reset Register for Init
	BaseAddress[6]=0x00;
	
	Delay123();
	
	CheckStatus();
	ch	=  BaseAddress[3] ;
	if (ch==0x00)
	{
		Uart_Tx(0xFF);
		return 0;
	}

	Uart_Tx(0x01);
	BaseAddress[5]=0x00;				//Reset Register for Init
	Delay123();
	
	return 1;
}

/**
  * This function Reads the status register before performing read / write operation & clears the status bit..
  *
  * @param none.
  *
  * @return none	 
  */
void CheckStatus()
{
	while(!*(BaseAddress_gpio));	 	
	BaseAddress[1] = 0;
}


/***************************************************************
 MAIN ROUTINE 
****************************************************************/
void main (void) 
{
	while(1)
	{
		Flag_Counter=0;
		Zone_Choice=CheckUART();
		if(Zone_Choice==1)
		{
			Data_Type=CheckUART();
			if(Data_Type==1)
			{
				Data_Rd=CheckUART();
			}
			else
			{
				Flag_Counter=1;
			}
			Write_UserZone();
			Uart_Tx(0x0A);
			Read_UserZone();
			Uart_Tx(0x0A);
		}
		else
		if(Zone_Choice==2)
		{
			Data_Type=CheckUART();
			if(Data_Type==1)
			{
				Data_Rd=CheckUART();
			}
			else
			{
				Flag_Counter=1;
			}
			Write_ConfZone();
			Uart_Tx(0x0A);
			Read_ConfZone();
			Uart_Tx(0x0A);
		}
		else
		if(Zone_Choice==3)
		{
			Init_Card();
		}
	}
}

	

