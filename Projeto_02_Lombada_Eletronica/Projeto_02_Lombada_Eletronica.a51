//////////////////////////////////////////////////////////////////////////////
//																			//
//           		PROJETO 02 - LOMBADA ELETRONICA 						//
//																			//
// Requisitos: 																//
// - mostre a velocidade em dois displays de sete segmentos vermelhos		//
// - A medida de velocidade e estruturada a partir de um sensor 			//
// ultrassonico sr04														//
// - Esse sensor calcula a distancia entre ele e o obstaculo, permitindo	//
// assim calcular a velocidade												//
// - O sistema devera, ainda, ter um alarme em forma de led e buzzer quando	//
// a velocidade ultrapassar os XX cm / s.									//
// 																			//
// CONSIDERE QUE 1 ESTADO = 0.375 us										//
//																			//
// @author: Leonardo Winter Pereira 										//
// @author: Rodrigo Yudi Endo												//
//																			//
//////////////////////////////////////////////////////////////////////////////

org 000h // Origem do codigo 
ljmp __STARTUP__

org 003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_EXT0

org 00Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_EXT1

org 01Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

//////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		    //
//////////////////////////////////////////////////

PORT_DISPLAY				EQU	P0

DISPLAY_UNIDADE				EQU P1.0
DISPLAY_DEZENA				EQU P1.1

PINO_LED_VERMELHO			EQU P1.6
	
BUZZER						EQU P1.7
	
TRIGGER_ULTRASSOM_RECEPTOR	EQU P3.0
TRIGGER_ULTRASSOM_ENVIO		EQU P3.1
	
// LEDS DA PLACA
LED_SEG 					EQU	P3.6
LED1   						EQU	P3.7
	
PWM_FLAG 					EQU 0	// Flag para indicar se o sinal esta em HIGH ou em LOW

PWM_DUTY_CYCLE				EQU 31h // 00h = 0% duty cycle; FFh = 100% duty cycle

PWM_COUNTER					EQU 32h

// 3 bytes para o periodo do pwm: [0x000000, 0xFFFFFF] (16777215 us) Logo ... 1 Hz = 1000000 us = 0xF4240
PWM_PERIODO_LSB				EQU 33h
PWM_PERIODO_MED				EQU 34h	
PWM_PERIODO_MSB				EQU 35h
	
PWM_QTDADE_PERIODOS			EQU 36h
	
FLAG_MEDIR_DISTANCIA_INIT 	EQU 37h
FLAG_CALCULAR_VELOCIDADE	EQU 38h  // Se essa flag esta em 1 -> calcula a velocidade e mostra no display de 7 segmentos
	
// Velocidade em cm/s
VELOCIDADE_VEICULO_UNIDADE	EQU	39h
VELOCIDADE_VEICULO_DEZENA	EQU	40h
VELOCIDADE_VEICULO			EQU 41h	

VELOCIDADE_LIMITE			EQU 42h	// em cm/s
	
TIMER_MEDICOES_LOW			EQU	43h

// Registradores disponibilizados para medir tempo com variacao de 1 ms
// Com esses 2 registradores (configurados na rotina INT_TIMER1) e possivel registrar um tempo de medicao de ate 65 s
TIMER_MEDICOES_LSB			EQU	44h
TIMER_MEDICOES_MSB			EQU	45h
	
DISTANCIA_ANTERIOR			EQU	46h
DISTANCIA_ATUAL				EQU	47h
	
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

org 030h
TAB7SEG:
	DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 71H

//////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			    //
//////////////////////////////////////////////////

__STARTUP__:
		LCALL	SETA_VARIAVEIS_INICIAIS
		LCALL	INT_CONFIGURA_INTERRUPCOES
		
ESPERA_TRIGGER_CALCULAR_DISTANCIA_INIT:
		MOV		A, FLAG_MEDIR_DISTANCIA_INIT
		CJNE	A, #01h, ESPERA_TRIGGER_CALCULAR_DISTANCIA_INIT
		
		MOV		R1, #DISTANCIA_ANTERIOR
		LCALL	MEDIR_DISTANCIA
		
		// Necessario reprogramar os timers e as interrupcoes devido ao calculo da distancia pelo sensor
		LCALL	TIMER_CONFIGURA_TIMER
		LCALL	INT_CONFIGURA_INTERRUPCOES
		LCALL	RESETA_TIMER_MEDICOES
		
		SETB	TR1
		
ESPERA_FLAG_MEDIR_DISTANCIA_2:
		MOV		A, FLAG_CALCULAR_VELOCIDADE
		CJNE	A, #01h, ESPERA_FLAG_MEDIR_DISTANCIA_2
		
		MOV		R1, #DISTANCIA_ATUAL
		LCALL	MEDIR_DISTANCIA
		
		LCALL	CALCULA_VELOCIDADE
		
		AJMP	__STARTUP__

