/*************************************************************************************
 * smartcard
 *
 *Dexcel Electronics Designs PVT Ltd
 *
 * - File              : header.h
 *
 * Description		   : contains Macros & Global variables for smartcard IP core
 *
 * (C) Copyright 2008 Dexcel Electronics Designs PVT Ltd.
 * $Revision: 1.2 $
 * $Date: Tuesday, December 08 2008 
 ************************************************************************************/

#ifndef HEADER_H_
#define HEADER_H_


/*
 * 	Defines Base Address for IP core & LED pins
 */

#define BASEADDRESS			0x0000
#define BASEADDRESS_GPIO	0x0004

unsigned char xdata *BaseAddress = (unsigned char xdata *)BASEADDRESS;
unsigned char xdata *BaseAddress_gpio = (unsigned char xdata *)BASEADDRESS_GPIO;

unsigned char Values[5];
unsigned char Rd_Data;

/*
 * function declaration
 */
void Uart_Tx(unsigned char );
void CheckStatus();
void Delay123();
void Read_UserZone();
void Write_UserZone();
void Read_ConfZone();
void Write_ConfZone();
void putw(unsigned char i);
void putc(unsigned char *buff);
void putT(unsigned char ch);

#endif /*HEADER_H_*/
