//////////////////////////////////////////////////////////
//														//
//  		CODIGOS RELACIONADOS AO DISPLAY DE   		//
//			  SETE SEGMENTOS - ANODO & CATODO			//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
// Datasheet do componente e esquematico:				//
//														//
// Necessario ter a biblioteca "timer.a51" como 		//
// dependencia do projeto em questao para funcionar		//
//														//
//////////////////////////////////////////////////////////

ORG		0E00h

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
//////////////////////////////////////////////////

PORT_DISPLAY				EQU	P0
DISPLAY_UNIDADE				EQU P1.0
DISPLAY_DEZENA				EQU P1.1
DISPLAY_CENTENA				EQU	P1.2
	
QTD_DIGITOS					EQU 0FFh
	
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

TAB7SEG:
	DB 3Fh, 06h, 5Bh, 4Fh, 66h, 6Dh, 7Dh, 07h, 7Fh, 6Fh, 77h, 7Ch, 39h, 5Eh, 79h, 71h
		
//////////////////////////////////////////////////////
// NOME: MOSTRA_DIGITO_DISPLAY						//
// DESCRICAO: 										//
// P.ENTRADA: A -> Valor do digito [0, F] 			//
// P.SAIDA: -										//
// ALTERA: A  										//
//////////////////////////////////////////////////////
MOSTRA_DIGITO_DISPLAY:
		PUSH 	DPH
		PUSH	DPL

		MOV 	DPTR, #TAB7SEG	// Move para o DPTR o endereco dos valores para o display de 7 segmentos
		
		MOVC 	A, @A + DPTR	// busca pelo valor referente ao digito a ser impresso
        CPL 	A           	// complementa o digito a ser impresso (necessario para que o display seja usado corretamente)
		MOV 	PORT_DISPLAY, A // Envia para o port do display
		
		POP 	DPL
		POP 	DPH
		
		RET
		
//////////////////////////////////////////////////////
// NOME: BINARIO_BCD								//
// DESCRICAO: TRANSFORMA O CONTADOR BINARIO PARA	//
// TRES, DOIS OU UM DIGITO(S) BCD 					//
// P.ENTRADA: R0 => valor a ser convertido 			//
// 			  R1 => LSB do tempo que o digito 		//
//					fica ativo no display			//
// 			  R2 => MSB do tempo que o digito 		//
//					fica ativo no display			//
//													//
//	OBS: BONS VALORES PARA R1 E R2 SAO 100d E 15d	//
//													//
// P.SAIDA: 										//
// ALTERA: R0, R1, R2 E R3  						//
//////////////////////////////////////////////////////
BINARIO_BCD:
		PUSH 	ACC
		PUSH	B

		CLR		DISPLAY_UNIDADE
		CLR		DISPLAY_DEZENA
		CLR		DISPLAY_CENTENA
		
		// apenas salva o valor de R1 para poder ser reutilizado no final da rotina
		MOV		A, R1
		MOV		R3, A

CONTINUA_BINARIO_BCD:
		MOV 	A, R0
		MOV 	B, #100d // carrega B com o valor 100d (pois temos 3 digitos)
		
		DIV 	AB
		SETB 	DISPLAY_UNIDADE
		ACALL	MOSTRA_DIGITO_DISPLAY
		
		MOV		R0,	#01h
		LCALL	TIMER_DELAY_1_MS
		
		MOV 	A, B
		MOV 	B, #10d
		
		DIV 	AB
		CLR 	DISPLAY_UNIDADE
		SETB	DISPLAY_DEZENA
		ACALL	MOSTRA_DIGITO_DISPLAY
		
		MOV		R0,	#01h
		LCALL	TIMER_DELAY_1_MS
		
		MOV 	A, B
		
		CLR 	DISPLAY_DEZENA
		SETB	DISPLAY_CENTENA
		ACALL	MOSTRA_DIGITO_DISPLAY
		
		MOV		R0,	#01h
		LCALL	TIMER_DELAY_1_MS
		
		CLR		DISPLAY_CENTENA
		
		// De acordo com os valores configurados em R6 e R5, mostra por mais ou menos tempo a velocidade no display
		DJNZ 	R1, CONTINUA_BINARIO_BCD
		
		MOV		A, R3
		MOV		R1, A
		
		DJNZ 	R2, CONTINUA_BINARIO_BCD  
		
		POP 	B
		POP		ACC
		
		RET