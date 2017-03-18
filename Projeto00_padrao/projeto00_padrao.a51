///////
///////
///////

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
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
	mov R0, #15h
	
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
	
	jmp main

	//ljmp SETA_CHAVE_MESTRA
	
/*SETA_CHAVE_MESTRA:	
	mov  007Dh, #01h
	mov  007Eh, #02h
	mov  007Fh, #03h
*/	
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