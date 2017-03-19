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
// Uma mensagem contida na memoria de     //
// programa no endereco de base 2000h     //
// deve ser enviada para o port P0        //
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

/////////////
// STRINGS //
/////////////
str_padrao:
	org 2000h
	db  'Esse trabalho merece nota extra, nao?!', 00H

main:
	mov DPTR, #2000h // inicializa o DPTR com o endereco 2000h
	
	mov R0, #str_padrao // R0 representa a quantidade de caracteres presente no texto a ser lido
	
	mov R1, #00h // R1 representa o caracter atual do texto a ser lido
	
escreve_texto:
	mov A, R1

	movc A, @A + DPTR
	
	mov P0, A
	
	inc R1
	
	djnz R0, escreve_texto

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