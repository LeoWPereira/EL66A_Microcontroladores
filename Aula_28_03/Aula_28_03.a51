/////////////////////////////////////////////////
//														//
//  PROJETO PADRAO PARA USO GERAL 	//
//														//
// @author: Leonardo Winter Pereira 		//
// @author: Rodrigo Yudi Endo				//
//														//
/////////////////////////////////////////////////

/////////////////////////////////////////////////////////////////////////////////////
// Faca um programa que controle a sequencia de acendimento de leds		//
// no port P2 (contador em anel nos dois sentidos), por interrupcoes, a		//
// partir do acionamento de duas chaves momentaneas (S1 e S2),			//
// colocadas nos pinos de INT0 e INT1. S1 devera ser programada por		//
// nivel e S2 por borda de descida														//
/////////////////////////////////////////////////////////////////////////////////////

org 0000h // Origem do codigo 
ljmp __START__ //

org 0003h // Inicio do codigo da interrupcao externa INT0
ljmp __INT_INT0__

org 000Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp __INT_TIMER0__ //

org 0013h // Inicio do codigo da interrupcao externa INT1
ljmp __INT_INT1__ //

org 001Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp __INT_TIMER1__ //

org 0023h // Inicio do codigo da interrupcao SERIAL
ljmp __INT_SERIAL__ //

__START__:
	setb 	TCON.3 // chave S2 definida por borda
	setb 	C
	
	mov 	IE, #10000101b // ativa INT0 e INT1
	mov 	P2, #0 // inicializa o port p2 em 0
	
	jmp $
	
ATUALIZA: //atualiza o LED ativado
	mov P2, A
	
//////////////////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
//////////////////////////////////////////////////////////////

/*
*	Movimenta em sentido horario
*/
__INT_INT0__:
	mov A, P2
	
	rrc A
	jnc ATUALIZA 	// enquanto o carry nao esta setado, ele so rotaciona e atualiza
	
	rrc A 				// caso o carry esteja setado, o contador deve ser rotacionado novamente, para pular o zero
	jmp ATUALIZA

	reti

/*
*
*/
__INT_TIMER0__:
	reti
	
/*
* Movimenta em sentido anti-horario
*/
__INT_INT1__:
	mov A, P2

	rlc A
	jnc ATUALIZA // enquanto o carry nao esta setado, ele so rotaciona e atualiza

	rlc A // caso o carry esteja setado, o contador deve ser rotacionado novamente, para pular o zero
	jmp ATUALIZA
	
	reti

/*
*
*/
__INT_TIMER1__:
	reti
	
/*
*
*/
__INT_SERIAL__:
	reti
	
	end