//////////////////////////////////////////////////////
// NOME: SETA_VARIAVEIS_INICIAIS					//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: -										//
// ALTERA:  										//
//////////////////////////////////////////////////////
SETA_VARIAVEIS_INICIAIS:
		SETB	PINO_LED_VERMELHO
		SETB	BUZZER
		
		MOV		VELOCIDADE_LIMITE,			#020d	// velocidade limite de 20 cm/s
		MOV		FLAG_MEDIR_DISTANCIA_INIT,	#00h 
		MOV		FLAG_CALCULAR_VELOCIDADE, 	#00h
		MOV		VELOCIDADE_VEICULO_UNIDADE, #00h
		MOV		VELOCIDADE_VEICULO_DEZENA, 	#00h
		MOV		DISTANCIA_ANTERIOR, 		#00h			
		MOV		DISTANCIA_ATUAL, 			#00h				
		
		RET
		
//////////////////////////////////////////////////////
// NOME: RESETA_TIMER_MEDICOES						//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: -										//
// ALTERA:  										//
//////////////////////////////////////////////////////
RESETA_TIMER_MEDICOES:
		MOV		TIMER_MEDICOES_LOW, 	#00h
		MOV		TIMER_MEDICOES_LSB, 	#00h
		MOV		TIMER_MEDICOES_MSB, 	#00h
		
		MOV		VELOCIDADE_VEICULO, 	#00h
		
		RET	
		
//////////////////////////////////////////////////////
// NOME: MEDIR_DISTANCIA							//
// DESCRICAO: 										//
// P.ENTRADA: R1 -> ponteiro para endereco de dist.	//
// P.SAIDA: 										//
// ALTERA: R1, A		  					 		//
//////////////////////////////////////////////////////
MEDIR_DISTANCIA:
		CLR		DISPLAY_UNIDADE 
		CLR 	DISPLAY_DEZENA
		
		MOV 	PORT_DISPLAY, #00h
		
		CLR 	TRIGGER_ULTRASSOM_RECEPTOR	// P3.0 configurado para enviar sinal de trigger
		SETB 	TRIGGER_ULTRASSOM_ENVIO     // P3.1 configurado para receber sinal de trigger

		MOV 	TMOD, #00100000B	// seta timer 1 para o modo 02
		MOV 	TL1, #130D    
		MOV 	TH1, #130D    
		
		MOV 	A, #00h
		
		SETB 	TRIGGER_ULTRASSOM_RECEPTOR	// inicia o pulso para o trigger
		
		ACALL 	TIMER_DELAY_10_US     // o trigger precisa de um pulso de 10 us para funcionar corretamente
		
		CLR 	TRIGGER_ULTRASSOM_RECEPTOR

ESPERANDO_RESPOSTA_ECHO: 	
		JNB 	TRIGGER_ULTRASSOM_ENVIO, $    // aguarda o recebimento do trigger (sinal de eco)

ECHO_AINDA_DISPONIVEL: 	
		SETB 	TR1         

		JNB 	TF1, $
      
		CLR 	TR1          
		CLR 	TF1          
      
		INC 	A	// o acumulador ira representar a distancia adquirida pelo sensor de ultrassom
      
		JB 		TRIGGER_ULTRASSOM_ENVIO, ECHO_AINDA_DISPONIVEL	// continua no loop enquanto ainda nao tiver recebido um echo como resposta
      
		MOV 	@R1, A	// armazena o valor (referente a distancia) no endereco apontado por R1
	  
		RET

//////////////////////////////////////////////////////
// NOME: CALCULA_VELOCIDADE							//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: 										//
// ALTERA: C, B  					 				//
//////////////////////////////////////////////////////
CALCULA_VELOCIDADE:
		CLR		C // para poder fazer a comparacao para ver se a velocidade e maior ou menor do que o limite permitido
		
		MOV 	A, DISTANCIA_ANTERIOR
		MOV		B, DISTANCIA_ATUAL
		
		SUBB	A, B

		JNC		DISTANCIA_ANTERIOR_MAIOR_QUE_ATUAL	
		
DISTANCIA_ATUAL_MAIOR_QUE_ANTERIOR:
		MOV 	A, DISTANCIA_ATUAL
		SUBB	A, DISTANCIA_ANTERIOR
		
		MOV		VELOCIDADE_VEICULO, A
		
		JMP		DLOOP

DISTANCIA_ANTERIOR_MAIOR_QUE_ATUAL:
		MOV 	A, DISTANCIA_ANTERIOR
		SUBB	A, DISTANCIA_ATUAL
		
		MOV		VELOCIDADE_VEICULO, A
		
