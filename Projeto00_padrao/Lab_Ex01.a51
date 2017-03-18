///////
///////
///////

// Definições da P51USB
LED0 EQU P1.0
LED1 EQU P1.1
LED2 EQU P1.2
LED3 EQU P1.3
LED4 EQU P1.4
LED5 EQU P1.5
LED6 EQU P1.6
LED7 EQU P1.7	

org 0000h //
ljmp main //

org 0003h //
ljmp INT_INT0

org 000Bh //
ljmp INT_TIMER0 //

org 0013h //
ljmp INT_INT1 //

org 001Bh //
ljmp INT_TIMER1 //

org 0023h //
ljmp INT_SERIAL //

main:
	clr LED0
	clr LED1
	clr LED2
	clr LED3
	clr LED4
	clr LED5
	clr LED6
	clr LED7

INICIO:
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
	mov R0, #15h
	
	mov R1, #0FFh
	
VOLTA:
	// 65535 - 50000 = 15535 
	mov TH0, #44h
	mov TL0, #0AFh
	
	clr TF0
	setb TR0
	
	jnb TF0, $
		
	clr TF0
	clr TR0
	
	djnz R0, VOLTA

	ajmp ACIONA_LED

ACIONA_LED:
	mov A, P1
	inc A
	mov P1, A
	
	djnz R1, INICIO
	
	mov A, #00h
	
INT_INT0:
	reti

INT_TIMER0:
	reti
	
INT_INT1:
	reti

INT_TIMER1:
	reti
	
INT_SERIAL:
	reti
	
	end