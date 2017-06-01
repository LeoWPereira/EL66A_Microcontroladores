#include "lcd16x2.h"

#include<reg51.h>							 //including sfr registers for ports of the controller

//LCD Module Connections
sbit BUSYF = P0^7;

sbit RS = P2^5;   
sbit RW = P2^6;
sbit E_LCD = P2^7;

sfr DISPLAY = 0x80;

sbit D0 = P0^0;
sbit D1 = P0^1;
sbit D2 = P0^2;
sbit D3 = P0^3;
sbit D4 = P0^4;
sbit D5 = P0^5;
sbit D6 = P0^6;
sbit D7 = P0^7;
//End LCD Module Connections

void INIDISP(void)
{
	ESCINST(0x38, 0x05);
	
	ESCINST(0x38, 0x01);
	
	ESCINST(0x06, 0x01);
	
	ESCINST(0x0C, 0x01);
	
	ESCINST(0x01, 0x02);
	
	return;
}

void ESCINST(unsigned char instruction, unsigned char time_ms)
{
	RW = 0;
	RS = 0;
	
	E_LCD = 1;
	
	DISPLAY = instruction;
	
	E_LCD = 0;
	
	DISPLAY = 0xFF;
	
	RW = 1;
	E_LCD = 1;
	
	while(BUSYF)
	{
	}
	
	E_LCD = 0;
	
	return;
}

void GOTOXY(unsigned char linha, unsigned char coluna)
{
	unsigned char aux = 0x80;
	
	if(linha == 1)
	{
		aux = 0xC0;
	}
	
	aux |= coluna;
		
	linha = aux;
		
	ESCINST(linha, 1);
	
	return;
}

void CLR1L(void)
{
	unsigned char linha = 0;
	unsigned char coluna = 0;
	unsigned char contador = 16;
	
	GOTOXY(linha, coluna);
	
	while(contador > 0);
	{
		ESCDADO(' ');
		
		contador--;
	}
	
	linha = 0;
	coluna = 0;
	
	GOTOXY(linha, coluna);

	return;
}

void CLR2L(void)
{
	unsigned char linha = 1;
	unsigned char coluna = 0;
	unsigned char contador = 16;
	
	GOTOXY(linha, coluna);
	
	while(contador > 0);
	{
		ESCDADO(' ');
		
		contador--;
	}
	
	linha = 1;
	coluna = 0;
	
	GOTOXY(linha, coluna);
	
	return;
}

void ESCDADO(unsigned char charToWrite)
{
	RW = 0;
	RS = 1;
	E_LCD = 1;
	
	DISPLAY = charToWrite;
	
	E_LCD = 0;
	
	DISPLAY = 0xFF;
	
	RW = 1;
	RS = 0;
	E_LCD = 1;
	
	while(BUSYF)
	{
	}
	
	E_LCD = 0;
	
	return;
}

void MSTRING(unsigned char *stringToWrite, unsigned char tamanho_string)
{
	unsigned char i = 0;
	
	for(i = 0; i < tamanho_string; i++)
	{
		ESCDADO(stringToWrite[i]);
	}
	
	return;
}

void ESC_STR1(unsigned char *stringToWrite, unsigned char tamanho_string)
{
	GOTOXY(0, 0);
	
	MSTRING(stringToWrite, tamanho_string);
	
	return;
}

void ESC_STR2(unsigned char *stringToWrite, unsigned char tamanho_string)
{
	GOTOXY(1, 0);
	
	MSTRING(stringToWrite, tamanho_string);
	
	return;
}

void CUR_ON(void)
{
	return;
}

void CUR_OFF(void)
{
	return;
}

unsigned char CONV_NUMBER_TO_ASCII(unsigned char dataToConvert)
{
	return dataToConvert + 0x30;
}

void ESC_DADO_NUMERO_COMPLETO(unsigned char numero, unsigned char tamanho_digitos)
{
	unsigned char aux = 100;
	unsigned char temp = numero;
	unsigned char i;
		
	temp = numero % aux;
	
	numero /= aux;

	ESCDADO(CONV_NUMBER_TO_ASCII(numero));
		
	aux = 10;
	
	numero = temp;
	temp = numero % aux;
		
	numero /= aux;
	ESCDADO(CONV_NUMBER_TO_ASCII(numero));
	
	numero = temp;
	ESCDADO(CONV_NUMBER_TO_ASCII(numero));
	
	return;
}