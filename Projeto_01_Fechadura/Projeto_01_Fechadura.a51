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

org 2000h // Origem do codigo 
ljmp __STARTUP__

org 2003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_INT0

org 200Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 2013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_INT1

org 201Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 2023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		  //
////////////////////////////////////////////////

// PARA PLACA USB VERMELHA
RS				EQU	P2.5			// COMANDO RS LCD
RW				EQU	P2.6			// READ/WRITE
E_LCD			EQU	P2.7			// COMANDO E (ENABLE) LCD

BUSYF			EQU	P0.7			// BUSY FLAG

// LEDS DA PLACA
LED_SEG 		EQU	P3.6
LED1   			EQU	P3.7
	
// LINHAS E COLUNAS DO TECLADO MATRICIAL
TECLADO			EQU	P1

COL1 			EQU P1.0
COL2 			EQU P1.1
COL3			EQU P1.2
COL4 			EQU P1.3

LIN1 			EQU P1.4
LIN2			EQU P1.5
LIN3 			EQU P1.6
LIN4 			EQU P1.7
	
// BUZZER
BUZZER			EQU P3.0	

// ESTADOS DO MOTOR DE PASSO
ESTADO_UM 		EQU P3.1
ESTADO_DOIS 	EQU P3.2
ESTADO_TRES 	EQU P3.3
ESTADO_QUATRO 	EQU P3.4
	
// ENDEREÇOS DOS DIGITOS DOS DADOS DE ENTRADA
TECLADO_1		EQU 31h
TECLADO_2		EQU 32h
TECLADO_3		EQU 33h
TECLADO_4		EQU 34h

// ENDEREÇOS DOS DIGITOS DE CADA SENHA
SENHA1_1		EQU 35h
SENHA1_2		EQU 36h
SENHA1_3		EQU 37h
SENHA1_4		EQU 38h

SENHA2_1		EQU 45h
SENHA2_2		EQU 46h
SENHA2_3		EQU 47h
SENHA2_4		EQU 48h

TENTATIVAS  	EQU 50h
	
TIMEOUT_LOW		EQU	51h
TIMEOUT_HIGH	EQU	52h
TIMEOUT_X1S		EQU	53h
		
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

org 2030h
SENHA_PADRAO_1:
		db  	'2812', 00H
SENHA_PADRAO_2:
		db  	'0912', 00H
STR_LOGO:
        DB      ' PROFS. LINDOS! ',00H
STR_LEONARDO_PEREIRA:
        DB      'Leonardo Pereira',00H
STR_RODRIGO_ENDO:
        DB      '  Rodrigo Endo  ',00H
STR_SENHA:
        DB      'SENHA: ',00H
STR_PRESSIONE_ENTER:
        DB      'PRESSIONE ENTER ',00H
STR_SENHA_VALIDA:
        DB      '  SENHA VALIDA  ',00H
STR_SENHA_INVALIDA:
        DB      ' SENHA INVALIDA ',00H
STR_LIBERANDO_PORTA:
        DB      'LIBERANDO PORTA ',00H
STR_TRANCANDO_PORTA:
        DB      'TRANCANDO PORTA ',00H		
STR_SISTEMA_BLOQUEADO:
        DB      'PORTA BLOQUEADA ',00H
STR_TIMEOUT:
        DB      '    TIMEOUT     ',00H			
		
////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			  //
////////////////////////////////////////////////		

__STARTUP__:
		CALL 	TIMER_CONFIGURA_TIMER
		CALL 	INT_CONFIGURA_INTERRUPCOES
		
		MOV 	R0, #0Fh		// R0 x 20 ms com o buzzer acionado - apenas para mostrar que o sistema esta inicializando
		LCALL 	ACIONA_BUZZER

		MOV 	DPTR, #SENHA_PADRAO_1  	// inicializa o DPTR com o endereco da senha 01
		MOV 	R0, #00h 	    		// R0 representa o caracter atual do texto a ser lido
		MOV 	R1, #SENHA1_1 			// R1 possui o endereco do registrador do primeiro numero da senha 01
		MOV 	R2, #04h	  			// quantidade de digitos da senha 01
		CALL 	LE_SENHA
	
		MOV 	DPTR, #SENHA_PADRAO_2	// inicializa o DPTR com o endereco da senha 02
		MOV 	R0, #00h 				// R0 representa o caracter atual do texto a ser lido
		MOV 	R1, #SENHA2_1			// R1 possui o endereco do registrador do primeiro numero da senha 02
		MOV 	R2, #04h				// quantidade de digitos da senha 02
		CALL 	LE_SENHA
	
		MOV 	TENTATIVAS, #3h	// Igual ao sistema de cartao de credito - Caso erre 3x seguidas a senha, bloqueia o sistema, tendo que reiniciar o sistema pelo botao fisico de RESET
	
