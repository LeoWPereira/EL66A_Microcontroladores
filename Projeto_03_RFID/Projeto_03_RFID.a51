//////////////////////////////////////////////////////////
//														//
//           		PROJETO 03 - RFID 					//
//														//
// Requisitos: 											//
// 														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
// http://www.circuitstoday.com/interfacing-rfid-module-to-8051
//////////////////////////////////////////////////////////

org 000h // Origem do codigo 
ljmp __STARTUP__

org 003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_INT0

org 00Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_INT1

org 01Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

org 204Bh
ljmp it_SPI

////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		  //
////////////////////////////////////////////////

// PARA PLACA USB VERMELHA
RS				EQU	P2.5			// COMANDO RS LCD
RW				EQU	P2.6			// READ/WRITE
E_LCD			EQU	P2.7			// COMANDO E (ENABLE) LCD
	
SPCON EQU 0C3h
IEN1  EQU 0B1h
SPDAT EQU 0C5h
SPSTA EQu 0C4h
	transmit_completed BIT 20H.1; software flag
serial_data DATA 08H
data_save DATA 09H
data_example DATA 0AH;

BUSYF			EQU	P0.7			// BUSY FLAG

// LEDS DA PLACA
LED_SEG 		EQU	P3.6
LED1   			EQU	P3.7
	
// BUZZER
BUZZER			EQU P3.0	
		
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

org 030h
TEXTO_1:
		db  	'  LEITOR  RFID  ', 00H
TEXTO_2:
		db  	' PASSE O CARTAO ', 00H
		
////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			  //
////////////////////////////////////////////////		

__STARTUP__:
		CALL 	TIMER_CONFIGURA_TIMER
		CALL 	INT_CONFIGURA_INTERRUPCOES
		
		SETB 	TR1                     // starts Timer1
		
MAIN:
		CALL	INIDISP  				// chama rotina de inicializacao do display 16x2
		MOV     DPTR,#TEXTO_1			// seta o DPTR com o endereco da string TEXTO_1
		CALL    ESC_STR1				// escreve na primeira linha do display
		
		// Atrasa 1s para escrever outra string
		MOV		R1, #01h
		CALL 	TIMER_DELAY_1_S
		
		MOV     DPTR,#TEXTO_2			// seta o DPTR com o endereco da string TEXTO_2
		CALL    ESC_STR2				// escreve na primeira linha do display
		
		// Atrasa 1s para escrever outra string
		MOV		R1, #01h
		CALL 	TIMER_DELAY_1_S
		
		ACALL 	CLR2L
	
		;init
MOV data_example,#55h;           /* data example */

ORL SPCON,#10h                  /* Master mode */
SETB P1.1;                       /* enable master */
ORL SPCON,#82h;                  /* Fclk Periph/128 */
ANL SPCON,#0F7h;                 /* CPOL=0; transmit mode example */
ORL SPCON,#04h;                  /* CPHA=1; transmit mode example */
ORL IEN1,#04h;                   /* enable spi interrupt */
ORL SPCON,#40h;                  /* run spi */
CLR transmit_completed;          /* clear software transfert flag */
SETB EA;                         /* enable interrupts */
jmp loop
		
		JMP	 	MAIN
		
loop:                            /* endless */

   MOV SPDAT,data_example;       /* send an example data */
   JNB transmit_completed,$;     /* wait end of transmition */
   CLR transmit_completed;       /* clear software transfert flag */

   MOV SPDAT,#00h;               /* data is send to generate SCK signal */
   JNB transmit_completed,$;     /* wait end of transmition */
   CLR transmit_completed;       /* clear software transfert flag */
   MOV data_save,serial_data;    /* save receive data */  

LJMP loop
		
READ:
		MOV 	R0,#12d             //loads R0 with 12D
		MOV 	R1,#160d            //loads R1 with 160D

WAIT:
		JNB 	RI, WAIT             //loops here until RI flag is set
		MOV 	A,	SBUF              //moves SBUF to A         
		MOV 	@R1, A               //moves A to location pointed by R1
		CLR 	RI                  //clears RI flag
		DJNZ 	R0, WAIT            //iterates the loop 12 times
     
		RET                     //return from subroutine

WRITE:
		MOV 	R2,#12d            //loads R2 with 12D
		MOV 	R1,#160d           //loads R1 with 160D

BACK1:
		MOV 	A,@R1              //loads A with data pointed by R1
		ACALL 	ESCDADO          //calls DISPLAY subroutine
		INC 	R1                 //incremets R1
		DJNZ 	R2,BACK1          //iterates the loop 160 times
      
		RET                    //return from subroutine
	   
///////////////////
// ACIONA BUZZER //
//  R0 x 20 MS 	 //
///////////////////
ACIONA_BUZZER:
		SETB 	BUZZER
		ACALL 	TIMER_DELAY_20_MS
		CLR 	BUZZER
		
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
		
		MOV 	TH1, #249d
		
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
		MOV		IE, 	#10001000b // Configura interrupcao apenas para o TIMER_1
		MOV		IP,		#00001000b // da prioridade alta para o TIMER_1
		
		MOV 	SCON,	#01010000b       // sets serial port to Mode1 and receiver enabled
		
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
*
*/
INT_TIMER1:
		RETI
	
/*
*
*/
INT_SERIAL:
		RETI
	
;/**
; * FUNCTION_PURPOSE:interrupt
; * FUNCTION_INPUTS: void
; * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
; */
it_SPI:;                         /* interrupt address is 0x004B */

MOV R7,SPSTA;
MOV ACC,R7
JNB ACC.7,break1;case 0x80:
    MOV serial_data,SPDAT;       /* read receive data */
	
	MOV A, serial_data
		ACALL 	ESCDADO          //calls DISPLAY subroutine
	
    SETB transmit_completed;     /* set software flag */
break1:

JNB ACC.4,break2;case 0x10:
;         /* put here for mode fault tasking */	
break2:;
	
JNB ACC.6,break3;case 0x40:
;         /* put here for overrun tasking */	
break3:;

RETI

FIM:
		JMP $
		END