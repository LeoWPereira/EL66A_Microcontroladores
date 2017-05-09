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
//#include "teclado_matricial_4x4.a51"
//#include "motor_de_passos.a51"
//#include "pwm_com_timer.a51"
//#include "i2c_twi.a51"
//#include "rtc.a51"
//#include "serial.a51"
//#include "hc_sr0x"

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
////										  ////
////// 		A comecar no endereco 0x101 	//////
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
	
__STARTUP__:
		MOV		R0, #050d
		MOV		R1, #005d
		MOV		R2, #002d
		LCALL	TIMER_DELAY
		
		JMP 	__STARTUP__

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
		RETI

		END