MAIN:
		CALL	INIDISP  		// chama rotina de inicializacao do display 16x2
		MOV     DPTR,#STR_LOGO	// seta o DPTR com o endereco da string LOGO
		CALL    ESC_STR1		// escreve na primeira linha do display
		
		// Atrasa 1s para escrever outra string
		MOV		R1, #01h
		CALL 	TIMER_DELAY_1_S
		
		CALL 	CLR1L	// limpa primeira linha do display
		
		MOV 	DPTR, #STR_LEONARDO_PEREIRA	// seta o DPTR com o endereco da string LEONARDO_PEREIRA
		CALL    ESC_STR1					// escreve na primeira linha do display
		
		MOV 	DPTR, #STR_RODRIGO_ENDO		// seta o DPTR com o endereco da string RODRIGO_ENDO
		CALL    ESC_STR2					// escreve na segunda linha do display
		
		// Atrasa 1s para escrever outra string
		MOV		R1, #01h
		CALL 	TIMER_DELAY_1_S

LIMPA_LCD_E_INICIA_SISTEMA:
		// Limpa ambas as linhas do display
		CALL 	CLR1L
		CALL 	CLR2L
		
		// Inicialmente, sera necessario o usuario apertar ENTER (simulando um sistema de bancos, por exemplo, onde voce precisa primeiro inserir o cartao para depois entrar com a senha)
		MOV     DPTR,#STR_PRESSIONE_ENTER	// seta o DPTR com o endereco da string PRESSIONE_ENTER
		CALL    ESC_STR1					// escreve na primeira linha do display
		
		ACALL 	PRESS_ENT		// espera o pressionamento da tecla ENTER
		
		MOV 	R0, #05h
		LCALL 	ACIONA_BUZZER

LIMPA_LCD_E_REINICIA_SISTEMA:
		CALL	CONFIGURA_VALORES_TIMER_1 // Temos 3 registradores separados para o TIMER_1 (sendo o TIMEOUT_X1S o mais importante -> TIMEOUT_X1S x 1s)
		SETB	TR1	// Como queremos ter a opcao de TIMEOUT no projeto, aciona o TR1, que comeca a contagem do TIMER_1

LIMPA_LCD_E_PEDE_SENHA:
		// Limpa ambas as linhas do display
		CALL 	CLR1L
		CALL 	CLR2L
		
		// Apos apertar ENTER, pede-se a senha (que precisa bater com uma das 2 senhas pre-definidas)
		MOV     DPTR,#STR_SENHA	// seta o DPTR com o endereco da string SENHA
		CALL    ESC_STR1		// escreve na primeira linha do display
		
		// Move para a coluna 07 da primeira linha do display
		MOV 	R0, #00h 	// linha
		MOV 	R1, #07h	// coluna
		CALL 	GOTOXY
		
		MOV 	R1, #TECLADO_1 	// ponteiro para a primeira leitura do teclado
		MOV 	R3, #1h		   	// primeiro digito a ser lido, esse registrador e incrementado automaticamente ao terminar de varrer o teclado
		MOV 	R7, #04h		// quantidade de digitos a serem lidos consecutivamente
LE_4_DIGITOS:
		MOV 	R0, #0Ah 		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no teclado matricial
		ACALL 	TIMER_DELAY_20_MS
		
		ACALL 	VARREDURA_TECLADO	// permanece varrendo o teclado ate que alguma tecla seja pressionada
		CALL 	ESCREVE_ASTERISCO	// escreve apenas um * na tela, semelhante a como funciona um sistema de cartao / banco
		
		INC R1	// incrementa o ponteiro R1, que aponta agora para o proximo digito a ser lido
		INC R3	
		
		DJNZ R7, LE_4_DIGITOS // enquanto nao ler os 4 digitos, se mantem no loop
		
		// Apos ler os 4 digitos da senha, e necessario testar a senha com as duas senhas gravadas na ROM
		MOV 	R0, #0Ah		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no teclado matricial
		ACALL 	TIMER_DELAY_20_MS
		
		ACALL 	PRESS_ENT_OU_CLR		// espera o pressionamento da tecla ENTER ou CLR
		
		JMP	 	LIMPA_LCD_E_INICIA_SISTEMA

//////////////////////////////////////////////////////
// NOME: LE_SENHA e LE_SENHA_ROM					//
// DESCRICAO: ROTINA QUE LE A SENHA CODIFICADA NA	//
// ROM E ARMAZENA NO ENDERECO APONTADO POR R1		//
// ENTRADA: R1 -> Ponteiro para a variavel			//
//			DPTR -> Endereco da posicao da senha	//
//			R0 -> Caracter atual da senha			//
// SAIDA: -											//
// DESTROI: R1, R0, R2, A 							//
//////////////////////////////////////////////////////
LE_SENHA:
		CALL 	LE_SENHA_ROM
	
		INC 	R1
	
		DJNZ 	R2, LE_SENHA
	
		RET

