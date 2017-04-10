//////////////////////////////////////
//									//
//  PROJETO PADRAO PARA USO GERAL 	//
//									//
// @author: Leonardo Winter Pereira //
// @author: Rodrigo Yudi Endo		//
//									//
//////////////////////////////////////

PWM_PORT			EQU	P1
PWM_PIN				EQU P1.0
PWM_FLAG 			EQU 0	// Flag to indicate high/low signal

WAVE_FORM 			EQU 31h	// 00h = sine wave; 01h = square wave
DUTY_CYCLE			EQU 32h // 00h = 0% duty cycle; FFh = 100% duty cycle
PERIOD				EQU 33h	// 

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

////////////////////////////////////////////////
// REGIAO DA MEMORIA COM AS AMOSTRAS DE ONDAS //
////////////////////////////////////////////////
org 0050h
SINE_WAVE_25_SAMPLES:
	DB 127, 160, 191, 217, 237, 250, 255, 250, 237, 217, 191, 160, 127, 94, 63, 37, 17, 4, 0, 4, 17, 37, 63, 94, 127
SINE_WAVE_37_SAMPLES:
	DB 128, 150, 172, 192, 210, 226, 239, 248, 254, 255, 254, 248, 239, 226, 210, 192, 172, 150, 128, 106, 84, 64, 46, 30, 17, 8, 2, 0, 2, 8, 17, 30, 46, 64, 84, 106, 128
SINE_WAVE_71_SAMPLES:
	DB 128, 139, 150, 161, 172, 182, 192, 201, 210, 218, 226, 233, 239, 245, 248, 253, 254, 255, 254, 253, 248, 245, 239, 233, 226, 218, 210, 201, 192, 182, 172, 161, 150, 139, 128, 117, 106, 95, 84, 74, 64, 55, 46, 38, 30, 24, 17, 13, 8, 5, 2, 1, 0, 1, 2, 5, 8, 13, 17, 24, 30, 38, 46, 55, 64, 74, 84, 95, 106, 117, 128

main:
	CALL	TIMER_CONFIGURA_TIMER
	
	MOV		WAVE_FORM, #01h // wave form
	
	MOV 	A, WAVE_FORM
	JZ		RESTART_SINE_WAVE

	CJNE	A, #02h, RESTART_SQUARE_WAVE

	CLR		A
	
RESTART_SINE_WAVE:
	MOV		DPTR, #SINE_WAVE_71_SAMPLES
	MOV		R1, #70d
	
	CLR		P0.7

NEXT_SAMPLE:
	MOVC	A, @A + DPTR
	MOV		PWM_PORT, A
	CLR		A
	
	MOV		R0, #0C8h
	CALL	TIMER_SINE_PERIOD_05_MS
	
	INC 	DPTR
	DJNZ	R1, NEXT_SAMPLE
	
	JMP		RESTART_SINE_WAVE
	
RESTART_SQUARE_WAVE:
	CALL	PWM_SQUARE_WAVE_SETUP
	
	JMP 	$
	
PWM_SQUARE_WAVE_SETUP:
	MOV 	TMOD, #00h  // Timer1 in Mode 0
	MOV 	DUTY_CYCLE, #229d // Set pulse width control (50%)
	
	// The value loaded in R7 is value X as
	// discussed above.
	SETB 	EA 	// Enable Interrupts
	SETB 	ET1 // Enable Timer 1 Interrupt
	SETB 	TR1 // Start Timer
	
	RET
	
PWM_STOP:
	CLR 	TR0			; Stop timer to stop PWM
	
	RET

////////////////////////////////////////////////
// INICIO DOS CODIGOS RELACIONADOS A TIMER 	  //
////////////////////////////////////////////////

TIMER_CONFIGURA_TIMER:
	MOV 	TMOD, #00000010b // Seta o timer_0 para o modo 02 (08 bits com auto-reload)
	
	// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 01ms
	MOV 	TH0, #041h
	MOV 	TL0, #041h
	
	RET
	
//////////////////////////////////////////////////////
// NOME: TIMER_SINE_PERIOD_05_MS					//
// DESCRICAO: INTRODUZ UM PERIODO DE 05 MS			//
// P.ENTRADA: R0 => (R0 x 05) ms  					//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_SINE_PERIOD_05_MS:
	CLR 	TF0
	SETB 	TR0
	
	JNB 	TF0, $
		
	CLR 	TF0
	CLR 	TR0
	
	DJNZ 	R0, TIMER_SINE_PERIOD_05_MS
	
	RET

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
	JB		PWM_FLAG, HIGH_DONE	// If PWM_FLAG flag is set then we just finished
				
LOW_DONE:			
	SETB 	PWM_FLAG		// Make PWM_FLAG=1 to indicate start of high section
	SETB 	PWM_PIN		// Make PWM output pin High
	MOV 	A, #0FFH		// Move FFH (255) to A
	CLR 	C			// Clear C (the carry bit) so it does not affect the subtraction
	SUBB 	A, DUTY_CYCLE		// Subtract R7 from A. A = 255 - R7.
	MOV 	TH1, A		// so the value loaded into TH0 + R7 = 255
				// (pulse width control value)
	CLR 	TF1			// Clear the Timer 0 interrupt flag
	
	RETI			// Return from Interrupt to where
				// the program came from
HIGH_DONE:
	CLR 	PWM_FLAG		// Make PWM_FLAG=0 to indicate start of low section
	CLR 	PWM_PIN		// Make PWM output pin low
	MOV 	TH1, DUTY_CYCLE		// Load high byte of timer with R7
	CLR 	TF1			// Clear the Timer 0 interrupt flag
	

	RETI
	
/*
*
*/
INT_SERIAL:
	reti
	
	end