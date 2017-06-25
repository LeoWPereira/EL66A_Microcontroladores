/*************************************************************************************
 * UsbCom
 *
 *Dexcel Electronics Designs PVT Ltd
 *
 * - File              : UsbCom.c
 *
 * Description		:  . contains the functions USB communication.
 *
 * (C) Copyright 2008 Dexcel Electronics Designs PVT Ltd.
 * $Revision: 1.2 $
 * $Date: Tuesday, December 08 2008 
 ************************************************************************************/


#include <windows.h>
#include <fcntl.h>
#include <stdio.h>
#include <limits.h>

DCB newconfig;

/**
  * This function is used to read data over USB port
  *
  * @param FD	File Discriptor
  * @param buf	Pointer to the buffer holding the data to be received
  *
  * @return	none
  */
int UsbRead(int FD, unsigned char *buf)
{
	DWORD bytes;						//Variable Declaration
	char lastError[1024];				//Variable Declaration
	int error;							//Variable Declaration

	if(! ReadFile(FD, buf, 1, &bytes, NULL))
	{
		error = GetLastError();					//Function gets the error message set 
		FormatMessage(
			FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			lastError,
			1024,
			NULL);
		printf("Invalid Device Handle\n");
	}
}
/**
  * This function is used to send data over USB port
  *
  * @param FD	File Discriptor
  * @param buf	Pointer to the buffer holding the data to be transmitted
  *	@param len	Length of the data in the buffer
  *
  * @return	none
  */
int UsbSend(int FD,unsigned char *buf,int len)
{
	DWORD bytes;						//Variable Declaration
	char lastError[1024];				//Variable Declaration
	int error;							//Variable Declaration
	if(!WriteFile(FD,buf,len,&bytes,NULL))		//Write data to the port and does Error handling
	{	
		error = GetLastError();					//Function gets the error message set 
		FormatMessage(
			FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			lastError,
			1024,
			NULL);
		printf("Invalid Device Handle\n");

	}
	
}

/**
  * This function is used to open the USB port
  *
  * @param Port	Name of the port to be opened (Ex. COM1 or COM2)
  *
  * @return	int	Handle of the opened port
  */
int OpenUsb(char * Port)
{
	int BusId;						//Variable Declaration
	char lastError[1024];			//Variable Declaration

	BusId = CreateFile(Port,		//Function opens the Selected Port in Read/Write mode
		GENERIC_READ | GENERIC_WRITE,
		0,
		0,
		OPEN_EXISTING,
		FILE_ATTRIBUTE_NORMAL,
		0);

	if(BusId > 0)										//Error Handling
	{
		GetCommState(BusId,&newconfig);					//Getting current COM settings

		newconfig.DCBlength = sizeof(newconfig);		//Setting new COM settings
		newconfig.BaudRate = 9600;
		newconfig.Parity = NOPARITY;
		newconfig.ByteSize = 8;
		newconfig.StopBits = ONESTOPBIT;


		if(SetCommState(BusId,&newconfig) == 0)			//Set COM settings to Device & Error handling
		{
			printf("%s bus property setting failed\n",Port);

			FormatMessage(
				FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL,
				GetLastError(),
				MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				lastError,
				1024,
				NULL);


			printf("Invalid Device Handle\n");
			getch();
			exit(0);

		}
	}
	else
	{
														//Error Handling
			FormatMessage(								
				FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
				NULL,
				GetLastError(),
				MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
				lastError,
				1024,
				NULL);

			printf("Unable to detect device\n");
			getch();
			exit(0);

	}

	return BusId;
}

/**
  * This function is used to read data over USB port
  *
  * @param FD	File Discriptor
  * @param buf	Pointer to the buffer holding the data to be received
  * @param len	length to be read
  *
  * @return	none
  */
int UsbRecv(int FD,unsigned char *buf,int len)
{
	DWORD bytes;
	char lastError[1024];
	int error;	


	if(!ReadFile(FD,buf,len,&bytes,NULL))
	{
		error = GetLastError();
		FormatMessage(
			FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			GetLastError(),
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			lastError,
			1024,
			NULL);

		
		printf("Invalid Device Handle\n");

	}
	return 0;
		
}


/**
  * This function is used to close the USB port
  *
  * @param FD	Handle of the port to be closed
  *
  * @return	none
  */
void CloseUsb(int FD)
{
	close(FD);				//Function used to close the port
}

void Delay()
{
	int i=50;
	while(i)
		i--;

}

