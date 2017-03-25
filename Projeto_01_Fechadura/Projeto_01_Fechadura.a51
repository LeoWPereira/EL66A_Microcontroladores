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

// PARA PLACA USB VERMELHA 1SEM2013
RS			EQU	P2.5			// COMANDO RS LCD
E_LCD		EQU	P2.7			// COMANDO E (ENABLE) LCD
RW			EQU	P2.6			// READ/WRITE
BUSYF		EQU	P0.7			// BUSY FLAG

// LEDS DA PLACA
LED1   		EQU	P3.7
LED_SEG 	EQU	P3.6
	
// LINHAS E COLUNAS DO TECLADO MATRICIAL
COL1 		EQU P3.0
COL2 		EQU P3.1
COL3		EQU P3.2
COL4 		EQU P3.3

LIN1 		EQU P3.4
LIN2		EQU P3.5
LIN3 		EQU P3.6
LIN4 		EQU P3.7
	
// ENDERE�OS DOS D�GITOS DOS DADOS DE ENTRADA
TECLADO_1	EQU 31h
TECLADO_2	EQU 32h
TECLADO_3	EQU 33h
TECLADO_4	EQU 34h
	
// CONTADOR DO TIMER
COUNTER		EQU 37h

// ENDERE�OS DOS D�GITOS DE CADA SENHA
SENHA1_1	EQU 41h
SENHA1_2	EQU 42h
SENHA1_3	EQU 43h
SENHA1_4	EQU 44h

SENHA2_1	EQU 45h
SENHA2_2	EQU 46h
SENHA2_3	EQU 47h
SENHA2_4	EQU 48h

TENTATIVAS  EQU 49h
ASTERISCO   EQU 50h
		
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
STR_ENTER:
        DB      'PRESSIONE  ENTER',00H
STR_SENHA:
        DB      'SENHA: ',00H
STR_LIBERA:
        DB      ' PORTA LIBERADA ',00H
STR_TRANCA:
        DB      ' PORTA TRANCADA ',00H		

STR_ERRO:
        DB      'SENHA NECESSARIA',00H
		
////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			  //
////////////////////////////////////////////////		

__STARTUP__:
	mov DPTR, #2030h  	// inicializa o DPTR com o endereco da senha 01
	mov R0, #00h 	    // R0 representa o caracter atual do texto a ser lido
	mov R1, #SENHA1_1 	// R1 possui o endereco do registrador do primeiro numero da senha 01
	mov R2, #04h	  	// quantidade de digitos da senha 01
	CALL LE_SENHA
	
	mov DPTR, #2035h	// inicializa o DPTR com o endereco da senha 02
	mov R0, #00h 		// R0 representa o caracter atual do texto a ser lido
	mov R1, #SENHA2_1	// R1 possui o endereco do registrador do primeiro numero da senha 02
	mov R2, #04h		// quantidade de digitos da senha 02
	CALL LE_SENHA
	
	MOV TENTATIVAS, #3h
	MOV ASTERISCO, 	#2Ah
	
	// CALL TIMER_CONFIGURA_TIMER
	
// Foi feito um atraso pequeno antes da varredura de cada teclado para tratar o debounce de cada tecla
MAIN:
		CALL	INIDISP  
		MOV     DPTR,#STR_LOGO	// STRING DA PRIMEIRA LINHA
		CALL    ESC_STR1		// ESCREVE NA PRIMEIRA LINHA
		
		MOV 	R1, #08d
ATRASO_2_S:		
		MOV 	R2, 250d
		ACALL 	ATRASO_MS
		djnz 	R1, ATRASO_2_S
		
		CALL CLR1L
		
		MOV     DPTR,#STR_SENHA	// STRING DA PRIMEIRA LINHA
		CALL    ESC_STR1		// ESCREVE NA PRIMEIRA LINHA
		
		MOV 	R0, #00h 	// linha
		MOV 	R1, #07h	// coluna
		CALL 	GOTOXY
		
		MOV 	R1, #TECLADO_1
		MOV 	R3, #1h
		MOV 	R7, #04h
LE_4_DIGITOS:
		MOV 	R0, 100
		ACALL 	ATRASO_MS
		ACALL 	VARREDURA_TECLADO
		CALL 	ESCREVE_ASTERISCO
		
		INC R1
		INC R3
		
		DJNZ R7, LE_4_DIGITOS
		
		JMP	 	FIM
	
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
	
//////////////////////////////////////////////////////
// NOME: ESCREVE_ASTERISCO							//
// DESCRICAO: ROTINA QUE ESCREVE UM * NO LCD		//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
ESCREVE_ASTERISCO:		
	MOV 	A, ASTERISCO
	CALL 	ESCDADO
	
	RET

