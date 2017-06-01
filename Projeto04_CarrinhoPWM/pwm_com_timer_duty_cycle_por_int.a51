//////////////////////////////////////////////////////////
//														//
//  			CODIGOS RELACIONADOS AO PWM				//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG		0400h

PWM_PIN_0					EQU P2.3
PWM_PIN_1					EQU P2.4

PWM_1_FLAG 					EQU 0	// Flag to indicate high/low pwm signal
PWM_2_FLAG 					EQU 0	// Flag to indicate high/low pwm signal

WAVE_FORM_SINE				EQU 0FEh
WAVE_FORM_SQUARE			EQU 0FDh

WAVE_FORM 					EQU 0FCh	// 00h = sine wave; 01h = square wave
PWM_DUTY_CYCLE_PIN_0		EQU 0FBh // 00h = 0% duty cycle; FFh = 100% duty cycle
PWM_DUTY_CYCLE_PIN_1		EQU 0FAh // 00h = 0% duty cycle; FFh = 100% duty cycle	
PWM_COUNTER					EQU 0F9h

// 3 bytes para o periodo do pwm: [0x000000, 0xFFFFFF] (16777215 us) Logo ... 1 Hz = 1000000 us = 0xF4240
PWM_1_PERIODO_LSB				EQU 0F8h
PWM_1_PERIODO_MED				EQU 0F7h	
PWM_1_PERIODO_MSB				EQU 0F6h
PWM_1_QTDADE_PERIODOS			EQU 0F5h
	
// 3 bytes para o periodo do pwm: [0x000000, 0xFFFFFF] (16777215 us) Logo ... 1 Hz = 1000000 us = 0xF4240
PWM_2_PERIODO_LSB				EQU 0F4h
PWM_2_PERIODO_MED				EQU 0F3h	
PWM_2_PERIODO_MSB				EQU 0F2h
PWM_2_QTDADE_PERIODOS			EQU 0F1h

PWM_1_AUX						EQU	0F0h
PWM_2_AUX						EQU	0EFh


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

//////////////////////////////////////////////////////
// NOME: PWM_1_SQUARE_WAVE_SETUP_AND_START			//
// DESCRICAO: 										//
// P.ENTRADA: R0-> QUANTIDADE DE PERIODOS ATE PARAR	//
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
PWM_1_SQUARE_WAVE_SETUP_AND_START:
		CLR		PWM_PIN_0
		
		MOV		A, R5
		
		MOV		R7, #00100010b // Timer 1 para modo 1
		MOV 	R6, #05h
		MOV 	R5, #05h
		MOV 	R4, #05h
		MOV 	R3, #05h
		LCALL	TIMER_CONFIGURA_TIMER_SEM_INT
		
		MOV		R5, A
	
		LCALL	PWM_1_SQUARE_WAVE_CONFIG_PERIOD
	
		SETB 	TR0

		RET
		
PWM_2_SQUARE_WAVE_SETUP_AND_START:
		CLR		PWM_PIN_1
		
		LCALL	PWM_2_SQUARE_WAVE_CONFIG_PERIOD
	
		SETB 	TR1

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
PWM_1_SQUARE_WAVE_CONFIG_PERIOD:
		MOV		PWM_1_PERIODO_MSB, R2
		MOV		PWM_1_PERIODO_MED, R3
		MOV		PWM_1_PERIODO_LSB, R4
		
		// PWM_QTDADE_PERIODOS soma 2x R0 pois o PWM_COUNTER (que trabalha juntamente com esse outro registrador)
		// e incrementado toda vez que o PWM_PIN muda de estado
		MOV		A, R0
		ADD		A, R0
		MOV		PWM_1_QTDADE_PERIODOS, A
		
		//MOV		R6, PWM_1_PERIODO_MED
		MOV		R7, PWM_1_PERIODO_MSB
		MOV		PWM_1_AUX, R7 
		
		MOV 	TH0, PWM_1_PERIODO_LSB
		MOV		TL0, PWM_1_PERIODO_LSB
		
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
PWM_2_SQUARE_WAVE_CONFIG_PERIOD:
		MOV		PWM_2_PERIODO_MSB, R2
		MOV		PWM_2_PERIODO_MED, R3
		MOV		PWM_2_PERIODO_LSB, R4
		
		// PWM_QTDADE_PERIODOS soma 2x R0 pois o PWM_COUNTER (que trabalha juntamente com esse outro registrador)
		// e incrementado toda vez que o PWM_PIN muda de estado
		MOV		A, R0
		ADD		A, R0
		MOV		PWM_2_QTDADE_PERIODOS, A
		
		//MOV		R6, PWM_2_PERIODO_MED
		MOV		R7, PWM_2_PERIODO_MSB
		MOV		PWM_2_AUX, R7 
		
		MOV 	TH1, PWM_2_PERIODO_LSB
		MOV		TL1, PWM_2_PERIODO_LSB
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_STOP									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
PWM_1_STOP:
		CLR 	TR0
		
		RET
		