LE_SENHA_ROM:
		MOV 	A, R0
		MOVC 	A, @A + DPTR
		MOV		@R1, A
	
		INC		R0
	
		CALL	CONV_ASCII_TO_NUMBER
	
		RET
	
//////////////////////////////////////////////////////
// NOME: CONV_ASCII_TO_NUMBER						//
// DESCRICAO: ROTINA QUE CONVERTE UM ASCII LIDO		//
// PARA UM VALOR NUMERICO QUE PODE SER TESTADO		//
// ENTRADA: R1 -> Ponteiro para a variavel			//
// SAIDA: -											//
// DESTROI: A 										//
//////////////////////////////////////////////////////
CONV_ASCII_TO_NUMBER:
		MOV 	A, @R1
	
		ADD 	A, #-30h
	
		MOV 	@R1, A
	
		RET
	
//////////////////////////////////////////////////////
// NOME: ESCREVE_ASTERISCO							//
// DESCRICAO: ROTINA QUE ESCREVE UM * NO LCD		//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
ESCREVE_ASTERISCO:		
		MOV 	R0, #05h
		LCALL 	ACIONA_BUZZER
		
		MOV 	A, #2Ah // valor em hexa para '*'
		CALL 	ESCDADO
	
		RET

//////////////////////////////////////////////////////
// NOME: PRESS_ENT									//
// DESCRICAO: Ao digitar os 4 digitos da senha, e	//
// necessario apertar ENTER							//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
PRESS_ENT:
		// Apenas LIN4 esta em 0
		MOV		TECLADO, #01111111b
		
VARRE_ENT:
		JNB  	COL4, CONTINUA_PROG 	// se apertou ENTER, testa senha
		
		JMP  	VARRE_ENT
CONTINUA_PROG:
		RET
		
//////////////////////////////////////////////////////
// NOME: PRESS_ENT_OU_CLR							//
// DESCRICAO: Ao digitar os 4 digitos da senha, e	//
// necessario apertar ENTER							//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////	
PRESS_ENT_OU_CLR:
		// Apenas LIN4 esta em 0
		MOV		TECLADO, #01111111b
		
VARRE_ENT_OU_CLR:
		JNB  	COL2, CLEAR			// se apertou CLR, limpa senha de entrada
		JNB  	COL4, TESTA_SENHA1 	// se apertou ENTER, testa senha
		
		JNB		TR1, FINALIZA_VARREDURA_POR_TIMEOUT
		
		JMP  	VARRE_ENT_OU_CLR

//////////////////////////////////////////////////////
// NOME: CLEAR										//
// DESCRICAO: Reseta os digitos do teclado para as	//
// senhas normais. Os POPs sao necessarios por		//
// causa do ACALL feito no main						//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
CLEAR: 
		MOV 	R0, #05h
		LCALL 	ACIONA_BUZZER
		
		POP		ACC
		POP		ACC
		JMP 	LIMPA_LCD_E_PEDE_SENHA
		
///////////////////////////////////////////////////////
// NOME: VARREDURA_TECLADO							 //
// DESCRICAO: Varredura de teclado					 //
// ENTRADA:											 //	
// SAIDA:											 //
// DESTROI:											 //
///////////////////////////////////////////////////////
VARREDURA_TECLADO:
		CLR  	LIN1
		SETB 	LIN2
		SETB 	LIN3
		SETB 	LIN4
		JNB  	COL2, DIGITO1
		JNB  	COL3, DIGITO2
		JNB  	COL4, DIGITO3
		
		CLR  	LIN2
		SETB 	LIN1
		JNB  	COL2, DIGITO4
		JNB  	COL3, DIGITO5
		JNB  	COL4, DIGITO6
		
		CLR  	LIN3
		SETB 	LIN2
		JNB  	COL2, DIGITO7
		JNB  	COL3, DIGITO8
		JNB  	COL4, DIGITO9
		
		CLR  	LIN4
		SETB 	LIN3
 		JNB  	COL2, CLEAR
		JNB  	COL3, DIGITO0
		
		JNB		TR1, FINALIZA_VARREDURA_POR_TIMEOUT
		
		JMP  	VARREDURA_TECLADO

FINALIZA_VARREDURA_POR_TIMEOUT:
		CALL	ESCREVE_TIMEOUT

		POP		ACC
		JMP		LIMPA_LCD_E_INICIA_SISTEMA
		