;Varredura de teclado para as senhas normais
VARREDURA_TECLADO:
		CLR  LIN1
		SETB LIN2
		SETB LIN3
		SETB LIN4
		JNB	 COL1, ESCREVE_ASTERISCO
		JNB  COL2, DIGITO1
		JNB  COL3, DIGITO2
		JNB  COL4, DIGITO3
		
		CLR  LIN2
		SETB LIN1
		JNB  COL2, DIGITO4
		JNB  COL3, DIGITO5
		JNB  COL4, DIGITO6
		
		CLR  LIN3
		SETB LIN2
		JNB  COL2, DIGITO7
		JNB  COL3, DIGITO8
		JNB  COL4, DIGITO9
		
		CLR  LIN4
		SETB LIN3
 		JNB  COL2, ESCREVE_ASTERISCO
		JNB  COL3, DIGITO0
		JMP  VARREDURA_TECLADO
		
		RET
		
;***************************************************************************
;NOME: DIGITO1
;DESCRICAO: Coloca o valor 1 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO1: MOV A, #1h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 
		 RET
;***************************************************************************
;NOME: DIGITO2
;DESCRICAO: Coloca o valor 2 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO2: MOV A, #2h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO3
;DESCRICAO: Coloca o valor 3 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO3: MOV A, #3h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO4
;DESCRICAO: Coloca o valor 4 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO4: MOV A, #4h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO5
;DESCRICAO: Coloca o valor 5 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO5: MOV A, #5h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO6
;DESCRICAO: Coloca o valor 6 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO6: MOV A, #6h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO7
;DESCRICAO: Coloca o valor 7 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO7: MOV A, #7h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO8
;DESCRICAO: Coloca o valor 8 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO8: MOV A, #8h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO9
;DESCRICAO: Coloca o valor 9 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO9: MOV A, #9h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
;***************************************************************************
;NOME: DIGITO0
;DESCRICAO: Coloca o valor 0 em R1 e grava no d�gito correspondente ao valor atual de R2
;ENTRADA:
;SAIDA:
;DESTROI: 
DIGITO0: MOV A, #0h
		 CJNE R3, #1h, GRAVA_TECLADO_2
		 MOV @R1, A
		 RET
		 
;***************************************************************************
;NOME: GRAVA_TECLADO_2
;DESCRICAO: Grava o valor de R1 e no d�gito 2 do teclado
;ENTRADA: R1
;SAIDA: TECLADO_2
;DESTROI: 
GRAVA_TECLADO_2: 
				 CJNE R3, #2h, GRAVA_TECLADO_3
				 MOV @R1, A
				 RET
;***************************************************************************
;NOME: GRAVA_TECLADO_3
;DESCRICAO: Grava o valor de R1 e no d�gito 3 do teclado
;ENTRADA: R1
;SAIDA: TECLADO_3
;DESTROI: 
GRAVA_TECLADO_3: CJNE R3, #3h, GRAVA_TECLADO_4
				 MOV @R1, A
				 RET		
;***************************************************************************
;NOME: GRAVA_TECLADO_4
;DESCRICAO: Grava o valor de R1 e no d�gito 4 do teclado
;ENTRADA: R1
;SAIDA: TECLADO_4
;DESTROI: 
GRAVA_TECLADO_4: MOV @R1, A
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
		CLR		RS				// RS = 0 (SELECIONA INSTRU��O)	
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
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
	RET
	
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_50_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 50 MS			//
// P.ENTRADA: R0 = y => (y x 50) ms  				//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_DELAY_50_MS:
	mov TH0, #HIGH(65535 - 49987)
	mov TL0, #LOW(65535 - 49987)
	
	clr TF0
	setb TR0
	
	jnb TF0, $
		
	clr TF0
	clr TR0
	
	djnz R0, TIMER_DELAY_50_MS
	
	RET
	
;***************************************************************************
;NOME: Atraso
;DESCRI��O: Introduz um atraso (delay) de T = (60 x R0 + 48)/fosc
;Para fosc =24MHz => R0=1 => T=4,5us a R0=0 => 0,642ms se R0= 199 => 0,5ms
;P. ENTRADA: R0 = Valor que multiplica por 60 na f�rmula (OBS.: R0 = 0 => 256)
;P. SAIDA: -
;Altera: R0
;***************************************************************************
Atraso:
	NOP			;12
	NOP			;12
	NOP			;12
	DJNZ		R0,Atraso	;24
	
	RET			;24


;***************************************************************************
;NOME: ATRASO_MS
;DESCRICAO: INTRODUZ UM ATRASO DE 1ms A 256ms
;P.ENTRADA: R2 = 1 => 1ms  A R2 = 0 => 256ms
;P.SAIDA: -
;ALTERA: R0,R2
ATRASO_MS:
	MOV		R0,#199		;VALOR PARA ATRASO DE 0,5ms
	CALL	Atraso
	MOV		R0,#199		;VALOR PARA ATRASO DE 0,5ms
	CALL	Atraso
	DJNZ	R2,ATRASO_MS
	
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
	
FIM:
	END