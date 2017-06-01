#include "teclado_matricial_4x4.h"
#include<reg51.h>							 //including sfr registers for ports of the controller

sfr DISPLAY = 0x90;

sbit COL1 = P1^0;
sbit COL2 = P1^1;
sbit COL3 = P1^2;
sbit COL4 = P1^3;

sbit LIN1 = P1^4;
sbit LIN2 = P1^5;
sbit LIN3 = P1^6;
sbit LIN4 = P1^7;

unsigned char COMANDO_TECLADO = 0;

void VARREDURA_TECLADO(void)
{
	while(1)
	{
		LIN1 = 0;
		LIN2 = 1;
		LIN3 = 1;
		LIN4 = 1;
		
		if(COL1 == 0) // digito f1
		{
			COMANDO_TECLADO = COMANDO_F1;
			
			return;
		}
		
		else if(COL2 == 0) // digito 1
		{
			COMANDO_TECLADO = COMANDO_1;
			
			return;
		}
		
		else if(COL3 == 0)  // digito 2
		{
			COMANDO_TECLADO = COMANDO_2;
			
			return;
		}
		
		else if(COL4 == 0) // digito 3
		{
			COMANDO_TECLADO = COMANDO_3;
			
			return;
		}
		
		LIN2 = 0;
		LIN1 = 1;
		
		if(COL1 == 0) // digito f2
		{
			COMANDO_TECLADO = COMANDO_F2;
			
			return;
		}
		
		else if(COL2 == 0) // digito 4
		{
			COMANDO_TECLADO = COMANDO_4;
			
			return;
		}
		
		else if(COL3 == 0) // digito 5
		{
			COMANDO_TECLADO = COMANDO_5;
			
			return;
		}
		
		else if(COL4 == 0) // digito 6
		{
			COMANDO_TECLADO = COMANDO_6;
			
			return;
		}
		
		LIN3 = 0;
		LIN2 = 1;
		
		if(COL1 == 0) // digito f3
		{
			COMANDO_TECLADO = COMANDO_F3;
			
			return;
		}
		
		else if(COL2 == 0) // digito 7
		{
			COMANDO_TECLADO = COMANDO_7;
			
			return;
		}
		
		else if(COL3 == 0) // digito 8
		{
			COMANDO_TECLADO = COMANDO_8;
			
			return;
		}
		
		else if(COL4 == 0) // digito 9
		{
			COMANDO_TECLADO = COMANDO_9;
			
			return;
		}
		
		LIN4 = 0;
		LIN3 = 1;
		
		if(COL1 == 0) // digito f4
		{
			COMANDO_TECLADO = COMANDO_F4;
			
			return;
		}
		
		else if(COL2 == 0) // digito CLR
		{
			COMANDO_TECLADO = COMANDO_CLR;
			
			return;
		}
		
		else if(COL3 == 0) // digito 0
		{
			COMANDO_TECLADO = COMANDO_0;
			
			return;
		}
		
		else if(COL4 == 0) // digito ENT
		{
			COMANDO_TECLADO = COMANDO_ENT;
			
			return;
		}
	}
	
	return;
}