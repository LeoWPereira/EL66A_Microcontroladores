//////////////////////////////////////
//									//
//     LABORATORIO 17.03.2017 		//
//									//
// @author: Leonardo Winter Pereira //
// @author: Rodrigo Yudi Endo		//
//									//
//////////////////////////////////////

////////////////////////////////////////////
//           ENUNCIADO DO PROBLEMA 		  //
//										  //
// Seja a RAM externa, escreva o alfabeto //
// de "a" ate "z" no endereco de base 	  //
// 1000h								  //
////////////////////////////////////////////

// Definicoes da P51USB


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
	mov DPTR, #1000h // carrega o DPTR com o endereco base 0x1000h
	
	mov R0,   #26d   // 26 letras no alfabeto
	
	mov A,    #61h   // carrega o acumulador com o caracter 'a'
	
escreve_ram_externa:
	movx @DPTR, A
	
	inc DPTR
	
	inc A
	
	djnz R0, escreve_ram_externa

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