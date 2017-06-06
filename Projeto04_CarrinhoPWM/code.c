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
static void PARAR_MOTORES(void);
static void MOTOR_AUMENTAR_VELOCIDADE(unsigned char motor, unsigned char valor);
static void MOTOR_DIMINUIR_VELOCIDADE(unsigned char motor, unsigned char valor);
static void MOTOR_1_INVERTE_SENTIDO(void);
static void MOTOR_2_INVERTE_SENTIDO(void);

static void MOTORES_PONTE_H_INICIAL(
	unsigned char pwm_1_in1,
	unsigned char pwm_1_in2,
	unsigned char pwm_2_in3,
	unsigned char pwm_2_in4
);

// Main Function
int main(void)
{	
	INIDISP();
	
	ESC_STR1("Leonardo Pereira", 16);
	ESC_STR2("  Rodrigo Endo  ", 16);
	
	Delay(5000);
	
	ESC_STR1("F1/F2: Muda Vel.", 16);
	ESC_STR2("ENTER: Init/Para", 16);
	
	Delay(5000);
	
	cct_init();   	       // Make all ports zero

	MOTORES_PONTE_H_INICIAL(0, 1, 0, 1);
	
	InitPWM();              // Start PWM

	PWM_1 = 1;              // Make 50% duty cycle of PWM
	PWM_2 = 1;              // Make 50% duty cycle of PWM
	
	while(1)
	{
		ESC_STR1("Vel. PWM 1: ", 12);
		ESC_DADO_NUMERO_COMPLETO(PWM_1, 3);
		ESCDADO(' ');
		
		ESC_STR2("Vel. PWM 2: ", 12);
		ESC_DADO_NUMERO_COMPLETO(PWM_2, 3);
		ESCDADO(' ');
		
		Delay(350);
		
		VARREDURA_TECLADO();
		
		DECODIFICA_FUNCAO();
	}
	
	return;
}

static void DECODIFICA_FUNCAO()
{
	switch(COMANDO_TECLADO)
	{
		case COMANDO_0: // para motores
			PARAR_MOTORES();
		
			PWM_1_SENTIDO = SENTIDO_FRENTE;
		
			PWM_2_SENTIDO = SENTIDO_FRENTE;
		
			break;
		
		case COMANDO_1:
			MOTOR_AUMENTAR_VELOCIDADE(1, 5);
		
			break;
		
		case COMANDO_2:
			break;
		
		case COMANDO_3:
			MOTOR_AUMENTAR_VELOCIDADE(2, 5);
		
			break;
		
		case COMANDO_4:
			MOTOR_AUMENTAR_VELOCIDADE(1, 5);
		
			MOTOR_AUMENTAR_VELOCIDADE(2, 10);
		
			break;
		
		case COMANDO_5:
			break;
		
		case COMANDO_6:
			MOTOR_AUMENTAR_VELOCIDADE(2, 5);
		
			MOTOR_AUMENTAR_VELOCIDADE(1, 10);
		
			break;
		
		case COMANDO_7:
			MOTOR_DIMINUIR_VELOCIDADE(1, 5);
		
			break;
		
		case COMANDO_8:
			break;
		
		case COMANDO_9:
			MOTOR_DIMINUIR_VELOCIDADE(2, 5);
		
			break;
		
		case COMANDO_F1: // aumenta velocidade linear
			if((PWM_1_SENTIDO == SENTIDO_FRENTE) && (PWM_2_SENTIDO == SENTIDO_FRENTE))
				MOTORES_PONTE_H_INICIAL(1, 0, 1, 0);
			
			else if((PWM_1_SENTIDO == SENTIDO_TRAS) && (PWM_2_SENTIDO == SENTIDO_TRAS))
				MOTORES_PONTE_H_INICIAL(0, 1, 0, 1);
			
			else if((PWM_1_SENTIDO == SENTIDO_TRAS) && (PWM_2_SENTIDO == SENTIDO_FRENTE))
				MOTORES_PONTE_H_INICIAL(0, 1, 1, 0);
			
			else
				MOTORES_PONTE_H_INICIAL(1, 0, 0, 1);
		
			MOTOR_AUMENTAR_VELOCIDADE(1, 5);
			
			MOTOR_AUMENTAR_VELOCIDADE(2, 5);
		
			break;
		
		case COMANDO_F2: // diminui velocidade linear
			if((PWM_1_SENTIDO == SENTIDO_FRENTE) && (PWM_2_SENTIDO == SENTIDO_FRENTE))
				MOTORES_PONTE_H_INICIAL(1, 0, 1, 0);
			
			else if((PWM_1_SENTIDO == SENTIDO_TRAS) && (PWM_2_SENTIDO == SENTIDO_TRAS))
				MOTORES_PONTE_H_INICIAL(0, 1, 0, 1);
			
			else if((PWM_1_SENTIDO == SENTIDO_TRAS) && (PWM_2_SENTIDO == SENTIDO_FRENTE))
				MOTORES_PONTE_H_INICIAL(0, 1, 1, 0);
			
			else
				MOTORES_PONTE_H_INICIAL(1, 0, 0, 1);
			
			MOTOR_DIMINUIR_VELOCIDADE(1, 5);
			
			MOTOR_DIMINUIR_VELOCIDADE(2, 5);
			
			break;
			
		case COMANDO_F3: // para motores e inverte sentidos
			PARAR_MOTORES();
		
			MOTOR_1_INVERTE_SENTIDO();
		
			MOTOR_2_INVERTE_SENTIDO();
		
			break;
		
		case COMANDO_ENT:
			PARAR_MOTORES();
		
			PWM_1_SENTIDO = SENTIDO_TRAS;
		
			PWM_2_SENTIDO = SENTIDO_FRENTE;
		
			break;
		
		case COMANDO_CLR:
			PARAR_MOTORES();
		
			PWM_1_SENTIDO = SENTIDO_FRENTE;
		
			PWM_2_SENTIDO = SENTIDO_TRAS;
		
			break;
		
		default:
			break;
	}
	
	return;
}