//////////////////////////////////////////////////////////////////////////
// NOME: DIGITOX (X = [0,9])											//
// DESCRICAO: Coloca o valor X em R1 e grava no dígito correspondente	//
// ao valor atual de R2													//
// ENTRADA: R1 -> ponteiro para o caracter da senha atual a ser lido	//
// SAIDA:																//
// DESTROI: A															//
//////////////////////////////////////////////////////////////////////////
DIGITO1: MOV A, #1h
		 AJMP GRAVA_DIGITO
DIGITO2: MOV A, #2h
		 AJMP GRAVA_DIGITO
DIGITO3: MOV A, #3h
		 AJMP GRAVA_DIGITO
DIGITO4: MOV A, #4h
		 AJMP GRAVA_DIGITO
DIGITO5: MOV A, #5h
		 AJMP GRAVA_DIGITO
DIGITO6: MOV A, #6h
		 AJMP GRAVA_DIGITO
DIGITO7: MOV A, #7h
		 AJMP GRAVA_DIGITO
DIGITO8: MOV A, #8h
		 AJMP GRAVA_DIGITO
DIGITO9: MOV A, #9h
		 AJMP GRAVA_DIGITO
DIGITO0: MOV A, #0h
		 AJMP GRAVA_DIGITO
		 
GRAVA_DIGITO:
		CJNE R3, #1h, GRAVA_TECLADO_2
		MOV @R1, A
	
		RET

//////////////////////////////////////////////////////
// NOME: TESTA_SENHAX [1,2]							//
// DESCRICAO: Compara os dígitos fornecidos pelo	//
// usuário com a senha X							//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
TESTA_SENHA1:
		MOV 	R0, #05h
		LCALL 	ACIONA_BUZZER
		 
		CLR		TR1 // Se chegou ate aqui é porque o usuario apertou ENTER, entao nao precisa mais dar TIMEOUT
		
		MOV	 	A, SENHA1_1
		CJNE 	A, TECLADO_1, TESTA_SENHA2
		MOV	 	A, SENHA1_2
		CJNE 	A, TECLADO_2, TESTA_SENHA2
		MOV	 	A, SENHA1_3
		CJNE 	A, TECLADO_3, TESTA_SENHA2
		MOV	 	A, SENHA1_4
		CJNE 	A, TECLADO_4, TESTA_SENHA2
		JMP 	LIMPA_LCD_E_MOSTRA_SENHA_VALIDA
	
TESTA_SENHA2:
		MOV	 	A, SENHA2_1
		CJNE 	A, TECLADO_1, LIMPA_LCD_E_MOSTRA_SENHA_INVALIDA
		MOV	 	A, SENHA2_2
		CJNE 	A, TECLADO_2, LIMPA_LCD_E_MOSTRA_SENHA_INVALIDA
		MOV	 	A, SENHA2_3
		CJNE 	A, TECLADO_3, LIMPA_LCD_E_MOSTRA_SENHA_INVALIDA
		MOV	 	A, SENHA2_4
		CJNE 	A, TECLADO_4, LIMPA_LCD_E_MOSTRA_SENHA_INVALIDA
		JMP 	LIMPA_LCD_E_MOSTRA_SENHA_VALIDA
		
//////////////////////////////////////////////////////////////////////////
// NOME: GRAVA_TECLADO_X [2,4]											//
// DESCRICAO: Grava o valor de R1 e no dígito X do teclado				//
// ENTRADA: R1															//
// SAIDA: TECLADO_X														//
// DESTROI: 															//
//////////////////////////////////////////////////////////////////////////
GRAVA_TECLADO_2: CJNE R3, #2h, GRAVA_TECLADO_3
				 AJMP GRAVA_TECLADO_X
GRAVA_TECLADO_3: CJNE R3, #3h, GRAVA_TECLADO_4
GRAVA_TECLADO_4: AJMP GRAVA_TECLADO_X		

GRAVA_TECLADO_X:
		 MOV @R1, A
		 
		 RET
		 
LIMPA_LCD_E_MOSTRA_SENHA_INVALIDA:
		// Limpa ambas as linhas do display
		CALL 	CLR1L
		CALL 	CLR2L
		
		MOV     DPTR,#STR_SENHA_INVALIDA	// string da primeira linha
		CALL    ESC_STR1					// escreve na primeira linha
		
		// Aciona o buzzer por 2s
		MOV 	R0, #064h
		LCALL 	ACIONA_BUZZER
		
		// Atrasa 3s (contando o tempo do buzzer) para reiniciar o sistema (caso nao tenha errado a senha 3x em sequencia)
		MOV		R1, #01h
		CALL 	TIMER_DELAY_1_S
		
		DJNZ	TENTATIVAS, REINICIA_SISTEMA
		
		CALL 	CLR1L
		MOV     DPTR,#STR_SISTEMA_BLOQUEADO	// string da primeira linha
		CALL    ESC_STR1					// escreve na primeira linha
		
		JMP 	FIM

