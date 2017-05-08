//////////////////////////////////////////////////////////
//														//
//  			CODIGOS RELACIONADOS AO PWM				//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0A00h
	
PWM_PORT			EQU	P1
PWM_PIN_0			EQU P1.0
PWM_PIN_1			EQU P1.1
PWM_PIN_2			EQU P1.2
	
PWM_FLAG 			EQU 0	// Flag to indicate high/low pwm signal

WAVE_FORM_SINE		EQU 00h
WAVE_FORM_SQUARE	EQU 01h

WAVE_FORM 			EQU 31h	// 00h = sine wave; 01h = square wave
PWM_DUTY_CYCLE		EQU 32h // 00h = 0% duty cycle; FFh = 100% duty cycle
PWM_COUNTER			EQU 33h

// 3 bytes para o periodo do pwm: [0x000000, 0xFFFFFF] (16777215 us) Logo ... 1 Hz = 1000000 us = 0xF4240
PWM_PERIODO_LSB		EQU 33h
PWM_PERIODO_MED		EQU 34h	
PWM_PERIODO_MSB		EQU 35h
PWM_QTDADE_PERIODOS	EQU 36h

////////////////////////////////////////////////
// REGIAO DA MEMORIA COM AS AMOSTRAS DE ONDAS //
////////////////////////////////////////////////
org 0A50h
SINE_WAVE_25_SAMPLES:
	DB 127, 160, 191, 217, 237, 250, 255, 250, 237, 217, 191, 160, 127, 94, 63, 37, 17, 4, 0, 4, 17, 37, 63, 94, 127
SINE_WAVE_37_SAMPLES:
	DB 128, 150, 172, 192, 210, 226, 239, 248, 254, 255, 254, 248, 239, 226, 210, 192, 172, 150, 128, 106, 84, 64, 46, 30, 17, 8, 2, 0, 2, 8, 17, 30, 46, 64, 84, 106, 128
SINE_WAVE_71_SAMPLES:
	DB 128, 139, 150, 161, 172, 182, 192, 201, 210, 218, 226, 233, 239, 245, 248, 253, 254, 255, 254, 253, 248, 245, 239, 233, 226, 218, 210, 201, 192, 182, 172, 161, 150, 139, 128, 117, 106, 95, 84, 74, 64, 55, 46, 38, 30, 24, 17, 13, 8, 5, 2, 1, 0, 1, 2, 5, 8, 13, 17, 24, 30, 38, 46, 55, 64, 74, 84, 95, 106, 117, 128

/*main:
	MOV		WAVE_FORM, #WAVE_FORM_SQUARE // wave form
	MOV		A, WAVE_FORM
	
	JZ		SINE_WAVE

	CJNE	A, #02h, SQUARE_WAVE

	CLR		A*/

//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE_SETUP_AND_START			//
// DESCRICAO: 										//
// P.ENTRADA: R0-> QUANTIDADE DE PERIODOS ATE PARAR	//
//			  R1-> DUTY CYCLE						//
//			  R2-> PWM_PERIODO_MSB					//
//			  R3-> PWM_PERIODO_MED					//
//			  R4-> PWM_PERIODO_LSB					//
//			  R5-> FLAG PARA PINOS A SEREM ATIVADOS //
//				bit 0 = PWM_PIN_0					//
//				bit 1 = PWM_PIN_1					//
//				bit 2 = PWM_PIN_2					//
// P.SAIDA: 										//
// ALTERA: [R0, R5]									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE_SETUP_AND_START:
		MOV		A, R5
		
		MOV		R7, #00000001b
		MOV 	R6, #HIGH(65535 - 53330)
		MOV 	R5, #LOW(65535 - 53330)
		ACALL	TIMER_CONFIGURA_TIMER_SEM_INT
		
		MOV		R5, A
		
		MOV 	PWM_DUTY_CYCLE, R1
	
		LCALL	PWM_SQUARE_WAVE_CONFIG_PERIOD
	
		SETB 	TR0

CONTINUA_PWM:
		LCALL	PWM_SQUARE_WAVE
		
		MOV 	A, PWM_COUNTER
		CJNE	A, PWM_QTDADE_PERIODOS, CONTINUA_PWM