DLOOP: 
	   // Soma a velocidade medida do veiculo com (0xFF - VELOCIDADE_LIMITE)
	   // Se essa soma setar o Carry, e porque a velocidade esta acima do limite
	   // Caso contrario, velocidade abaixo do limite
	   MOV		A, #0FFh
	   SUBB		A, VELOCIDADE_LIMITE
		
	   ADDC		A, VELOCIDADE_VEICULO
		
	   JC		ACIMA_DO_LIMITE

CONTINUA_DLOOP:
		MOV 	R5,#100D    // loads R5 with 100D
		MOV		R6,#15D
BACK1: 
		MOV 	A,VELOCIDADE_VEICULO        // loads the value in R4 to A
		MOV 	B,#10D     // loads B with 100D
       
		DIV 	AB          // isolates the first digit
       
		SETB 	DISPLAY_UNIDADE       // activates LED display unit D1
       ACALL MOSTRA_VELOCIDADE_DISPLAY   // calls DISPLAY subroutine
	   
	   ACALL 	TIMER_DELAY_1_MS     
       
	   MOV A,B         // moves the remainder of 2nd division to A
       CLR DISPLAY_UNIDADE        // deactivates LED display unit D2
       SETB DISPLAY_DEZENA       // activates LED display unit D3
       ACALL MOSTRA_VELOCIDADE_DISPLAY
       
	   ACALL 	TIMER_DELAY_1_MS 
       
	   CLR DISPLAY_DEZENA       // deactivates LED display unit D3
	   
	   DJNZ R6,BACK1
	   MOV	R6,#15h
       DJNZ R5,BACK1  // repeats the display loop 100 times
	   
	   SETB		PINO_LED_VERMELHO
	   SETB		BUZZER
	   
       RET

ACIMA_DO_LIMITE:
		LCALL	VELOCIDADE_ACIMA_DO_LIMITE
		
		JMP		CONTINUA_DLOOP
		
		RET	

//////////////////////////////////////////////////////
// NOME: VELOCIDADE_ACIMA_DO_LIMITE					//
// DESCRICAO: CHAMA PWM PARA FAZER O LED VEMELHO	//
// PISCAR DURANTE 2 S COM FREQUENCIA DE 1 HZ 		//
// P.ENTRADA: 					 					//
// P.SAIDA: 										//
// ALTERA:  										//
//////////////////////////////////////////////////////
VELOCIDADE_ACIMA_DO_LIMITE:
		CLR		PINO_LED_VERMELHO
		CLR		BUZZER

		RET

//////////////////////////////////////////////////////
// NOME: MOSTRA_VELOCIDADE_DISPLAY					//
// DESCRICAO: 										//
// P.ENTRADA: A 					 				//
// P.SAIDA: 										//
// ALTERA: A  										//
//////////////////////////////////////////////////////
MOSTRA_VELOCIDADE_DISPLAY:
		MOV 	DPTR, #TAB7SEG	// Move para o DPTR o endereco dos valores para o display de 7 segmentos
		
		MOVC 	A, @A + DPTR	// busca pelo valor referente ao digito a ser impresso
        CPL 	A           	// complementa o digito a ser impresso (necessario para que o display seja usado corretamente)
		MOV 	PORT_DISPLAY, A // Envia para o port do display
		
		RET

//////////////////////////////////////////////////
// 	      CODIGOS RELACIONADOS AO TIMER		    //
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: TIMER_CONFIGURA_TIMER						//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
TIMER_CONFIGURA_TIMER:
		MOV 	TMOD, #00100010b // Seta o TIMER_0 para o modo 02 (08 bits com reset) e o TIMER_1 para o modo 02 (8 bits com reset)
		
		ACALL	TIMER_SETA_VALORES_TIMER_PADRAO
		
		////////////////////////////////////////////////////////
		//    Aqui configuramos o TIMER_1 (para as medicoes)  //
		// 	     Interrupcao a ser chamada a cada 50 us	      //
		// 50 us = 133 instrucoes (onde 1 executa em 0.375us) //
		////////////////////////////////////////////////////////
		
		MOV 	TH1, #0FFh
		MOV		TL1, #122d
				
		RET
		
//////////////////////////////////////////////////////
// NOME: TIMER_SETA_VALORES_TIMER_PADRAO			//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
TIMER_SETA_VALORES_TIMER_PADRAO:
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 20ms
		// Se 1 estado executa em 0.375 us, precisamos de 53330 estados para executar 20ms
		MOV 	TH0, #207d
		MOV 	TL0, #207d
				
		RET
		
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_20_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 20 MS			//
// P.ENTRADA: R0 => (R0 x 20) ms  					//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_DELAY_20_MS:
		MOV 	TMOD, #00000001b // Seta o TIMER_0 para o modo 01 (16 bits) e o TIMER_1 para o modo 02 (8 bits com reset)
		
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 20ms
		MOV 	TH0, #HIGH(65535 - 43350)
		MOV 	TL0, #LOW(65535 - 43350)

		CLR 	TF0
		SETB 	TR0
	
		JNB 	TF0, $
		
		CLR 	TF0
		CLR 	TR0
	
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