static void PARAR_MOTORES(void)
{
	while((PWM_1 > 1) || (PWM_2 > 1))
	{
		MOTOR_DIMINUIR_VELOCIDADE(1, 5);
			
		MOTOR_DIMINUIR_VELOCIDADE(2, 5);
		
		Delay(200);
	}
	
	return;
}

static void MOTOR_AUMENTAR_VELOCIDADE(unsigned char motor, unsigned char valor)
{
	if (motor == 1)
	{
		if(PWM_1 > (255 - valor))
				PWM_1 = 255;
		
		else
			PWM_1 += valor;
	}
	
	else if(motor == 2)
	{
		if(PWM_2 > (255 - valor))
				PWM_2 = 255;
		
		else
			PWM_2 += valor;
	}
	
	return;
}

static void MOTOR_DIMINUIR_VELOCIDADE(unsigned char motor, unsigned char valor)
{
	if (motor == 1)
	{
		if(PWM_1 < valor)
				PWM_1 = 1;
			
		else
			PWM_1 -= valor;
	}
		
	
	else if(motor == 2)
	{
		if(PWM_2 < valor)
				PWM_2 = 1;
			
		else
			PWM_2 -= valor;
	}
	
	return;
}

static void MOTORES_PONTE_H_INICIAL(unsigned char pwm_1_in1, unsigned char pwm_1_in2, unsigned char pwm_2_in3, unsigned char pwm_2_in4)
{
	PWM_1_in1 = pwm_1_in1;
	PWM_1_in2 = pwm_1_in2;
	
	PWM_2_in3 = pwm_2_in3;
	PWM_2_in4 = pwm_2_in4;
	return;
}

static void MOTOR_1_INVERTE_SENTIDO(void)
{
	PWM_1_in1 ^= 1;
	PWM_1_in2 ^= 1;
	
	PWM_1_SENTIDO ^= 1; 
	
	return;
}

static void MOTOR_2_INVERTE_SENTIDO(void)
{
	PWM_2_in3 ^= 1;
	PWM_2_in4 ^= 1;
	
	PWM_2_SENTIDO ^= 1;
	
	return;
}