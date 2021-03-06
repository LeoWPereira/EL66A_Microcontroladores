//////////////////////////////////////////////////////////
//														//
//  	CODIGOS RELACIONADOS AO TECLADO MATRICIAL		//
//														//
// Datasheet do componente e esquematico:				//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG		0C00h

TECLADO		EQU	P1
	
// LINHAS E COLUNAS DO TECLADO MATRICIAL
COL1 		EQU P1.0
COL2 		EQU P1.1
COL3		EQU P1.2
COL4 		EQU P1.3
	
LIN1 		EQU P1.4
LIN2		EQU P1.5
LIN3 		EQU P1.6
LIN4 		EQU P1.7

//////////////////////////////////////////////////////
// NOME: PRESS_ENT									//
// DESCRICAO: ESPERA PRESSIONAR ENTER				//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
PRESS_ENT:
		MOV		TECLADO, #01111111b		// Apenas LIN4 esta em 0
		
VARRE_ENT:
		JNB  	COL4, CONTINUA_PROG 	// se apertou ENTER, testa senha
		
		JMP  	VARRE_ENT
CONTINUA_PROG:
		RET
		
///////////////////////////////////////////////////////
// NOME: VARREDURA_TECLADO							 //
// DESCRICAO: VARRE O TECLADO					 	 //
// ENTRADA:											 //	
// SAIDA:											 //
// DESTROI:											 //
///////////////////////////////////////////////////////
VARREDURA_TECLADO:
		CLR  	LIN1
		SETB 	LIN2
		SETB 	LIN3
		SETB 	LIN4
		JNB		COL1, DIGITOF1
		JNB  	COL2, DIGITO1
		JNB  	COL3, DIGITO2
		JNB  	COL4, DIGITO3
		
		CLR  	LIN2
		SETB 	LIN1
		JNB		COL1, DIGITOF2
		JNB  	COL2, DIGITO4
		JNB  	COL3, DIGITO5
		JNB  	COL4, DIGITO6
		
		CLR  	LIN3
		SETB 	LIN2
		//JNB		COL1, $
		JNB  	COL2, DIGITO7
		JNB  	COL3, DIGITO8
		JNB  	COL4, DIGITO9
		
		CLR  	LIN4
		SETB 	LIN3
		//JNB		COL1, $
 		//JNB  	COL2, $
		JNB  	COL3, DIGITO0
		//JNB		COL4, $
		
		JMP  	VARREDURA_TECLADO
		
//////////////////////////////////////////////////////////////////////////
// NOME: DIGITOX (X = [0,9])											//
// DESCRICAO: Coloca o valor X em R1 e grava no d�gito correspondente	//
// ao valor atual de R2													//
// ENTRADA: R1 -> ponteiro para o caracter da senha atual a ser lido	//
// SAIDA:																//
// DESTROI: A															//
//////////////////////////////////////////////////////////////////////////
DIGITO1: 
		MOV A, #01h
		AJMP GRAVA_DIGITO
DIGITO2:
		MOV A, #02h
		AJMP GRAVA_DIGITO
DIGITO3: 
		MOV A, #03h
		AJMP GRAVA_DIGITO
DIGITO4:
		MOV A, #04h
		AJMP GRAVA_DIGITO
DIGITO5:
		MOV A, #05h
		AJMP GRAVA_DIGITO
DIGITO6:
		MOV A, #06h
		AJMP GRAVA_DIGITO
DIGITO7:
		MOV A, #07h
		AJMP GRAVA_DIGITO
DIGITO8:
		MOV A, #08h
		AJMP GRAVA_DIGITO
DIGITO9:
		MOV A, #09h
		AJMP GRAVA_DIGITO
DIGITO0:
		MOV A, #00h
		AJMP GRAVA_DIGITO
DIGITOF1:
		MOV A, #0Ch
		AJMP GRAVA_DIGITO
DIGITOF2:
		MOV A, #0Dh
		
GRAVA_DIGITO:
		MOV @R1, A
	
		RET