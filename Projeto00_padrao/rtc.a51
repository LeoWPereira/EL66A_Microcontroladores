//////////////////////////////////////////////////////////
//														//
//    			CODIGOS RELACIONADOS AO RTC				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG 	0600h

// Endereços de leitura e escrita do RTC
RADDR 	EQU 0xD1
WADDR 	EQU 0xD0
	
// Deve ser colocado na posição correta do JP5
RTC_SQW	EQU P2.1
	
// Serao utilizados para setar e pegar a data/hora do RTC
SEC 	EQU 0050h
MIN 	EQU 0051h
HOU 	EQU 0052h
DAY 	EQU 0053h
DAT 	EQU 0054h
MON 	EQU 0055h
YEA 	EQU 0056h
CTR 	EQU 0057h
LSB		EQU	0058h
MSB		EQU 0059h
	
MULT 	EQU 005Ah // multiplicador de base de tempo utilizado em runT0
T_OUT   EQU 005Bh ; time-out de espera do fim da comunicacao
T_OUTS  EQU 005Ch ; contador do numero de time_outs para estatística

STRING_HORA_MINUTO_SEGUNDO		EQU 005Dh
COMPRIMENTO_STRING_HMS			EQU 08h
	
STRING_DATA_PT_BR				EQU 0066h
COMPRIMENTO_STRING_DATA_PT_BR	EQU 08h
	
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
	
//////////////////////////////////////////////////////
// Nome:	INIT_RTC								//
// Descrição: Inicializa a comunicacao e o RTC		//
// Parâmetros: R0 -> SEC							//
//			   R1 -> MIN							//	
//			   R2 -> HORA							//
//			   R3 -> DIA							// 
//			   R4 -> MES							//
//			   R5 -> ANO							//
//			   R6 -> DIA DA SEMANA					//
//			   R7 -> FREQUENCIA						//
// Retorna:											//
// Destrói: A, R0, R1, R2, R3, R4, R5, R6, R7		//
//////////////////////////////////////////////////////
INIT_RTC:
		//	1.0 - Desabilita as interrupções
		MOV 	IEN0, #00h
		MOV 	IEN1, #00h

		// 	1.1 - Configurar o Timer 0
		MOV 	TMOD, #01h // T0 no modo timer 16bits

		//	1.2 - Configurar o I2C (TWI)
		SETB 	I2C_SCL
		SETB 	I2C_SDA 	// Coloca os latches em high-Z

		// CR2 = 0, CR1 = 0, CR0 = 1, divisor XX, clock 24MHz, I2C = XXXk
		MOV 	SSCON, #01000001b
					   //||||||||_ CR0
					   //|||||||__ CR1
					   //||||||___ AA (vai ser usado apenas na recepção)
					   //|||||____ SI  flag de int
					   //||||_____ STO to send a stop
					   //|||______ STA to send a start
					   //||_______ SSIE Enable TWI
					   //|________ CR2

		//	1-3 Habilita as interrupções
		MOV 	IPL1, #0x02
		MOV 	IPH1, #0x02
		MOV 	IEN1, #0x02	// habilita a int do i2c com prioridade alta.

		SETB 	EA	// liga as ints habilitadas
		
		////////////////////////////////////////////////
		// Configurar o RTC com data e hora definidos //
		////////////////////////////////////////////////
		// 	2.1 - SEX, 19/05/2017 - 15:00:00
		MOV 	SEC, R0 // BCD segundos, deve ser iniciado com valor PAR para o relogio funcionar.
		MOV 	MIN, R1 // BCD minutos
		MOV 	HOU, R2 // BCD hora, se o bit mais alto for 1, o relógio é 12h, senão BCD 24h
		MOV 	DAY, R3 // Dia da semana
		MOV 	DAT, R4 // Dia
		MOV 	MON, R5 // Mês
		MOV 	YEA, R6 // Ano
		MOV 	CTR, R7 // freq

		LCALL 	RTC_SET_TIME
		
		RET
	
