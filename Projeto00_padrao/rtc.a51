//////////////////////////////////////////////////////////
//														//
//    			CODIGOS RELACIONADOS AO RTC				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG 	0700h

// Endere�os de leitura e escrita do RTC
RADDR 	EQU 0xD1
WADDR 	EQU 0xD0
	
// Deve ser colocado na posi��o correta do JP5
RTC_SQW	EQU P2.1
	
// Serao utilizados para setar e pegar a data/hora do RTC
SEC 	EQU 00F4h
MIN 	EQU 00F3h
HOU 	EQU 00F2h
DAY 	EQU 00F1h
DAT 	EQU 00F0h
MON 	EQU 00EFh
YEA 	EQU 00EEh
CTR 	EQU 00EDh
LSB		EQU	00ECh
MSB		EQU 00EBh
	
MULT 	EQU 00EAh // multiplicador de base de tempo utilizado em runT0
T_OUT   EQU 00E9h ; time-out de espera do fim da comunica��o
T_OUTS  EQU 00E8h ; contador do numero de time_outs para estat�stica
	
//////////////////////////////////////////////////////
// Nome:	INIT_RTC								//
// Descri��o: Inicializa a comunica��o e o RTC		//
// Par�metros: SEC, MIN, HOU, 						//
// Retorna:											//
// Destr�i: A										//
//////////////////////////////////////////////////////
INIT_RTC:
	//	1.0 - Desabilita as interrup��es
	MOV IEN0, #0x00
	MOV IEN1, #0x00

	// 	1.1 - Configurar o Timer 0
	MOV TMOD, #0x01 ; T0 no modo timer 16bits

	//	1.2 - Configurar o I2C (TWI)
	SETB I2C_SCL
	SETB I2C_SDA ; Coloca os latches em high-Z

	// CR2 = 0, CR1 = 0, CR0 = 1, divisor XX, clock 24MHz, I2C = XXXk
	MOV SSCON, #01000001b
			  //||||||||_ CR0
		 	  //|||||||__ CR1
			  //||||||___ AA (vai ser usado apenas na recep��o)
			  //|||||____ SI  flag de int
			  //||||_____ STO to send a stop
			  //|||______ STA to send a start
			  //||_______ SSIE Enable TWI
			  //|________ CR2

	//	1-3 Habilita as interrup��es
	MOV IPL1, #0x02
	MOV IPH1, #0x02
	MOV IEN1, #0x02	// habilita a int do i2c com prioridade alta.

	;SETB ES ; habilita a int da serial (para o flashmon!)
	SETB EA	// liga as ints habilitadas
	
	//------------------------------------------------------------------------------
	// Configurar o RTC com data e hora definidos
	//------------------------------------------------------------------------------
	// 	2.1 - TER, 09/05/2017 - 13:50:00
	MOV SEC, #000h  // BCD segundos, deve ser iniciado com valor PAR para o relogio funcionar.
	MOV MIN, #050d // BCD minutos
	MOV HOU, #010d // BCD hora, se o bit mais alto for 1, o rel�gio � 12h, sen�o BCD 24h
	MOV DAY, #002d // Dia da semana
	MOV DAT, #009d // Dia
	MOV MON, #005d // M�s
	MOV YEA, #017d // Ano
	MOV CTR, #00010010b ; freq 8192khz

	LCALL RTC_SET_TIME
	
	RET
	
;------------------------------------------------------------------------------
; Nome:	RTC_SET_TIME
; Descri��o: escreve data e hora no RTC
; Par�metros: SEC, MIN, HOU
; Retorna:
; Destr�i: A
;------------------------------------------------------------------------------
RTC_SET_TIME:
	MOV ADDR, #0x00		; endere�o do reg interno
	MOV B2W, #(8+1) 	; a quantidade de bytes que dever�o ser enviados + 1.
	MOV B2R, #(0+1)		; a quantidade de bytes que ser�o lidos + 1.
	MOV DBASE, #SEC		; endere�o base dos dados

	; gera o start, daqui pra frente � tudo na interrup��o.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	// devemos aguardar um tempo "suficiente" para ser gerada a interrup��o de START
	MOV		R0, #005h
	MOV		R1, #000h
	MOV		R2, #000h
	LCALL	TIMER_DELAY

	; Polling at� certo limite! 500 ms
	MOV T_OUT, #100
set_wait:
	JNB I2C_BUSY, end_set
	
	// Aguardamos 16 ms
	MOV		R0, #016d
	MOV		R1, #000h
	MOV		R2, #000h
	LCALL	TIMER_DELAY
	
	DJNZ T_OUT,set_wait
	INC T_OUTS
end_set:
	RET
	
;------------------------------------------------------------------------------
; Nome:	RTC_GET_TIME
; Descri��o: l� data e hora do RTC
; Par�metros:
; Retorna: SEC, MIN, HOU
; Destr�i: A
;------------------------------------------------------------------------------
RTC_GET_TIME:
	MOV ADDR, #0x00		; endere�o do reg interno
	MOV B2W, #(0+1) 	; a quantidade de bytes que dever�o ser enviados + 1.
	MOV B2R, #(8+1)		; a quantidade de bytes que ser�o lidos + 1.
	MOV DBASE, #SEC		; endere�o base dos dados (buffer)

	; gera o start, daqui pra frente � tudo na interrup��o.
	MOV A, SSCON
	ORL A, #STA
	MOV SSCON, A

	// devemos aguardar um tempo "suficiente" para ser gerada a interrup��o de START
	MOV		R0, #00Ah
	MOV		R1, #000h
	MOV		R2, #000h
	LCALL	TIMER_DELAY

	; Polling at� certo limite. rev2 RdG
	MOV T_OUT, #100
get_wait:
	JNB I2C_BUSY, end_get
	
	// Aguardamos 16 ms
	MOV		R0, #016d
	MOV		R1, #000h
	MOV		R2, #000h
	LCALL	TIMER_DELAY
	
	DJNZ 	T_OUT,get_wait
	INC 	T_OUTS

end_get:
		RET