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

org 0000h // Origem do codigo 
ljmp main //

org 0003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_INT0

org 000Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0 //

org 0013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_INT1 //

org 001Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1 //

org 0023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL //

org 0030h
TEXTO_1:
		db  	'  LEITOR  RFID 2', 00H

main:
	CALL	INIDISP  				// chama rotina de inicializacao do display 16x2
		MOV     DPTR,#TEXTO_1			// seta o DPTR com o endereco da string TEXTO_1
		CALL    ESC_STR1				// escreve na primeira linha do display
		
		// Atrasa 1s para escrever outra string
		MOV		R1, #03h
		CALL 	TIMER_DELAY_1_S
		
		jmp main

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

/*
*
*/
INT_INT0:
	reti

/*
*
*/
INT_TIMER0:
	reti
	
/*
*
*/
INT_INT1:
	reti

/*
*
*/
INT_TIMER1:
	reti
	
/*
*
*/
INT_SERIAL:
	reti
	
	end