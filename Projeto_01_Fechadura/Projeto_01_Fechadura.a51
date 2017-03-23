//////////////////////////////////////////////////////////
//														//
//           PROJETO 01 - FECHADURA ELETRONICA 			//
//														//
// Requisitos: 											//
// - LCD, teclado matricial, buzzer e motor de passos	//
// - 02 senhas padroes na memoria de programa			//
// - Mensagem introdutoria personalizada				//
// - Validacao visual no LCD							//
// - O teclado nao deve possuir bounce					//
// 														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

org 0000h // Origem do codigo 
ljmp __STARTUP__

org 0003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_INT0

org 000Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 0013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_INT1

org 001Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 0023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		  //
////////////////////////////////////////////////

// PARA PLACA USB VERMELHA 1SEM2013
RS			EQU	P2.5			// COMANDO RS LCD
E_LCD		EQU	P2.7			// COMANDO E (ENABLE) LCD
RW			EQU	P2.6			// READ/WRITE
BUSYF		EQU	P0.7			// BUSY FLAG

// LEDS DA PLACA
LED1   		EQU	P3.7
LED_SEG 	EQU	P3.6
	
// LINHAS E COLUNAS DO TECLADO MATRICIAL
COL1 		EQU P1.0
COL2 		EQU P1.1
COL3		EQU P1.2
COL4 		EQU P1.3

LIN1 		EQU P1.4
LIN2		EQU P1.5
LIN3 		EQU P1.6
LIN4 		EQU P1.7
	
// ENDEREÇOS DOS DÍGITOS DOS DADOS DE ENTRADA
TECLADO_1	EQU 31h
TECLADO_2	EQU 32h
TECLADO_3	EQU 33h
TECLADO_4	EQU 34h
TECLADO_5	EQU 35h
TECLADO_6	EQU 36h
	
// CONTADOR DO TIMER
COUNTER		EQU 37h

// ENDEREÇOS DOS DÍGITOS DE CADA SENHA
SENHA1_1	EQU 41h
SENHA1_2	EQU 42h
SENHA1_3	EQU 43h
SENHA1_4	EQU 44h

SENHA2_1	EQU 45h
SENHA2_2	EQU 46h
SENHA2_3	EQU 47h
SENHA2_4	EQU 48h

TENTATIVAS  EQU 49h

/////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS SENHAS //
/////////////////////////////////////////////////

SENHA_PADRAO_1:
	org 0030h
	db  '2812', 00H

SENHA_PADRAO_2:
	org 0034h
	db  '2017', 00H
		
////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			  //
////////////////////////////////////////////////		

__STARTUP__:
	mov DPTR, #0030h  	// inicializa o DPTR com o endereco da senha 01
	mov R0, #00h 	    // R0 representa o caracter atual do texto a ser lido
	mov R1, #SENHA1_1 	// R1 possui o endereco do registrador do primeiro numero da senha 01
	mov R2, #04h	  	// quantidade de digitos da senha 01
	CALL LE_SENHA
	
	mov DPTR, #0034h	// inicializa o DPTR com o endereco da senha 02
	mov R0, #00h 		// R0 representa o caracter atual do texto a ser lido
	mov R1, #SENHA2_1	// R1 possui o endereco do registrador do primeiro numero da senha 02
	mov R2, #04h		// quantidade de digitos da senha 02
	CALL LE_SENHA
	
//////////////////////////////////////////////////////
// NOME: LE_SENHA e LE_SENHA_ROM					//
// DESCRICAO: ROTINA QUE LE A SENHA CODIFICADA NA	//
// ROM E ARMAZENA NO ENDERECO APONTADO POR R1		//
// ENTRADA: R1 -> Ponteiro para a variavel			//
//			DPTR -> Endereco da posicao da senha	//
//			R0 -> Caracter atual da senha			//
// SAIDA: -											//
// DESTROI: R1, R0, R2 								//
//////////////////////////////////////////////////////
LE_SENHA:
	call LE_SENHA_ROM
	
	INC R1
	
	djnz R2, LE_SENHA
	
	RET

LE_SENHA_ROM:
	mov A, R0
	movc A, @A + DPTR
	mov @R1, A
	
	inc R0
	
	call CONV_ASCII_TO_NUMBER
	
	RET
	
//////////////////////////////////////////////////////
// NOME: CONV_ASCII_TO_NUMBER						//
// DESCRICAO: ROTINA QUE CONVERTE UM ASCII LIDO		//
// PARA UM VALOR NUMERICO QUE PODE SER TESTADO		//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: 										//
//////////////////////////////////////////////////////
CONV_ASCII_TO_NUMBER:
	mov A, @R1
	
	ADD A, #-30h
	
	mov @R1, A
	
	RET

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

/*
*
*/
INT_INT0:
	RETI

/*
*
*/
INT_TIMER0:
	RETI
	
/*
*
*/
INT_INT1:
	RETI

/*
*
*/
INT_TIMER1:
	RETI
	
/*
*
*/
INT_SERIAL:
	RETI
	
END