/*  Name     : code.c
 *  Purpose  : Main file for generating pwm using 8051.
 *  Author   : M.Saeed Yasin
 *  Date     : 13-06-12
 *  Revision : None
 */
#include<reg51.h>
#include "lcd16x2.h"
#include "pwm.h"
#include "timer.h"
#include "teclado_matricial_4x4.h"

static void DECODIFICA_FUNCAO(void);

// Main Function
int main(void)
{	
	INIDISP();
	
	ESC_STR1("Leonardo Pereira", 16);
	ESC_STR2("  Rodrigo Endo  ", 16);
	
	Delay(5000);
	
	ESC_STR1("F1/F2: Muda Vel.", 16);
	ESC_STR2("ENTER: Init/Para", 16);
	
	Delay(10000);
	
	cct_init();   	       // Make all ports zero

	InitPWM();              // Start PWM

	PWM_1 = 0;              // Make 50% duty cycle of PWM
	PWM_2 = 0;              // Make 50% duty cycle of PWM
	
	while(1)
	{
		ESC_STR1("Vel. PWM 1: ", 12);
		ESC_DADO_NUMERO_COMPLETO(PWM_1, 3);
		ESCDADO(' ');
		
		ESC_STR2("Vel. PWM 2: ", 12);
		ESC_DADO_NUMERO_COMPLETO(PWM_2, 3);
		ESCDADO(' ');
		
		VARREDURA_TECLADO();
		
		Delay(500);
		
		DECODIFICA_FUNCAO();
	}
	
	return;
}

static void DECODIFICA_FUNCAO()
{
	switch(COMANDO_TECLADO)
	{
		case COMANDO_0:
			break;
		
		case COMANDO_1:
			break;
		
		case COMANDO_2:
			break;
		
		case COMANDO_3:
			break;
		
		case COMANDO_4:
			break;
		
		case COMANDO_5:
			break;
		
		case COMANDO_6:
			break;
		
		case COMANDO_7:
			break;
		
		case COMANDO_8:
			break;
		
		case COMANDO_9:
			break;
		
		case COMANDO_F1:
			if(PWM_1 > 251)
				PWM_1 = 255;
			
			else
				PWM_1 += 5;
			
			if(PWM_2 > 251)
				PWM_2 = 255;
			
			else
				PWM_2 += 5;
		
			break;
		
		case COMANDO_F2:
			if(PWM_1 < 4)
				PWM_1 = 0;
			
			else
				PWM_1 -= 5;
			
			if(PWM_2 < 4)
				PWM_2 = 0;
			
			else
				PWM_2 -= 5;
			
			break;
	}
	
	return;
}