//////////////////////////////////////////////////////
// Nome: RTC_SET_TIME								//
// Descricao: escreve data e hora no RTC			//
// Parametros: 										//
// Retorna:											//
// Destroi: A										//
//////////////////////////////////////////////////////
RTC_SET_TIME:
		MOV 	ADDR,  #00h		// endereço do reg interno
		MOV 	B2W,   #(8+1) 	// a quantidade de bytes que deverao ser enviados + 1.
		MOV 	B2R,   #(0+1)	// a quantidade de bytes que serao lidos + 1.
		MOV 	DBASE, #SEC		// endereco base dos dados

		// gera o start, daqui pra frente é tudo na interrupcao.
		MOV 	A, 		SSCON
		ORL 	A, 		#STA
		MOV 	SSCON, 	A

		// Aguardamos 10 ms
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #00Ah
		LCALL	TIMER_DELAY

		// Polling ate certo limite! 500 ms (30 x 16 ms)
		MOV 	T_OUT, #1Eh
		
set_wait:
		JNB 	I2C_BUSY, end_set
		
		// Aguardamos 16 ms - Taxa de atualizacao da tela de 60 Hz
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #010h
		LCALL	TIMER_DELAY
		
		DJNZ 	T_OUT,set_wait
		INC 	T_OUTS
		
end_set:
		RET
		
//////////////////////////////////////////////////////
// Nome: RTC_GET_TIME								//
// Descricao: le data e hora do RTC					//
// Parametros: 										//
// Retorna:											//
// Destroi: A										//
//////////////////////////////////////////////////////
RTC_GET_TIME:
		MOV 	ADDR,  #000h	// endereço do reg interno
		MOV 	B2W,   #(0+1) 	// a quantidade de bytes que deverao ser enviados + 1.
		MOV 	B2R,   #(8+1)	// a quantidade de bytes que serao lidos + 1.
		MOV 	DBASE, #SEC		// endereço base dos dados (buffer)

		// gera o start, daqui pra frente e tudo na interrupcao.
		MOV 	A, 		SSCON
		ORL 	A, 		#STA
		MOV 	SSCON, 	A

		// Aguardamos 10 ms
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #00Ah
		LCALL	TIMER_DELAY

		// Polling ate certo limite! 500 ms (30 x 16 ms)
		MOV 	T_OUT, #1Eh

get_wait:
		JNB 	I2C_BUSY, end_get
		
		// Aguardamos 16 ms - Taxa de atualizacao da tela de 60 Hz
		MOV		R2, #000h
		MOV		R1, #000h
		MOV		R0, #010h
		LCALL	TIMER_DELAY
		
		DJNZ 	T_OUT,get_wait
		INC 	T_OUTS

end_get:
		RET
		
//////////////////////////////////////////////////////
// Nome: RECEBE_DATA_COMPLETA						//
// Descricao: le data e hora do RTC					//
// Parametros: 										//
// Retorna:											//
// Destroi: A										//
//////////////////////////////////////////////////////
RECEBE_DATA_COMPLETA:
		LCALL 	RECEBE_DADO
		MOV 	SEC, A // BCD segundos, deve ser iniciado com valor PAR para o relogio funcionar.
		
		LCALL 	RECEBE_DADO
		MOV 	MIN, A // BCD minutos
		
		LCALL 	RECEBE_DADO
		MOV 	HOU, A // BCD hora, se o bit mais alto for 1, o relógio é 12h, senão BCD 24h
		
		LCALL 	RECEBE_DADO
		MOV 	DAY, A // Dia da semana
		
		LCALL 	RECEBE_DADO
		MOV 	DAT, A // Dia
		
		LCALL 	RECEBE_DADO
		MOV 	MON, A // Mês
		
		LCALL 	RECEBE_DADO
		MOV 	YEA, A // Ano
		
		LCALL 	RECEBE_DADO
		MOV 	CTR, A // CONTROLE
		
		RET
		