REINICIA_SISTEMA:
		RET
		
LIMPA_LCD_E_MOSTRA_SENHA_VALIDA:
		MOV 	TENTATIVAS, #3h // reinicia numero de tentativas
		
		// Limpa ambas as linhas do display
		CALL 	CLR1L
		CALL 	CLR2L
		
		MOV     DPTR,#STR_SENHA_VALIDA	// string da primeira linha
		CALL    ESC_STR1				// escreve na primeira linha
		
		// Aciona por 1s o buzzer
		MOV 	R0, #032h
		LCALL 	ACIONA_BUZZER
		
		MOV 	DPTR, #STR_LIBERANDO_PORTA	// string da segunda linha
		CALL    ESC_STR2					// escreve na segunda linha
		
		// Aciona o mecanismo (motor de passos) para abrir a fechadura
		MOV 	R5, #0Dh
		LCALL 	ABRE_FECHADURA
		
		// Atrasa 3s para escrever outra string
		MOV		R1, #03h
		CALL 	TIMER_DELAY_1_S
		
		CALL 	CLR2L 						// limpa a segunda linha do LCD
		MOV 	DPTR, #STR_TRANCANDO_PORTA	// string da segunda linha
		CALL    ESC_STR2					// escreve na segunda linha
		
		// Aciona o mecanismo (motor de passos) para trancar a fechadura (basicamente faz o caminho oposto ao ABRE_FECHADURA)
		MOV 	R5, #0Dh
		LCALL 	TRANCA_FECHADURA
		
		RET
		 
///////////////////
// ACIONA BUZZER //
//  R0 x 20 MS 	 //
///////////////////
ACIONA_BUZZER:
		SETB 	BUZZER
		ACALL 	TIMER_DELAY_20_MS
		CLR 	BUZZER
		
		RET
		
//////////////////////////////////////////////
// CODIGOS RELACIONADOS AO MOTOR DE PASSOS	//
//////////////////////////////////////////////
ABRE_FECHADURA:
		SETB	ESTADO_UM
		CLR		ESTADO_DOIS
		CLR		ESTADO_TRES
		CLR		ESTADO_QUATRO
		
		MOV 	R0, #05h
		ACALL 	TIMER_DELAY_20_MS
		
		CLR		ESTADO_UM
		SETB	ESTADO_DOIS
		
		MOV 	R0, #05h
		ACALL 	TIMER_DELAY_20_MS
		
		CLR		ESTADO_DOIS
		SETB	ESTADO_TRES
		
		MOV 	R0, #05h
		ACALL 	TIMER_DELAY_20_MS
		
		CLR		ESTADO_TRES
		SETB	ESTADO_QUATRO
		
		MOV 	R0, #05h
		ACALL 	TIMER_DELAY_20_MS
		
		DJNZ 	R5, ABRE_FECHADURA
		
		RET
		
TRANCA_FECHADURA:
		CLR		ESTADO_UM
		CLR		ESTADO_DOIS
		CLR		ESTADO_TRES
		SETB	ESTADO_QUATRO
		
		MOV 	R0, #01h
		ACALL 	TIMER_DELAY_20_MS
		
		SETB	ESTADO_TRES
		CLR		ESTADO_QUATRO
		
		MOV 	R0, #01h
		ACALL 	TIMER_DELAY_20_MS
		
		SETB	ESTADO_DOIS
		CLR		ESTADO_TRES
		
		MOV 	R0, #01h
		ACALL 	TIMER_DELAY_20_MS
		
		SETB	ESTADO_UM
		CLR		ESTADO_DOIS
		
		MOV 	R0, #01h
		ACALL 	TIMER_DELAY_20_MS
		
		DJNZ 	R5, TRANCA_FECHADURA

		RET
		
//////////////////////////////////////////////////////
//													//
//////////////////////////////////////////////////////
ESCREVE_TIMEOUT:
		CALL 	CLR1L
		CALL 	CLR2L
		
		// Apos apertar ENTER, pede-se a senha (que precisa bater com uma das 2 senhas pre-definidas)
		MOV     DPTR,#STR_TIMEOUT	// seta o DPTR com o endereco da string SENHA
		CALL    ESC_STR1			// escreve na primeira linha do display
		
		// Atrasa 2s para escrever outra string
		MOV		R1, #02h
		CALL 	TIMER_DELAY_1_S
		
		RET
		
////////////////////////////////////////////////
// 		  INICIO DOS CODIGOS PARA LCD		  //
////////////////////////////////////////////////
	