PWM_2_STOP:
		CLR 	TR1
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_1_SQUARE_WAVE							//
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
PWM_1_SQUARE_WAVE:	
		//CLR 	TF0
	
		//DJNZ	R6, CONTINUE_SQUARE
		//MOV	R6, PWM_PERIODO_MED
		
		DJNZ	PWM_1_AUX, CONTINUE_SQUARE_1
		MOV		PWM_1_AUX, PWM_1_PERIODO_MSB	
		
		JB		PWM_1_FLAG, HIGH_1_DONE
	
LOW_1_DONE:			
		SETB 	PWM_1_FLAG
		
		MOV		R5, #01h
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV		TH0, PWM_DUTY_CYCLE_PIN_0
		MOV 	TL0, PWM_DUTY_CYCLE_PIN_0		
		
		RET
				
HIGH_1_DONE:
		CLR 	PWM_1_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
		
		MOV		R5, #01h
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_PIN_0
		
		MOV 	TH0, A			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		//CLR 	TF0					// Clear the Timer 1 interrupt flag
		
		RET

CONTINUE_SQUARE_1:
		JNB		PWM_1_FLAG, CONTINUE_SQUARE_LOW_1
	
CONTINUE_SQUARE_HIGH_1:
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_PIN_0
		
		MOV 	TH0, A			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		//CLR 	TF0

		RET
		
CONTINUE_SQUARE_LOW_1:
		MOV		TH0, PWM_DUTY_CYCLE_PIN_0
		MOV 	TL0, PWM_DUTY_CYCLE_PIN_0
		
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
PWM_2_SQUARE_WAVE:	
		//CLR 	TF1
	
		//DJNZ	R6, CONTINUE_SQUARE
		//MOV		R6, PWM_PERIODO_MED
		
		DJNZ	PWM_2_AUX, CONTINUE_SQUARE_2
		MOV		PWM_2_AUX, PWM_2_PERIODO_MSB	
		
		JB		PWM_2_FLAG, HIGH_DONE_2
	
LOW_DONE_2:			
		SETB 	PWM_2_FLAG
		
		MOV		R5, #02h
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV		TH1, PWM_DUTY_CYCLE_PIN_1
		MOV 	TL1, PWM_DUTY_CYCLE_PIN_1		
		
		RET
				
HIGH_DONE_2:
		CLR 	PWM_2_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
			
		MOV		R5, #02h
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_PIN_1
		
		MOV 	TH1, A			// Load high byte of timer with DUTY_CYCLE
		MOV		TL1, A
		
		//CLR 	TF1					// Clear the Timer 1 interrupt flag
		
		RET

CONTINUE_SQUARE_2:
		JNB		PWM_2_FLAG, CONTINUE_SQUARE_LOW_2
	
CONTINUE_SQUARE_HIGH_2:
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_PIN_1
		
		MOV 	TH1, A			// Load high byte of timer with DUTY_CYCLE
		MOV		TL1, A
		
		//CLR 	TF1

		RET
		
CONTINUE_SQUARE_LOW_2:
		MOV		TH1, PWM_DUTY_CYCLE_PIN_1
		MOV 	TL1, PWM_DUTY_CYCLE_PIN_1
		
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
		RET
