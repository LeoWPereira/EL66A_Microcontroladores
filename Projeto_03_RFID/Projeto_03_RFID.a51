//////////////////////////////////////////////////////////
//														//
//           		PROJETO 03 - RFID 					//
//														//
// Requisitos: 											//
// 														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
// http://www.circuitstoday.com/interfacing-rfid-module-to-8051
//////////////////////////////////////////////////////////


$NOMOD51
#include <at89c5131.h>
#include "lcd16x2.a51"
#include "timer.a51"
#include "serial.a51"
#include "i2c_twi.a51"
#include "rtc.a51"

BOTAO_SW EQU 20h ;Representa qual interrupcao SW foi pressionado (SW1 = 1 e SW2=0)

SW1 EQU P3.2
SW2 EQU P3.4
	
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
		LCALL 	INIT_RTC
		LCALL 	INIDISP
		
		MOV 	CTR, #00010010b
		CLR 	BOTAO_SW	
		
		MOV 	R1, #00100001b	// Timer 1 no modo 2
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
		
/*BOTAOSW1: 
	JNB 	BOTAO_SW, EHOSW2
	MOV 	A, #'S'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'W'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #31h
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	LJMP 	CONTINUA_ENVIAR*/

EHOSW2:	
	MOV 	A, #'S'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'W'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #32h
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
CONTINUA_ENVIAR:
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL	ATRASO_MS
	MOV 	A, #2Dh ;Manda (-)
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #20h ;Manda (espaço)
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'A'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'c'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'i'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'o'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'n'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'a'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'d'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'o'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #20h
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'a'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #'s'
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, #20h
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	MOV 	A, HOU ;Manda horas
	LCALL 	CONVERTE_BCD
	MOV		A, MSB
	ADD		A, #30h
	LCALL 	ENVIA_DADO
	MOV 	R2, #50
	LCALL 	ATRASO_MS
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
;	MOV 	R7, #0x01
	MOV 	R2, #50
	LCALL 	ATRASO_MS
	/*JNB 	SW1, BOTAUMSW1
	JNB 	SW2, BOTAUMSW2*/
	JNB 	RI, tanormal
	CLR		RI
	MOV		A, SBUF
	CJNE 	A, #0AAh, tanormal
	LJMP 	ESPERA_DADOS
tanormal:
	JMP 	reload
/*BOTAUMSW1: 
	SETB 	BOTAO_SW
	LJMP 	BOTAOSW1
BOTAUMSW2:
	CLR 	BOTAO_SW
	LJMP 	BOTAOSW1*/
reload:
	MOV 	R6, #0x01		; 1x
again:
	MOV 	MULT, #0xA0	; 250x
	LCALL 	runT0			; 0.5ms
	DJNZ 	R6, again		; = 125 ms
;	DJNZ 	R7, reload		; 125 ms x 4 = 0,5s
	LCALL	RTC_GET_TIME
	CPL 	P3.6			; toggle no led
	LCALL	ATUALIZA_DISPLAY
	JMP 	LOOP;

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

;===============================================================================
; Funções do Timer0
;===============================================================================
;------------------------------------------------------------------------------
; Nome: runT0
; Descrição: Gera atraso de tempo utilizando Timer0
; Parâmetros: MULT
; Retorna:
; Destrói: MULT
;------------------------------------------------------------------------------
runT0:
    MOV TH0,#0FCh 	;fclk CPU = 24MHz
    MOV TL0,#17h 	; ... base de tempo de 0,5ms
    SETB TR0 		;dispara timer

    JNB TF0,$ 		;preso CLR TR0 ;stop timer
    CLR TR0 		;para o timer 0
    CLR TF0 		;zera flag overflow
    DJNZ MULT,runT0
    RET   

;***************************************************************************
;NOME: Atraso
;DESCRIÇÃO: Introduz um atraso (delay) de T = (60 x R0 + 48)/fosc
;	Para fosc = 11,059MHz => R0 = 1 => T = 9,8us  a  R0 = 0 => 1,4ms
;P. ENTRADA: R0 = Valor que multiplica por 60 na fórmula (OBS.: R0 = 0 => 256)
;P. SAIDA: -
;Altera: R0
;***************************************************************************
Atraso:
	NOP				;12
	NOP				;12
	NOP				;12
	DJNZ R0,Atraso	;24
	RET				;24


;***************************************************************************
;NOME: ATRASO_MS
;DESCRICAO: INTRODUZ UM ATRASO DE 1ms A 256ms
;P.ENTRADA: R2 = 1 => 1ms  A R2 = 0 => 256ms
;P.SAIDA: -
;ALTERA: R0,R2
ATRASO_MS:
	MOV	R0,#183		;VALOR PARA ATRASO DE 1ms
	CALL	Atraso
	MOV	R0,#183		;VALOR PARA ATRASO DE 1ms
	CALL	Atraso
	DJNZ R2,ATRASO_MS
	RET		
	

END