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
#include "display_7_segmentos.a51"
#include "timer.a51"
#include "teclado_matricial_4x4.a51"
#include "motor_de_passos.a51"
#include "serial.a51"
#include "pwm_com_timer.a51"
#include "i2c_twi.a51"
//#include "rtc.a51"
#include "hc_sr0x.a51"

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
////										  ////
////// 		A finalizar no endereco 0xF5 	//////
////////			(OBRIGATORIO)		  ////////
//////////////////////////////////////////////////

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

ORG	0043h
		LJMP INT_I2C_TWI
	
org 0100h
TEXTO_1:
		db  	'  LEITOR  RFID  ', 00H
TEXTO_2:
		db  	' PASSE O CARTAO ', 00H
	
__STARTUP__:
		LCALL	INIDISP  				// chama rotina de inicializacao do display 16x2
		MOV     DPTR,#TEXTO_1			// seta o DPTR com o endereco da string TEXTO_1
		LCALL   ESC_STR1				// escreve na primeira linha do display
		
		MOV		R2, #01h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
		MOV     DPTR,#TEXTO_2			// seta o DPTR com o endereco da string TEXTO_2
		CALL    ESC_STR2				// escreve na primeira linha do display
		
		MOV		R2, #01h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
		LCALL 	CLR2L
		
		MOV		R0, #10000000b
		MOV		R1, #01010000b
		LCALL	CONFIGURA_SERIAL
		
		MOV		R0, #00100001b
		MOV 	R1, #243
		LCALL	CONFIGURA_BAUD_RATE
		
LOOP:
		LCALL	RECEBE_DADO
		LCALL 	ESCDADO
		
		MOV		R2, #00h
		MOV		R1, #01h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
		JMP 	LOOP

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: INT_INT0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_INT0:
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER0:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_INT1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_INT1:
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER1:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_SERIAL									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_SERIAL:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_I2C_TWI								//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_I2C_TWI:
		CPL		P1.4
		LJMP 	i2c_int
	
		RETI

		END