//////////////////////////////////////
//									//
//  PROJETO PADRAO PARA USO GERAL 	//
//									//
// @author: Leonardo Winter Pereira //
// @author: Rodrigo Yudi Endo		//
//									//
//////////////////////////////////////

$NOMOD51
#include <at89c5131.h>
#include "lcd16x2.a51"
#include "timer.a51"
#include "display_7_segmentos.a51"
#include "teclado_matricial_4x4.a51"
#include "motor_de_passos.a51"
#include "pwm_com_timer.a51"

ORG 0000h // Origem do codigo 
LJMP __STARTUP__

ORG 0003h // Inicio do codigo da interrupcao externa INT0
LJMP INT_INT0

ORG 000Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
LJMP INT_TIMER0

ORG 0013h // Inicio do codigo da interrupcao externa INT1
LJMP INT_INT1

ORG 001Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
LJMP INT_TIMER1

ORG 0023h // Inicio do codigo da interrupcao SERIAL
LJMP INT_SERIAL

__STARTUP__:
		MOV		R0, #001h // quantidade de periodos
		MOV		R1, #128d // duty cycle (50%)
		
		// Considerando 20 ciclos de maquina para a interrupcao (20 x 0.375 us = 7.5 us)
		// 2666666 (0x28B0AA) estados em 32 MHz para frequencia de 1 Hz
		// 0x29 * 0xFF * 0xFF =~ 1Hz 
		MOV		R2, #029h
		MOV		R3, #0FFh
		MOV		R4, #0FFh
		MOV		R5, #00000101b // ativa o led amarelo, sinalizando que a lombada esta funcionando
		
		LCALL	PWM_SQUARE_WAVE_SETUP_AND_START

		JMP 	__STARTUP__

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

/*
*
*/
INT_INT0:
		RETI

/*
*
*/
INT_TIMER0:
		RETI
	
/*
*
*/
INT_INT1:
		RETI

/*
*
*/
INT_TIMER1:
		RETI
	
/*
*
*/
INT_SERIAL:
		RETI
	
		END