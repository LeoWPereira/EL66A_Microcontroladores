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

DOMINGO:
		DB		'DOM', 00H
SEGUNDA:
		DB		'SEG', 00H
TERCA:
		DB		'TER', 00H
QUARTA:
		DB		'QUA', 00H
QUINTA:
		DB		'QUI', 00H
SEXTA:
		DB		'SEX', 00H
SABADO:
		DB		'SAB', 00H

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
		// 	SEX, 19/05/2017 - 15:00:00
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
	LCALL 	RECEBE_DADO
	MOV 	SEC, A ; BCD segundos, deve ser iniciado com valor PAR para o relogio funcionar.
	LCALL 	RECEBE_DADO
	MOV 	MIN, A ; BCD minutos
	LCALL 	RECEBE_DADO
	MOV 	HOU, A; BCD hora, se o bit mais alto for 1, o relógio é 12h, senão BCD 24h
	LCALL 	RECEBE_DADO
	MOV 	DAY, A ; Dia da semana
	LCALL 	RECEBE_DADO
	MOV 	DAT, A ; Dia
	LCALL 	RECEBE_DADO
	MOV 	MON, A ; Mês
	LCALL 	RECEBE_DADO
	MOV 	YEA, A ; Ano
	LCALL 	RECEBE_DADO
	MOV 	CTR, A ; CONTROLE
	LCALL	ENVIA_OK
	LCALL 	RTC_SET_TIME
	MOV 	CTR, #10010010b
	JMP 	LOOP

EHOSW2:	
	MOV 	A, #'S'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
		
	MOV 	A, #'W'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #32h
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
CONTINUA_ENVIAR:
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #2Dh ;Manda (-)
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'A'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'c'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'i'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'o'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'n'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'a'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'d'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'o'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #20h
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'a'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #'s'
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, #20h
	LCALL 	ENVIA_DADO

	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV 	A, HOU ;Manda horas
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	
	// Aguardamos 50 ms
	MOV		R2, #000h
	MOV		R1, #000h
	MOV		R0, #032h
	LCALL	TIMER_DELAY
	
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #03Ah ;Manda (:)
	LCALL 	ENVIA_DADO
	MOV 	A, MIN ;Manda minutos
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #03Ah ;Manda (:)
	LCALL 	ENVIA_DADO
	MOV 	A, SEC ;Manda segundos
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	MOV 	A, #2Dh ;Manda (-)
	LCALL 	ENVIA_DADO
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	MOV 	A, DAT ;Manda dia
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #2Fh ;Manda (/)
	LCALL 	ENVIA_DADO
	MOV 	A, MON ;Manda mes
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #2Fh ;Manda (/)
	LCALL 	ENVIA_DADO
	MOV 	A, YEA ; Manda ano
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	MOV 	A, #0Dh ;Retorno ao inicio da linha
	LCALL 	ENVIA_DADO
	MOV 	A, #0Ah ; Nova linha
	LCALL 	ENVIA_DADO

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

;entra: A
;sai:	LSB, MSB
CONVERTE_BCD:
	PUSH	ACC
	ANL		A, #0Fh
	MOV 	LSB, A
	POP		ACC
	SWAP	A
	ANL		A, #0Fh
	MOV		MSB, A
	RET
	
ATUALIZA_DISPLAY:
	LCALL	CLR1L ;Clear na linha 1
	MOV		A, HOU ;Atualiza hora
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A, #3Ah ;Manda (:)
	LCALL	ESCDADO
	MOV		A, MIN ;Atualiza minutos
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A, #3Ah ;Manda (:)
	LCALL	ESCDADO
	MOV		A, SEC ;Atualiza segundos
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	LCALL 	CLR2L ;Clear na linha 2
	MOV		A, DAT ;Atualiza dia
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A, #2Fh ;Manda(/)
	LCALL	ESCDADO
	MOV		A, MON ;Atualiza mes
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A, #2Fh ;Manda(/)
	LCALL	ESCDADO
	MOV		A, YEA ;Atualiza ano
	LCALL	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A,	LSB
	ADD		A, #30h
	LCALL	ESCDADO
	MOV		A, #20h ;Manda (espaço)
	LCALL	ESCDADO
	MOV		A, #2Dh ;Manda(-)
	LCALL	ESCDADO
	MOV		A, #20h ;Manda (espaço)
	LCALL	ESCDADO
	MOV		A, DAY ;Atualiza dia da semana
	CJNE A, #01, SEGU
	MOV      DPTR,#DOMINGO		;STRING 
	LCALL    MSTRING 
	RET
	
SEGU:
	CJNE 	A, #02, TER
	MOV     DPTR,#SEGUNDA		;STRING 
	LCALL   MSTRING
	RET
TER:
	CJNE 	A, #03, QUA
	MOV     DPTR,#TERCA		;STRING 
	LCALL   MSTRING
	RET
QUA:
	CJNE 	A, #04, QUI
	MOV     DPTR,#QUARTA		;STRING 
	LCALL   MSTRING
	RET
QUI:
	CJNE 	A, #05, SEX
	MOV     DPTR,#QUINTA		;STRING 
	LCALL   MSTRING
	RET
SEX:
	CJNE 	A, #06, SAB
	MOV     DPTR,#SEXTA		;STRING 
	LCALL   MSTRING
	RET
SAB:
	CJNE 	A, #07, RETORNA
	MOV     DPTR,#SABADO		;STRING 
	LCALL   MSTRING
RETORNA:
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