//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_10_US							//
// DESCRICAO: INTRODUZ UM ATRASO DE 10 US			//
// P.ENTRADA: 										//
// P.SAIDA: -										//
// ALTERA: R6										//
//////////////////////////////////////////////////////
TIMER_DELAY_10_US: 
		MOV 	R6, #2D     
		DJNZ 	R6, $
		
		RET

//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_1_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 1 MS			//
// P.ENTRADA: 										//
// P.SAIDA: -										//
// ALTERA: R7										//
//////////////////////////////////////////////////////
TIMER_DELAY_1_MS: 
		MOV 	R7, #250d        
		DJNZ 	R7, $
        
		RET

//////////////////////////////////////////////////
//  INICIO DOS CODIGOS GERADOS POR INTERRUPCAO  //
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: INT_CONFIGURA_INTERRUPCOES					//
// DESCRICAO: CONFIGURA AS PALAVRAS IE, IP E PARTE	//
// 			  DO TCON								// 
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_CONFIGURA_INTERRUPCOES:
		// Bits da palavra IE - Interrupt Enable
		SETB	EA
		SETB	EX0
		SETB	ET1
		
		// Bits da palavra IP - Interrupt Priority
		CLR		PX0		// Baixa prioridade para o SENSOR_EXTERNO_1
		SETB	PT1		// Alta prioridade para o TIMER/COUNTER 1
		
		// Bits da palavra TCON - Timer Control
		CLR		IE0		// Interrupcao por Borda
		CLR		IT1		// Interrupcao por Nivel
		
		RET

//////////////////////////////////////////////////////
// NOME: INT_EXT0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_EXT0:
		PUSH 	ACC
		PUSH	PSW
		
		MOV		FLAG_MEDIR_DISTANCIA_INIT, #01h
		
		MOV 	R0, #05h 		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no trigger da "pistola"
		ACALL 	TIMER_DELAY_20_MS
		
		POP		PSW
		POP		ACC
		
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER0:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_EXT1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: A										//
//////////////////////////////////////////////////////
INT_EXT1:
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER1									//
// DESCRICAO: ESTA ROTINA SERA CHAMADA A CADA 200US //
// TODA VEZ QUE A INT_EXT0 FOR ACIONADA. PERMITE 	//
// CALCULAR O TEMPO GASTO PELO VEICULO PARA SAIR DO //
// PRIMEIRO SENSOR E ALCANCAR O SEGUNDO				//
// P.ENTRADA: -				 	 					//
// P.SAIDA: TIMER_MEDICOES_LOW; TIMER_MEDICOES_LSB  //
// ALTERA: TIMER_MEDICOES_LOW; TIMER_MEDICOES_LSB	//
//////////////////////////////////////////////////////
INT_TIMER1:
		PUSH 	ACC
		PUSH	PSW
		
		MOV		TL1, #122d
		CLR		TF1
		
		MOV		A, TIMER_MEDICOES_LOW
		CJNE	A, #020d, INCREMENTA_TIMER_MEDICOES_LOW      // neste ponto, o TIMER_MEDICAO_LSB passa a contar 1 ms em cada novo estado 
	
		MOV		A, TIMER_MEDICOES_LSB
		CJNE	A, #0250d, INCREMENTA_TIMER_MEDICOES_LSB	// neste ponto, o TIMER_MEDICAO_MSB passa a contar 250 ms em cada novo estado
		
		MOV		TIMER_MEDICOES_LOW, #00h
		MOV		TIMER_MEDICOES_LSB, #00h
		INC		TIMER_MEDICOES_MSB
		
		MOV		A, TIMER_MEDICOES_MSB
		CJNE	A, #02d, FINALIZA_TIMER_1	// neste ponto, o TIMER_MEDICAO_MSB passa a contar 250 ms em cada novo estado
		
		CLR		TR1
		MOV		FLAG_CALCULAR_VELOCIDADE, #01h
		AJMP	FINALIZA_TIMER_1
	
INCREMENTA_TIMER_MEDICOES_LOW:
		INC		TIMER_MEDICOES_LOW
		AJMP	FINALIZA_TIMER_1
		
INCREMENTA_TIMER_MEDICOES_LSB:
		MOV		TIMER_MEDICOES_LOW, #00h
		INC		TIMER_MEDICOES_LSB

FINALIZA_TIMER_1:
		POP		PSW
		POP		ACC
		
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_SERIAL									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_SERIAL:
		RETI
	
FIM:
		JMP $
		END