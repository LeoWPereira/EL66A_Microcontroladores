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