//////////////////////////////////////////////////////////
//														//
//           		PROJETO 03 - RFID 					//
//														//
// Requisitos: 											//
// 														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////


$NOMOD51
#include <at89c5131.h>
#include "lcd16x2.a51"
#include "timer.a51"
#include "serial.a51"
#include "i2c_twi.a51"
#include "rtc.a51"

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
////										  ////
////// 		A finalizar no endereco 0xE7 	//////
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
	
__STARTUP__:
		// 	Seta data para: SEX, 19/05/2017 - 15:00:00
		MOV 	R0, #000h 		
		MOV 	R1, #000h 		
		MOV 	R2, #015h 		
		MOV 	R3, #006h 		
		MOV 	R4, #019h 		
		MOV 	R5, #005h 		
		MOV 	R6, #017h 		
		MOV 	R7, #00010010b  // freq 8192khz
		LCALL 	INIT_RTC
		
		LCALL 	INIDISP
		
		MOV 	R1, #00100000b	// Timer 1 no modo 2
		MOV 	R0, #0F3h		// seta timer1 para baud rate 9600
		LCALL	CONFIGURA_BAUD_RATE
		
		MOV 	R1, #01010000b
		MOV 	R0, #10000000b
		LCALL	CONFIGURA_SERIAL
		
main:
		LJMP 	LOOP
	
ESPERA_DADOS:
		LCALL 	RECEBE_DADO
		CJNE 	A, #01h, main
		
		LCALL	RECEBE_DATA_COMPLETA
		
		LCALL	ENVIA_OK
		
		LCALL 	RTC_SET_TIME
		
		MOV 	CTR, #10010010b
		
		JMP 	LOOP

;------------------------------------------------------------------------------
;Ler o RTC periodicamente
;------------------------------------------------------------------------------
LOOP:
		// Aguardamos 50 ms
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #032h
		LCALL	TIMER_DELAY
		
		JNB 	RI, again
		CLR		RI
		MOV		A, SBUF
		CJNE 	A, #0AAh, again
		LJMP 	ESPERA_DADOS

again:
		// Aguardamos 125 ms
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #07Dh
		LCALL	TIMER_DELAY
		
		LCALL	RTC_GET_TIME
		
		CPL 	P3.6
		
		LCALL	ATUALIZA_DISPLAY
		
		JMP 	LOOP
	
ATUALIZA_DISPLAY:
		LCALL	CLR1L // Clear na linha 1
	
		LCALL	MONTA_STRING_HORA_MINUTO_SEGUNDO
		
		MOV		R2, #COMPRIMENTO_STRING_HMS
		MOV		R1, #STRING_HORA_MINUTO_SEGUNDO

escreve_string_hms:
		MOV		A,  @R1
		LCALL   ESCDADO
		INC 	R1	
		DJNZ 	R2, escreve_string_hms
	
		LCALL 	CLR2L // Clear na linha 2

		LCALL	MONTA_STRING_DATA_PT_BR
		
		MOV		R2, #COMPRIMENTO_STRING_DATA_PT_BR
		MOV		R1, #STRING_DATA_PT_BR

escreve_string_data_pt_br:
		MOV		A,  @R1
		LCALL   ESCDADO
		INC 	R1	
		DJNZ 	R2, escreve_string_data_pt_br
	
		MOV		A, #20h // Manda (espaço)
		LCALL	ESCDADO
		
		MOV		A, #2Dh // Manda(-)
		LCALL	ESCDADO
		
		MOV		A, #20h // Manda (espaço)
		LCALL	ESCDADO
	
		LCALL	STRINGS_DIAS_DA_SEMANA
		LCALL   MSTRING
	
	RET
	
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