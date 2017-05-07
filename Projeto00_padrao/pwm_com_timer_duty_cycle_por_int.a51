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
	
PWM_FLAG 			EQU 0	// Flag to indicate high/low pwm signal

WAVE_FORM_SINE		EQU 00h
WAVE_FORM_SQUARE	EQU 01h

WAVE_FORM 			EQU 31h	// 00h = sine wave; 01h = square wave
DUTY_CYCLE			EQU 32h // 00h = 0% duty cycle; FFh = 100% duty cycle

// 3 bytes for Period: from 0000h til FFFFFFh (16777215 us) So .... 1 Hz = 1000000 = 0F4240h
PERIOD_LSB			EQU 33h
PERIOD_MED			EQU 34h	
PERIOD_MSB			EQU 35h

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
	// Habilita Interrupcao 0 e 1
	SETB	EX0 // interrupcao 0 
	SETB	EX1	// interrupcao 1 
	SETB	IE0 // interrupcao por borda
	SETB 	IE1 // interrupcao por borda
	
	MOV		WAVE_FORM, #WAVE_FORM_SQUARE // wave form
	MOV		A, WAVE_FORM
	
	JZ		SINE_WAVE

	CJNE	A, #02h, SQUARE_WAVE

	CLR		A

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
	MOV		R7, PERIOD_MSB
	
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
	MOV		PERIOD_MSB, #001h
	MOV		PERIOD_MED, #0C8h
	MOV		PERIOD_LSB, #052h
	
	MOV		R7, PERIOD_MSB
	
	MOV 	TH1, PERIOD_MED
	MOV		TL1, PERIOD_LSB
	
	RET

/////////////////
// SQUARE WAVE //
/////////////////	
SQUARE_WAVE:
	CALL	PWM_SQUARE_WAVE_SETUP
	
	JMP 	$
	
PWM_SQUARE_WAVE_SETUP:
	MOV 	TMOD, #00010000b  // Timer1 in Mode 1 (16 bits without auto-reload)
	MOV 	DUTY_CYCLE, #127d // Set pulse width control (50%)
	
	CALL	PWM_SQUARE_WAVE_CONFIG_PERIOD
	
	SETB 	EA 	// Enable Interrupts
	SETB 	ET1 // Enable Timer 1 Interrupt
	SETB 	TR1 // Start Timer
	
	RET
	
PWM_SQUARE_WAVE_CONFIG_PERIOD:
	// Considerando 20 ciclos de maquina para a interrupcao
	// 0xE * 0xFF * 0xFF =~ 1Hz 
	// 0x0 * 0x4 * 0xFF = 1kHz
	MOV		PERIOD_MSB, #000h
	MOV		PERIOD_MED, #004h
	MOV		PERIOD_LSB, #0FFh
	
	MOV		R6, PERIOD_MED
	MOV		R7, PERIOD_MSB
	
	MOV 	TH1, #0FFh
	MOV		TL1, PERIOD_LSB
	
	RET

PWM_STOP:
	CLR 	TR1			; Stop timer to stop PWM
	
	RET
	
PWM_INTERRUPT_SQUARE_WAVE:	
	DJNZ	R6, CONTINUE_SQUARE
	MOV		R6, PERIOD_MED
	
	DJNZ	R7, CONTINUE_SQUARE
	MOV		R7, PERIOD_MSB	

	JB		PWM_FLAG, HIGH_DONE	// If PWM_FLAG flag is set then we just finished
				
LOW_DONE:			
	SETB 	PWM_FLAG
	SETB 	PWM_PIN
	
	MOV		TH1, #0FFh
	MOV 	TL1, DUTY_CYCLE		
	
	CLR 	TF1
	
	RET
				
HIGH_DONE:
	CLR 	PWM_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
	CLR 	PWM_PIN				// Make PWM output pin low
	
	MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
	CLR		C
	SUBB	A, DUTY_CYCLE
	
	MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
	MOV		TL1, A
	
	CLR 	TF1					// Clear the Timer 1 interrupt flag
	
	RET

CONTINUE_SQUARE:
	JNB		PWM_FLAG, CONTINUE_SQUARE_LOW
	
CONTINUE_SQUARE_HIGH:
	MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
	CLR		C
	SUBB	A, DUTY_CYCLE
	
	MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
	MOV		TL1, A

	RET
		
CONTINUE_SQUARE_LOW:
	MOV		TH1, #0FFh
	MOV 	TL1, DUTY_CYCLE
	
	RET

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

/*
* Decrementa o DUTY_CYCLE em 1
*/
INT_INT0:
	PUSH 	ACC
	
	DEC 	DUTY_CYCLE
	
	POP		ACC
	
	RETI

/*
*
*/
INT_TIMER0:
	RETI
	
/*
* Incrementa o DUTY_CYCLE em 1
*/
INT_INT1:
	PUSH 	ACC
	
	INC 	DUTY_CYCLE
	
	POP		ACC

	RETI

/*
*
*/
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
	RETI
/*
*
*/
INT_SERIAL:
	RETI
	
	END