PWM_PARAR:
		LCALL	PWM_STOP
		
		MOV		PWM_COUNTER, #00h
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE_CONFIG_PERIOD				//
// DESCRICAO: 										//
// P.ENTRADA: R0-> QUANTIDADE DE PERIODOS ATE PARAR //
//			  R2-> PWM_PERIODO_MSB					//
//			  R3-> PWM_PERIODO_MED					//
//			  R4-> PWM_PERIODO_LSB					//
// P.SAIDA: R6, R7 									//
// ALTERA: R6, R7 									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE_CONFIG_PERIOD:
		MOV		PWM_PERIODO_MSB, R2
		MOV		PWM_PERIODO_MED, R3
		MOV		PWM_PERIODO_LSB, R4
		
		// PWM_QTDADE_PERIODOS soma 2x R0 pois o PWM_COUNTER (que trabalha juntamente com esse outro registrador)
		// e incrementado toda vez que o PWM_PIN muda de estado
		MOV		A, R0
		ADD		A, R0
		MOV		PWM_QTDADE_PERIODOS, A
		
		MOV		R6, PWM_PERIODO_MED
		MOV		R7, PWM_PERIODO_MSB
		
		MOV 	TH0, #0FFh
		MOV		TL0, PWM_PERIODO_LSB
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_STOP									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
PWM_STOP:
		CLR 	TR0
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE							//
// DESCRICAO: 										//
// P.ENTRADA: R6, R7					 	 		//
//			  R5-> FLAG PARA PINOS A SEREM ATIVADOS //
//				bit 0 = PINO_LED_VERDE				//
//				bit 1 = PWM_PIN_0					//
//				bit 2 = PWM_PIN_1					//
//				bit 3 = PWM_PIN_2					//
// P.SAIDA: - 										//
// ALTERA: R6, R7									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE:	
		JNB 	TF0, $
	
		DJNZ	R6, CONTINUE_SQUARE
		MOV		R6, PWM_PERIODO_MED
		
		DJNZ	R7, CONTINUE_SQUARE
		MOV		R7, PWM_PERIODO_MSB	

		// Se chegou ate aqui, incrementa o contador do PWM (para sinalizar a quantidade de vezes que queremos chamar o PWM)
		INC		PWM_COUNTER

		JB		PWM_FLAG, HIGH_DONE
	
LOW_DONE:			
		SETB 	PWM_FLAG
		
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV		TH0, #0FFh
		MOV 	TL0, PWM_DUTY_CYCLE		
		
		CLR 	TF0
		
		RET
				
HIGH_DONE:
		CLR 	PWM_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
			
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE
		
		MOV 	TH0, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		CLR 	TF0					// Clear the Timer 1 interrupt flag
		
		RET

CONTINUE_SQUARE:
		JNB		PWM_FLAG, CONTINUE_SQUARE_LOW
	
CONTINUE_SQUARE_HIGH:
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE
		
		MOV 	TH0, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		CLR 	TF0

		RET
		
CONTINUE_SQUARE_LOW:
		MOV		TH0, #0FFh
		MOV 	TL0, PWM_DUTY_CYCLE
		
		CLR 	TF0
		
		RET

//////////////////////////////////////////////////////
// NOME: DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS	//
// DESCRICAO: 										//
// P.ENTRADA: R5-> FLAG PARA PINOS					//
//				bit 0 = PWM_PIN_0					//
//				bit 1 = PWM_PIN_1					//
//				bit 2 = PWM_PIN_2					//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS:
		MOV		A, #01h
		ANL		A, R5
		JZ		NAO_ATIVA_BIT_0
		
		CPL 	PWM_PIN_0
		
NAO_ATIVA_BIT_0:
		MOV		A, #02h
		ANL		A, R5
		JZ		NAO_ATIVA_BIT_1
		
		CPL 	PWM_PIN_1

NAO_ATIVA_BIT_1:
		MOV		A, #04h
		ANL		A, R5
		JZ		NAO_ATIVA_BIT_2
		
		CPL 	PWM_PIN_2

NAO_ATIVA_BIT_2:
		RET
		
