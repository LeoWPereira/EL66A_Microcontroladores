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