//////////////////////////////////////////////////////
// Nome: CONVERTE_BCD								//
// Descricao: Converte o dado de entrada do RTC p/	//
// BCD												//
// Parametros: A 									//
// Retorna: LSB, MSB								//
// Destroi: A										//
//////////////////////////////////////////////////////
CONVERTE_BCD:
		PUSH	ACC
		
		ANL		A, #0Fh
		MOV 	LSB, A
		
		POP		ACC
		
		SWAP	A
		ANL		A, #0Fh
		MOV		MSB, A
		
		RET
		
//////////////////////////////////////////////////////
// Nome: STRINGS_DIAS_DA_SEMANA						//
// Descricao: Move para o DPTR o dia da semana em	//
// questao											//
// Parametros: A 									//
// Retorna: LSB, MSB								//
// Destroi: A										//
//////////////////////////////////////////////////////	
STRINGS_DIAS_DA_SEMANA:
		MOV		A, DAY
		
		CJNE 	A, #01, SEGU
		MOV     DPTR,#DOMINGO	
	 
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA
	
SEGU:
		CJNE 	A, #02, TER
		MOV     DPTR,#SEGUNDA		
	
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA

TER:
		CJNE 	A, #03, QUA
		MOV     DPTR,#TERCA		
	
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA

QUA:
		CJNE 	A, #04, QUI
		MOV     DPTR,#QUARTA		
	
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA
		
QUI:
		CJNE 	A, #05, SEX
		MOV     DPTR,#QUINTA		
	
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA

SEX:
		CJNE 	A, #06, SAB
		MOV     DPTR,#SEXTA	
	
		LJMP	FIM_STRINGS_DIAS_DA_SEMANA

SAB:
		CJNE 	A, #07, FIM_STRINGS_DIAS_DA_SEMANA
		MOV     DPTR,#SABADO		
	
FIM_STRINGS_DIAS_DA_SEMANA:
		RET
		
//////////////////////////////////////////////////////
// Nome: MONTA_STRING_HORA_MINUTO_SEGUNDO			//
// Descricao: 										//
// questao											//
// Parametros: A 									//
// Retorna: LSB, MSB								//
// Destroi: A, R1									//
//////////////////////////////////////////////////////	
MONTA_STRING_HORA_MINUTO_SEGUNDO:
		MOV 	R1, #STRING_HORA_MINUTO_SEGUNDO
		
		MOV		A, HOU 
		LCALL	CONVERTE_BCD
		
		MOV		A, 	 MSB
		ADD		A, 	 #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A, #3Ah // Manda (:)
		MOV		@R1, A
		INC 	R1
		
		MOV		A, MIN 
		LCALL	CONVERTE_BCD
		
		MOV		A, MSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A, #3Ah // Manda (:)
		MOV		@R1, A
		INC 	R1
		
		MOV		A, SEC 
		LCALL	CONVERTE_BCD
		
		MOV		A, MSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		
		RET
		
//////////////////////////////////////////////////////
// Nome: MONTA_STRING_DATA_PT_BR					//
// Descricao: 										//
// questao											//
// Parametros: A 									//
// Retorna: LSB, MSB								//
// Destroi: A										//
//////////////////////////////////////////////////////	
MONTA_STRING_DATA_PT_BR:
		MOV 	R1, #STRING_DATA_PT_BR
		
		MOV		A, DAT
		LCALL	CONVERTE_BCD
		
		MOV		A, MSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A, #2Fh // Manda(/)
		MOV		@R1, A
		INC 	R1
		
		MOV		A, MON 
		LCALL	CONVERTE_BCD
		
		MOV		A, MSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A, #2Fh // Manda(/)
		MOV		@R1, A
		INC 	R1
		
		MOV		A, YEA 
		LCALL	CONVERTE_BCD
		
		MOV		A, MSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		MOV		A,	LSB
		ADD		A, #30h
		MOV		@R1, A
		INC 	R1
		
		RET