//////////////////////////////////////////////////////
// NOME: INIDISP								  	//
// DESCRICAO: ROTINA DE INICIALIZACAO DO DISPLAY	//
// LCD 16x2 --- PROGRAMA CARACTER 5x7, LIMPA		//
// DISPLAY E POSICIONA (0,0)						//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: R0, R2									//
//////////////////////////////////////////////////////
INIDISP:                       
        MOV     R0,#38H         // UTILIZACAO: 8 BITS, 2 LINHAS, 5x7
        MOV     R2,#05          // ESPERA 5ms
        CALL    ESCINST         // ENVIA A INSTRUCAO
        
		MOV     R0,#38H         // UTILIZACAO: 8 BITS, 2 LINHAS, 5x7
        MOV     R2,#01          // ESPERA 1ms
        CALL    ESCINST         // ENVIA A INSTRUCAO
        
		MOV     R0,#06H         // INSTRUCAO DE MODO DE OPERACAO
        MOV     R2,#01          // ESPERA 1ms
        CALL    ESCINST         // ENVIA A INSTRUCAO
        
		MOV     R0,#0CH         // INSTRUCAO DE CONTROLE ATIVO/INATIVO
        MOV     R2,#01          // ESPERA 1ms
        CALL    ESCINST         // ENVIA A INSTRUCAO
        
		MOV     R0,#01H         // INSTRUCAO DE LIMPEZA DO DISPLAY
        MOV     R2,#02          // ESPERA 2ms
        CALL    ESCINST         // ENVIA A INSTRUCAO
        
		RET
		
//////////////////////////////////////////////////////
// NOME: ESCINST									//
// DESCRICAO: ROTINA QUE ESCREVE INSTRUCAO PARA O	//
// DISPLAY E ESPERA DESOCUPAR						//
// ENTRADA: R0 = INSTRUCAO A SER ESCRITA NO MODULO	//
//          R2 = TEMPO DE ESPERA EM ms				//
// SAIDA: -											//
// DESTROI: R0, R2									//	
//////////////////////////////////////////////////////
ESCINST:  
		CLR		RW				// MODO ESCRITA NO LCD
		CLR     RS              // RS  = 0 (SELECIONA REG. DE INSTRUCOES)
		SETB    E_LCD           // E = 1 (HABILITA LCD)
		
		MOV     P0,R0           // INSTRUCAO A SER ESCRITA
		
		CLR     E_LCD           // E = 0 (DESABILITA LCD)
		
		MOV		P0,#0xFF		// PORTA 0 COMO ENTRADA
		
		SETB	RW				// MODO LEITURA NO LCD	
		SETB    E_LCD           // E = 1 (HABILITA LCD)	

ESCI1:	JB	BUSYF,ESCI1			// ESPERA BUSY FLAG = 0
		
		CLR     E_LCD           // E = 0 (DESABILITA LCD)
        
		RET
		
//////////////////////////////////////////////////////
// NOME: GOTOXY										//
// DESCRICAO: ROTINA QUE POSICIONA O CURSOR			//
// ENTRADA: R0 = LINHA (0 A 1)						//
//          R1 = COLUNA (0 A 15)					//
// SAIDA: -											//
// DESTROI: R0,R2									//
//////////////////////////////////////////////////////
GOTOXY: 
		PUSH    ACC
        
		MOV     A,#80H
        CJNE    R0,#01,GT1      // SALTA SE COLUNA 0
        
		MOV     A,#0C0H
		
GT1:    ORL     A,R1            // CALCULA O ENDERECO DA MEMORIA DD RAM
        MOV     R0,A
        MOV     R2,#01          // ESPERA 1ms               
        
		CALL    ESCINST         // ENVIA PARA O MODULO DISPLAY
        
		POP     ACC
        
		RET
	
//////////////////////////////////////////////////////
// NOME: CLR1L										//
// DESCRICAO: ROTINA QUE APAGA PRIMEIRA LINHA DO	//
// DISPLAY LCD E POSICIONA NO INICIO				//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: R0,R1									//
//////////////////////////////////////////////////////
CLR1L:    
        PUSH   ACC
        
		MOV    R0,#00              // LINHA
        MOV    R1,#00
        
		CALL   GOTOXY
        
		MOV    R1,#16              // CONTADOR

CLR1L1: MOV    A,#' '              // ESPACO
        
		CALL   ESCDADO
        
		DJNZ   R1,CLR1L1
        MOV    R0,#00              // LINHA
        MOV    R1,#00
        
		CALL   GOTOXY
        
		POP    ACC
        
		RET
		
//////////////////////////////////////////////////////
// NOME: CLR2L										//
// DESCRICAO: ROTINA QUE APAGA SEGUNDA LINHA DO		//
// DISPLAY LCD E POSICIONA NO INICIO				//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: R0,R1									//
//////////////////////////////////////////////////////
CLR2L:    
        PUSH   ACC
        
		MOV    R0,#01              // LINHA
        MOV    R1,#00
        
		CALL   GOTOXY
        
		MOV    R1,#16              // CONTADOR

