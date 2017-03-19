//////////////////////////////////////
//									//
//     LABORATORIO 17.03.2017 		//
//									//
// @author: Leonardo Winter Pereira //
// @author: Rodrigo Yudi Endo		//
//									//
//////////////////////////////////////

//////////////////////////////////////////////
//           ENUNCIADO DO PROBLEMA 		    //
//										    //
// Projete um contador binario modulo 256   //
// decrescente que acenda os LED's contidos //
// em P1.0 a P1.7						    //
//////////////////////////////////////////////

// Definicoes da P51USB
LED0 EQU P1.0
LED1 EQU P1.1
LED2 EQU P1.2
LED3 EQU P1.3
LED4 EQU P1.4
LED5 EQU P1.5
LED6 EQU P1.6
LED7 EQU P1.7	

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

main:
	mov P1, #0FFh // reseta o Port P1 para 0
	
	mov R1, #0FFh // contador de modulo 256, para marcar o overflow de 8 bits

	ljmp timer_configura_timer
	
aciona_led:
	mov A, P1 // move para o acumulador o estado atual do Port P1
	dec A // decrementa o acumulador
	mov P1, A // retorna o valor para o Port P1
	
	djnz R1, timer_delay_1_s
	
	mov P1, #0FFh // reinicia o valor do Port P1, por segurança
	mov R1, #0FFh // reinicia tambem o contador R1
	
	ljmp timer_delay_1_s
	
////////////////////////////////////////////////
//  INICIO DOS CODIGOS RELACIONADOS AO TIMER  //
////////////////////////////////////////////////

timer_configura_timer:
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
timer_delay_1_s:
	mov R0, #20d // 20 vezes
	
timer_delay_50_ms:
	// 65535 - 49987 = 15548 ()
	mov TH0, #HIGH(65535 - 49987) // 0x3Ch
	mov TL0, #LOW(65535 - 49987)	// 0xBCh
	
	clr TF0 // reseta flag de contagem maxima
	setb TR0 // inicializa o timer
	
	jnb TF0, $ // nao faz nada enquanto o flag TF0 vale 0
		
	clr TF0 // reseta flag TF0 quando estoura a contagem do TIMER
	clr TR0 // reseta flag TR0 quando estoura a contagem do TIMER
	
	djnz R0, timer_delay_50_ms // como ate aqui sao 50 ms, fazemos isso o numero de vezes desejado
	
	ljmp aciona_led

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
	reti
	
/*
*
*/
INT_SERIAL:
	reti
	
	end