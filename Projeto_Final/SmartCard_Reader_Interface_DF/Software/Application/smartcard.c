/*************************************************************************************
 * Smart_Card
 *
 *Dexcel Electronics Designs PVT Ltd
 *
 * - File              : smartcard.c
 *
 * Description		:  . contains the functions for verifying the Actel Nand Flash IP core.
 *					   . Ask for the Communication Port
 *					   . Ask for the User Zone or config Zone
 *					   . Ask for the Data to be written 
 *					   . Displays the Result
 *					   . Exit from the program
 *
 * (C) Copyright 2008 Dexcel Electronics Designs PVT Ltd.
 * $Revision: 1.3 $
 * $Date: Tuesday, December 08 2008 
 ************************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include<string.h>
#include <windows.h>
#define DATA_LEN_USER	0x100
#define DATA_LEN_CONF	4
unsigned char ComPort[10];

unsigned char User_Data[DATA_LEN_USER];
unsigned long file_cnt;

/*********************************************************************************************
 MAIN ROUTINE 
*********************************************************************************************/
int main()
{
	int USB_HANDLE;
	unsigned char buffer[100],flag_rcv,bank_count=0;
	unsigned char Data,fileflag=1,Flag_Complete=0;//,count;
	int port_choice=0,choice=0,data_choice, zone_choice;
	long int start_addr, end_addr;
	unsigned int ret,i,l,bank_no,j,test;
	unsigned short data_tx,count;
	unsigned char StartAddr1, StartAddr2, StartAddr3,EndAddr1,EndAddr2,EndAddr3;
	unsigned char Data_Rcv;
	unsigned char ch1, ch2,cnt;
	unsigned char data_ch, ch_rcv,atr_rcv;

	FILE *fp1, *fp2;
	printf("\n");
	printf("/***************************************************\\\n");
	printf("|         Dexcel Electronics Designs (P) Ltd        |\n");
	printf("|                                                   |\n");
	printf("|                  Bangalore, India                 |\n");
	printf("|                                                   |\n");
	printf("|           Contact: info@dexceldesigns.com         |\n");
	printf("|           Website: www.dexceldesigns.com          |\n");
	printf("\\***************************************************/\n");
	printf("\n");
	
	printf("Please Enter COM Port Name (e.g: COM1 or COM2 etc)\n");
	scanf("%s",&ComPort);

	USB_HANDLE = OpenUsb(ComPort);
	
	printf(" Insert the SmartCard & press ENTER");
	printf("\n");
	// Unitl the Enter Key is pressed do not proceed further
	while(getch()!=13)
	{
		printf("Please press ENTER Key\n");
	}
	

	while(1)
	{
		test=3;
		UsbSend(USB_HANDLE,&test,1);
		ret=UsbRecv(USB_HANDLE,&atr_rcv,1);
		
		if(atr_rcv==0xFF)
		{
			printf("No response from the Smart Card, Insert the Smart Card correctly and then press ENTER \n");
			printf("\n");
			getch();
		}
		else
		if(atr_rcv=0x01)
		{
			printf("Please Select\n 1 for User Zone Testing \n 2 For Config Zone Testing \n");
			printf("Press Ctrl-C to exit\n");
			printf("\n");
			scanf("%d",&zone_choice);

			test=3;
			UsbSend(USB_HANDLE,&test,1);
			ret=UsbRecv(USB_HANDLE,&atr_rcv,1);
			
			if(atr_rcv==0xFF)
			{
				printf("No response from the Smart Card, Insert the Smart Card correctly and then press ENTER \n");
				printf("\n");
				getch();
			}
			else
			{
				UsbSend(USB_HANDLE,&zone_choice,1);
				if(zone_choice==1)						/*User Zone Operation*/
				{
					fp2=fopen("Write_Data_user.txt","w");
					if(!fp2)
					{
						printf("Error in opening Write file \n");
						return 1;
					}
					fp1=fopen("Read_Data_user.txt","wb");
					if(!fp1)
					{
						printf("File to write read data cannot be opened \n");
						return 1;
					}
					printf("Select \n 1. for fixed data\n 2. for counter data \n");	/*Data type selection*/
					printf("Press Ctrl-C to exit\n");
					scanf("%d", &data_choice);
					printf("\n");
					UsbSend(USB_HANDLE,&data_choice,1);
					if(data_choice==1)										/*Static data*/
					{		
						printf("Select Data between 0x00 to 0xFF to Download \n");
						printf("Press Ctrl-C to exit\n");
						scanf("%x", &data_tx);
						UsbSend(USB_HANDLE,&data_tx,1);
						printf("\n");
						printf("Writing Data please wait ....\n");
						for(i=0;i<(DATA_LEN_USER);i++)
						{
							fwrite(&data_tx,1, 1, fp2);
						}
					}
					else
					{
						count=0;											/*counter data*/
						printf("\n");
						printf("Writing Data please wait ....\n");
						for(i=0;i<(DATA_LEN_USER);i++)
						{
							fwrite(&count,1, 1, fp2);
							count++;
							if(count==0xff)
							count=0;
						}
					}
					ret=UsbRecv(USB_HANDLE,&flag_rcv,1);
					if(flag_rcv==0x0A)
					printf(" WRITE COMPLETED \n");
					printf("\n");
					printf("\n");
					printf(" Reading Data please wait .......................... \n");
					for(i=0;i<(DATA_LEN_USER);i++)
					{
						ret=UsbRecv(USB_HANDLE,&Data_Rcv,1);
						User_Data[i]=Data_Rcv;
					}
					for(i=0;i<(DATA_LEN_USER);i++)
					{
						data_ch=0x00;
						for(j=0;j<8;j++)
						{
							ch_rcv=((User_Data[i] >> j) & 0x01);
							if(ch_rcv)
							data_ch|=(1 << (8-(j+1)));
						}
						fwrite(&data_ch,1, 1, fp1);
					}
					ret=UsbRecv(USB_HANDLE,&flag_rcv,1);
					if(flag_rcv==0x0A)
					printf(" DATA READ COMPLETED \n");
					printf("\n");
					printf("\n");
					fclose(fp1);
					fclose(fp2);
					printf("\n");

					fp1=fopen("Read_Data_user.txt","r");
					if(!fp1)
					{
						printf("File Read_Data cannt be opened \n");
						return 1;
					}
					fp2=fopen("Write_Data_user.txt","r");
					if(!fp2)
					{
						printf("Write Read_Data cannt be opened \n");
						return 1;
					}
					printf("Verification under progress . Please wait ..... \n");
						/*comparing 2 files*/
						while(!feof(fp1))
						{
							ch1 = fgetc(fp1);
							if(ferror(fp1)) 
							{
								printf("Error reading read file.\n");
								exit(1);
							}
							ch2 = fgetc(fp2);
							if(ferror(fp2))
							{
								printf("Error reading write file.\n");
								exit(1);
							}
							if(ch1 != ch2) 
							{
								printf("VERIFICATION COMPLETED \n");
								printf("Files are NOT same \n");
								fileflag=0;
								break;
							}
						}
						if(fileflag)
						{
							printf("VERIFICATION COMPLETED \n");
							printf("Files are same\n");
						}
						printf("\n");
						printf("\n");
						fileflag=1;
						fclose(fp1);
						fclose(fp2);
				}
				
			else
			if(zone_choice==2)
			{
				fp2=fopen("Write_Data_conf.txt","wb");
				if(!fp2)
				{
					printf("Error in opening Write file \n");
					return 1;
				}
				fp1=fopen("Read_Data_conf.txt","wb");
				if(!fp1)
				{
					printf("File to write read data cannot be opened \n");
					return 1;
				}
				printf("Select \n 1. for fixed data\n 2. for counter data \n");
				printf("Press Ctrl-C to exit\n");
				scanf("%d", &data_choice);
				printf("\n");
				UsbSend(USB_HANDLE,&data_choice,1);
				if(data_choice==1)
				{		
					printf("Select Data between 0x00 to 0xFF to Download \n");
					printf("Press Ctrl-C to exit\n");
					scanf("%x", &data_tx);
					UsbSend(USB_HANDLE,&data_tx,1);
					printf("Writing Data please wait ....\n");
					for(i=0;i<(DATA_LEN_CONF);i++)
					{
						fwrite(&data_tx,1, 1, fp2);
					}
				}
				else
				{
					count=0;
					printf("Writing Data please wait ....\n");
					for(i=0;i<(DATA_LEN_CONF);i++)
					{
						fwrite(&count,1, 1, fp2);
						count++;
						if(count==0xff)
						count=0;
					}
				}
				ret=UsbRecv(USB_HANDLE,&flag_rcv,1);
				if(flag_rcv==0x0A)
				printf(" WRITE COMPLETED \n");
				printf("\n");
				printf("\n");
				printf(" Reading Data please wait .......................... \n");
				for(i=0;i<(DATA_LEN_CONF);i++)
				{
					ret=UsbRecv(USB_HANDLE,&Data_Rcv,1);
					User_Data[i]=Data_Rcv;
				}
				for(i=0;i<(DATA_LEN_CONF);i++)
				{
					data_ch=0x00;
					for(j=0;j<8;j++)
					{
						ch_rcv=((User_Data[i] >> j) & 0x01);
						if(ch_rcv)
						data_ch|=(1 << (8-(j+1)));
					}
					fwrite(&data_ch,1, 1, fp1);
				}
				ret=UsbRecv(USB_HANDLE,&flag_rcv,1);
				if(flag_rcv==0x0A)
				printf(" READ COMPLETED  \n");

				printf("\n");
				printf("\n");
				fclose(fp1);
				fclose(fp2);

				fp1=fopen("Read_Data_conf.txt","r");
				if(!fp1)
				{
					printf("File Read_Data cannt be opened \n");
					return 1;
				}
				fp2=fopen("Write_Data_conf.txt","r");
				if(!fp2)
				{
					printf("Write Read_Data cannt be opened \n");
					return 1;
				}
				printf("Verification under progress . Please wait ..... \n");
				while(!feof(fp2))
				{
					ch1 = fgetc(fp1);
					if(ferror(fp1)) 
					{
						printf("Error reading read file.\n");
						exit(1);
					}
					ch2 = fgetc(fp2);
					if(ferror(fp2))
					{
						printf("Error reading write file.\n");
						exit(1);
					}
					if(ch1 != ch2) 
						{
							printf("VERIFICATION COMPLETED \n");
							printf("Files are NOT same \n");
							fileflag=0;
							break;
						}
					}
					if(fileflag)
					{
						printf("VERIFICATION COMPLETED\n ");
						printf("Files are same\n");
					}
					printf("\n");
					printf("\n");
					fileflag=1;
					fclose(fp1);
					fclose(fp2);
				}
			}
		}
	}
}
	