CLR2L1: MOV    A,#' '              // ESPACO
        
		CALL   ESCDADO
        
		DJNZ   R1,CLR2L1
        MOV    R0,#01              // LINHA
        MOV    R1,#00
        
		CALL   GOTOXY
        
		POP    ACC
        
		RET
           
//////////////////////////////////////////////////////
// NOME: ESCDADO									//
// DESCRICAO: ROTINA QUE ESCREVE DADO NO DISPLAY	//
// ENTRADA: A = DADO A SER ESCRITO NO DISPLAY		//
// SAIDA: -											//
// DESTROI: R0 										//
//////////////////////////////////////////////////////
ESCDADO:  
		CLR		RW				// MODO ESCRITA NO LCD
        SETB	RS              // RS  = 1 (SELECIONA REG. DE DADOS)
        SETB  	E_LCD           // LCD = 1 (HABILITA LCD)
		
        MOV   	P0,A            // ESCREVE NO BUS DE DADOS
        
		CLR   	E_LCD           // LCD = 0 (DESABILITA LCD)
		
		MOV		P0,#0xFF		// PORTA 0 COMO ENTRADA
		
		SETB	RW				// MODO LEITURA NO LCD
		CLR		RS				// RS = 0 (SELECIONA INSTRUÇÃO)	
		SETB    E_LCD           // E = 1 (HABILITA LCD)

ESCD1:	JB		BUSYF,ESCD1		// ESPERA BUSY FLAG = 0

		CLR     E_LCD          	// E = 0 (DESABILITA LCD)

        RET
		
//////////////////////////////////////////////////////
// NOME: MSTRING									//
// DESCRICAO: ROTINA QUE ESCREVE UMA STRING DA ROM	//
// NO DISPLAY A PARTIR DA POSICAO DO CURSOR			//
// ENTRADA: DPTR = ENDERECO INICIAL DA STRING NA	//
// MEMORIA ROM FINALIZADA POR 00H					//
// SAIDA: -											//
// DESTROI: A,DPTR,R0								//
//////////////////////////////////////////////////////
MSTRING:  
		  CLR    A
          MOVC   A,@A+DPTR      // CARACTER DA MENSAGEM EM A
          
		  JZ     MSTR1
          
		  LCALL  ESCDADO        // ESCREVE O DADO NO DISPLAY
          
		  INC    DPTR
          
		  SJMP   MSTRING
		  
MSTR1:    RET
           
//////////////////////////////////////////////////////
// NOME: MSTRINGX									//
// DESCRICAO: ROTINA QUE ESCREVE UMA STRING DA RAM	//
// NO DISPLAY A PARTIR DA POSICAO DO CURSOR			//
// ENTRADA: DPTR = ENDERECO INICIAL DA STRING NA	//
// MEMORIA RAM FINALIZADA POR 00H					//
// SAIDA: -											//
// DESTROI: A,DPTR,R0								//
//////////////////////////////////////////////////////
MSTRINGX: 
		  MOVX   A,@DPTR        // CARACTER DA MENSAGEM EM A
          
		  JZ     MSTR21
          
		  LCALL  ESCDADO        //ESCREVE O DADO NO DISPLAY
          
		  INC    DPTR
          
		  SJMP   MSTRINGX

MSTR21:   RET

//////////////////////////////////////////////////////
// NOME: ESC_STR1									//
// DESCRICAO: ROTINA QUE ESCREVE UMA STRING NO		//
// DISPLAY A PARTIR DO INICIO DA PRIMEIRA LINHA		//
// ENTRADA: DPTR = ENDERECO INICIAL DA STRING NA	//
// MEMORIA ROM FINALIZADA POR 00H					//
// SAIDA: -											//
// DESTROI: R0,A,DPTR								//
//////////////////////////////////////////////////////
ESC_STR1: 
		  // PRIMEIRA LINHA E PRIMEIRA COLUNA
		  MOV    R0,#00         
          MOV    R1,#00
          
		  JMP    ESC_S
          
//////////////////////////////////////////////////////
// NOME: ESC_STR2									//
// DESCRICAO: ROTINA QUE ESCREVE UMA STRING NO		//
// DISPLAY A PARTIR DO INICIO DA SEGUNDA LINHA		//
// ENTRADA: DPTR = ENDERECO INICIAL DA STRING NA	//
// MEMORIA ROM FINALIZADA POR 00H					//
// SAIDA: -											//
// DESTROI: R0,A,DPTR								//
//////////////////////////////////////////////////////
ESC_STR2: 
		  // SEGUNDA LINHA E PRIMEIRA COLUNA
		  MOV    R0,#01         
          MOV    R1,#00
		  