/*
///////////////
// SINE WAVE //
///////////////
SINE_WAVE:
	CALL	PWM_SINE_WAVE_SETUP
	
PWM_SINE_WAVE_NEXT_PERIOD:
	MOV		DPTR, #SINE_WAVE_71_SAMPLES
	MOV		R1, #70d
	
	CLR		P0.7
	
TESTA_R1:
	MOV		A, R1
	JZ		PWM_SINE_WAVE_NEXT_PERIOD
	
	JMP 	TESTA_R1

PWM_INTERRUPT_SINE_NEXT_SAMPLE:
	DJNZ	R7, CONTINUE_SINE
	MOV		R7, PWM_PERIODO_MSB
	
	MOVC	A, @A + DPTR
	MOV		PWM_PORT, A
	CLR		A
	
	INC 	DPTR
	DEC		R1
	
	CALL	PWM_SINE_WAVE_CONFIG_PERIOD

CONTINUE_SINE:
	RET
	
PWM_SINE_WAVE_SETUP:
	MOV 	TMOD, #00010000b  // Timer1 in Mode 1 (16 bits without auto-reload)
	
	CALL	PWM_SINE_WAVE_CONFIG_PERIOD
	
	SETB 	EA 	// Enable Interrupts
	SETB 	ET1 // Enable Timer 1 Interrupt
	SETB 	TR1 // Start Timer
	
	RET
	
// Considerando 70 samples:
// 30 us para executar cada sample
// 1 Hz = 1000000 us
// (1000000 - 30) / 70 = 14255 contagens / sample
// 14255 = 0x37AF
// 0xFFFF - 0x37AF = 0xC850
// 1 kHz = 1000 us
// (1000 - 30) / 70 = 13 (D)
// 0xFFFF - 0xD = 0xFFF2
PWM_SINE_WAVE_CONFIG_PERIOD:
	MOV		PWM_PERIODO_MSB, #001h
	MOV		PWM_PERIODO_MED, #0C8h
	MOV		PWM_PERIODO_LSB, #052h
	
	MOV		R7, PWM_PERIODO_MSB
	
	MOV 	TH1, PWM_PERIODO_MED
	MOV		TL1, PWM_PERIODO_LSB
	
	RET

/////////////////
// SQUARE WAVE //
/////////////////	
SQUARE_WAVE:
	CALL	PWM_SQUARE_WAVE_SETUP
	
	JMP 	$
	
PWM_SQUARE_WAVE_SETUP:
	MOV 	TMOD, #00010000b  // Timer1 in Mode 1 (16 bits without auto-reload)
	MOV 	PWM_DUTY_CYCLE, #35d // Set pulse width control (50%)
	
	CALL	PWM_SQUARE_WAVE_CONFIG_PERIOD
	
	SETB 	EA 	// Enable Interrupts
	SETB 	ET1 // Enable Timer 1 Interrupt
	SETB 	TR1 // Start Timer
	
	RET
	
PWM_INTERRUPT_SQUARE_WAVE:	
	DJNZ	R6, CONTINUE_SQUARE
	MOV		R6, PWM_PERIODO_MED
	
	DJNZ	R7, CONTINUE_SQUARE
	MOV		R7, PWM_PERIODO_MSB	

	JB		PWM_FLAG, HIGH_DONE	// If PWM_FLAG flag is set then we just finished
				
LOW_DONE:			
	SETB 	PWM_FLAG
	SETB 	PWM_PIN
	
	MOV		TH1, #0FFh
	MOV 	TL1, PWM_DUTY_CYCLE		
	
	CLR 	TF1
	
	RET
				
HIGH_DONE:
	CLR 	PWM_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
	CLR 	PWM_PIN				// Make PWM output pin low
	
	MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
	CLR		C
	SUBB	A, PWM_DUTY_CYCLE
	
	MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
	MOV		TL1, A
	
	CLR 	TF1					// Clear the Timer 1 interrupt flag
	
	RET

CONTINUE_SQUARE:
	JNB		PWM_FLAG, CONTINUE_SQUARE_LOW
	
CONTINUE_SQUARE_HIGH:
	MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
	CLR		C
	SUBB	A, PWM_DUTY_CYCLE
	
	MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
	MOV		TL1, A

	RET
		
CONTINUE_SQUARE_LOW:
	MOV		TH1, #0FFh
	MOV 	TL1, PWM_DUTY_CYCLE
	
	RET

INT_TIMER1:
	PUSH	ACC

	MOV		A, WAVE_FORM
	
	JZ		JUMP_SINE_INT

	CJNE	A, #02h, JUMP_SQUARE_INT

JUMP_SINE_INT:
	CALL	PWM_INTERRUPT_SINE_NEXT_SAMPLE

	POP		ACC
	RETI

JUMP_SQUARE_INT:
	CALL 	PWM_INTERRUPT_SQUARE_WAVE
	
	POP		ACC
	RETI*/