ESC_S:    LCALL  GOTOXY         // POSICIONA O CURSOR
          
		  LCALL  MSTRING
          
		  RET

//////////////////////////////////////////////////////
// NOME: CUR_ON E CUR_OFF							//
// DESCRICAO: ROTINA CUR_ON => LIGA CURSOR DO LCD	//
//        ROTINA CUR_OFF => DESLIGA CURSOR DO LCD	//
// ENTRADA: -										//
// SAIDA: -											//
; DESTROI: R0,R2									//
//////////////////////////////////////////////////////
CUR_ON:   
		  MOV    R0,#0FH              // INST.CONTROLE ATIVO (CUR ON)
          SJMP   CUR1
		  
CUR_OFF:  
		  MOV    R0,#0CH              // INST. CONTROLE INATIVO (CUR OFF)
		  
CUR1:     MOV    R2,#01
	  
		  CALL   ESCINST              // ENVIA A INSTRUCAO
          
		  RET
		  
////////////////////////////////////////////////
// 	     CODIGOS RELACIONADOS AO TIMER		  //
////////////////////////////////////////////////
		  
TIMER_CONFIGURA_TIMER:
		MOV 	TMOD, #00100001b // Seta o TIMER_0 para o modo 01 (16 bits) e o TIMER_1 para o modo 02 (8 bits com reset)
		
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 20ms
		MOV 	TH0, #HIGH(65535 - 43350)
		MOV 	TL0, #LOW(65535 - 43350)
		
		//////////////////////////////////////////////////
		// Aqui configuramos o TIMER_1 (para o TIMEOUT) //
		// 	  Interrupcao a ser chamada a cada 200 us	//
		//////////////////////////////////////////////////
		
		MOV 	TH1, #0FFh
		MOV		TL1, #05h
		
		RET

CONFIGURA_VALORES_TIMER_1:
		MOV		TIMEOUT_LOW, 	#0FFh
		MOV		TIMEOUT_HIGH, 	#01Eh
		MOV		TIMEOUT_X1S, 	#014h	
		
		RET
	
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_20_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 20 MS			//
// P.ENTRADA: R0 => (R0 x 20) ms  					//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_DELAY_20_MS:
		CLR TF0
		SETB TR0
	
		JNB TF0, $
		
		CLR TF0
		CLR TR0
	
		DJNZ R0, TIMER_DELAY_20_MS
	
		RET
	
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_1_S							//
// DESCRICAO: INTRODUZ UM ATRASO DE 1 S				//
// P.ENTRADA: R1 = y => (y x 1) s 	 				//
// P.SAIDA: -										//
// ALTERA: R1										//
//////////////////////////////////////////////////////
TIMER_DELAY_1_S:
		MOV		R0, #50d
		CALL 	TIMER_DELAY_20_MS
		
		DJNZ	R1, TIMER_DELAY_1_S
	
		RET

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

INT_CONFIGURA_INTERRUPCOES:
		MOV		IE, #10001000b // Configura interrupcao apenas para o TIMER_1
		MOV		IP,	#00001000b // da prioridade alta para o TIMER_1
		
		RET

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
* Para podermos utilizar valores elevados para nosso TIMEOUT, decidimos 
* utilizar até 3 bytes (TIMEOUT_LOW, TIMEOUT_HIGH, TIMEOUT_X1S) para definir
* o tempo do nosso TIMEOUT
*
* Mantendo TIMEOUT_LOW em 0xFF e TIMEOUT_HIGH em 0x1E, juntamente com os 200 us
* que a interrupcao e chamada, temos aproximadamente 1 s.
* Desta forma, basta configurar o TIMEOUT_X1S para a quantidade de segundos desejado
* Da forma como esta configurado, e possivel configurar o sistema para trabalhar com
* um TIMEOUT de ate 255 s ( ~4.25 min)
*/
INT_TIMER1:
		PUSH 	ACC
		PUSH	PSW
		
		MOV		TL1, #05h
		CLR		TF1
		
		DJNZ	TIMEOUT_LOW, FINALIZA_TIMER_2
		MOV		TIMEOUT_LOW, #0FFh
		
		DJNZ	TIMEOUT_HIGH, FINALIZA_TIMER_2
		MOV		TIMEOUT_HIGH, #01Eh
		
		DJNZ	TIMEOUT_X1S, FINALIZA_TIMER_2
		MOV		TIMEOUT_X1S, #014h	
		
		CLR		TR1

FINALIZA_TIMER_2:
		POP		PSW
		POP		ACC
		
		RETI
	
/*
*
*/
INT_SERIAL:
		RETI
	
FIM:
		JMP $
		END