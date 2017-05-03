//////////////////////////////////////////////////////////////////////////////
//																			//
//           		PROJETO 02 - LOMBADA ELETRONICA 						//
//																			//
// Requisitos: 																//
// - mostre a velocidade em dois displays de sete segmentos vermelhos		//
// - A medida de velocidade e estruturada a partir de dois lacos			//
// indutivos, em uma distancia previamente conhecida						//
// - Cada laco indutivo consta de um conjunto de espiras, formando uma  	//
// indutancia conhecida. Cada laco indutivo consta de um conjunto de		//
// espiras, formando uma indutancia conhecida. Esta indutancia e a base 	//
// de um circuito oscilador com frequencia padrao (normalmente Colpitts)	//
// - Quando um veiculo passa, por ser metalico, ele perturba a indutancia,  //
// que automaticamente varia esta indutancia, e que varia a frequencia de 	//
// oscilacao.																//
// - O circuito microcontrolado deve capturar estas variabilidades de 		//
// frequencia e assim chavear o disparo da contagem de tempo referente a 	//
// passagem pelo primeiro laco ate o segundo.								//
// - Esta janela de tempo voce converte em velocidade e assim mostra.		//
// - O sistema devera, ainda, ter um alarme em forma de led e buzzer quando	//
// a velocidade ultrapassar os 40 km/h.										//
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

PINO_LED_VERMELHO			EQU P1.6
	
// BUZZER
BUZZER						EQU P1.7
	
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
	
DISTANCIA_SENSORES			EQU 37h	 // Distancia entre os dois sensores (em cm)

FLAG_MEDIR_DISTANCIA_INIT 	EQU 38h
FLAG_CALCULAR_VELOCIDADE	EQU 39h  // Se essa flag esta em 1 -> calcula a velocidade e mostra no display de 7 segmentos
	
// Velocidade em km/h
VELOCIDADE_VEICULO_UNIDADE	EQU	40h
VELOCIDADE_VEICULO_DEZENA	EQU	41h
VELOCIDADE_VEICULO			EQU 42h	

VELOCIDADE_LIMITE			EQU 43h	// em cm/ms (x36 = km / h)
	
TIMER_MEDICOES_LOW			EQU	44h

// Registradores disponibilizados para medir tempo com variacao de 1 ms
// Com esses 2 registradores (configurados na rotina INT_TIMER1) e possivel registrar um tempo de medicao de ate 65 s
TIMER_MEDICOES_LSB			EQU	45h
TIMER_MEDICOES_MSB			EQU	46h
	
DISTANCIA_ANTERIOR			EQU	47h
DISTANCIA_ATUAL				EQU	48h
	
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
		LCALL	TIMER_CONFIGURA_TIMER
		LCALL	INT_CONFIGURA_INTERRUPCOES
		LCALL	RESETA_TIMER_MEDICOES
		
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
		
		// Necessario reprogramar os timers e as interrupcoes devido ao calculo da distancia pelo sensor
		LCALL	TIMER_CONFIGURA_TIMER
		LCALL	INT_CONFIGURA_INTERRUPCOES
		LCALL	RESETA_TIMER_MEDICOES
		
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
		CLR		PINO_LED_VERMELHO
		CLR		BUZZER
		
		MOV		VELOCIDADE_LIMITE,			#010d	// velocidade limite de 40 km/h
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
		CLR		ET1

		MOV 	DPTR,#TAB7SEG          // moves the address of LUT to DPTR
		
		MOV 	P1,#00h      // sets P1 as output port
		MOV 	P0,#00h      // sets P0 as output port
		
		CLR 	P3.0               // sets P3.0 as output for sending trigger
		SETB 	P3.1              // sets P3.1 as input for receiving echo

		MOV 	TMOD,#00100000B    // sets timer1 as mode 2 auto reload timer
		MOV 	TL1,#130D    // loads the initial value to start counting from
		MOV 	TH1,#130D    // loads the reload value
		
		MOV 	A,#00h // clears accumulator
		
		SETB 	P3.0        // starts the trigger pulse
		
		ACALL 	DELAY1     // gives 10uS width for the trigger pulse
		
		CLR 	P3.0         // ends the trigger pulse

HERE: 	
		JNB 	P3.1,HERE    // loops here until echo is received
BACK: 	
		SETB 	TR1         // starts the timer1
HERE1: 
		JNB 	TF1,HERE1   // loops here until timer overflows (ie;48 count)
      
		CLR 	TR1          // stops the timer
		CLR 	TF1          // clears timer flag 1
      
		INC 	A            // increments A for every timer1 overflow
      
		JB 		P3.1,BACK     // jumps to BACK if echo is still available
      
		MOV 	@R1, A         // saves the value of A to R4
	  
		RET

/************************************/

DELAY1: 
		MOV 	R6,#2D     // 10uS delay
LABEL1: 
		DJNZ 	R6,LABEL1
	  
DELAY: MOV R7,#250D        // 1mS delay
LABEL2: DJNZ R7,LABEL2
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
		MOV 	R5,#100D    // loads R5 with 100D
		MOV		R6,#15D
BACK1: 
		MOV 	A,VELOCIDADE_VEICULO        // loads the value in R4 to A
		MOV 	B,#10D     // loads B with 100D
       
		DIV 	AB          // isolates the first digit
       
		SETB 	P1.1       // activates LED display unit D1
       ACALL MOSTRA_VELOCIDADE_DISPLAY   // calls DISPLAY subroutine
       ACALL DELAY     // 1mS delay
       ACALL DELAY
       
	   MOV A,B         // moves the remainder of 2nd division to A
       CLR P1.1        // deactivates LED display unit D2
       SETB P1.2       // activates LED display unit D3
       ACALL MOSTRA_VELOCIDADE_DISPLAY
       ACALL DELAY
       ACALL DELAY
       
	   CLR P1.2       // deactivates LED display unit D3
	   
	   DJNZ R6,BACK1
	   MOV	R6,#15h
       DJNZ R5,BACK1  // repeats the display loop 100 times
	   
	   // Soma a velocidade medida do veiculo com 215d
	   // Se essa soma setar o Carry, e porque a velocidade esta acima do limite
	   // Caso contrario, velocidade abaixo do limite
	   MOV		A, #0FFh
	   SUBB		A, VELOCIDADE_LIMITE
		
	   ADDC		A, VELOCIDADE_VEICULO
		
	   JC		ACIMA_DO_LIMITE
	   
       RET

ACIMA_DO_LIMITE:
		LCALL	VELOCIDADE_ACIMA_DO_LIMITE
		
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
		MOV		R0, #02h // quantidade de periodos
		MOV		R1, #128d // duty cycle (50%)
		
		// Considerando 20 ciclos de maquina para a interrupcao (20 x 0.375 us = 7.5 us)
		// 2666666 (0x28B0AA) estados em 32 MHz para frequencia de 1 Hz
		// 0x29 * 0xFF * 0xFF =~ 1Hz 
		MOV		R2, #029h
		MOV		R3, #0FFh
		MOV		R4, #0FFh
		MOV		R5, #00000101b // ativa o led vermelho e o buzzer, sinalizando que o veiculo passou em velocidade acima do limite
		
		LCALL	PWM_SQUARE_WAVE_SETUP_AND_START
		
		RET

//////////////////////////////////////////////////////
// NOME: MOSTRA_VELOCIDADE_DISPLAY					//
// DESCRICAO: 										//
// P.ENTRADA: A 					 				//
// P.SAIDA: 										//
// ALTERA: A  										//
//////////////////////////////////////////////////////
MOSTRA_VELOCIDADE_DISPLAY:
		MOV DPTR,#TAB7SEG          // moves the address of LUT to DPTR
		
		MOVC 	A,@A+DPTR   // gets the digit drive pattern for the content in A
        CPL 	A           // complements the digit drive pattern (see Note 1)
		MOV 	P0,A        // moves digit drive pattern for 1st digit to P0
		
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
		
//////////////////////////////////////////////////
//    INICIO DOS CODIGOS RELACIONADOS AO PWM	//
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE_SETUP_AND_START			//
// DESCRICAO: 										//
// P.ENTRADA: R0-> QUANTIDADE DE PERIODOS ATE PARAR	//
//			  R1-> DUTY CYCLE						//
//			  R2-> PWM_PERIODO_MSB					//
//			  R3-> PWM_PERIODO_MED					//
//			  R4-> PWM_PERIODO_LSB					//
//			  R5-> FLAG PARA PINOS A SEREM ATIVADOS //
//				bit 0 = PINO_LED_VERDE				//
//				bit 1 = PINO_LED_VERMELHO			//
//				bit 2 = PINO_LED_AMARELO			//
//				bit 3 = BUZZER						//
// P.SAIDA: 										//
// ALTERA: A										//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE_SETUP_AND_START:
		MOV 	PWM_DUTY_CYCLE, R1
	
		LCALL	PWM_SQUARE_WAVE_CONFIG_PERIOD
	
		SETB 	TR0

CONTINUA_PWM:
		LCALL	PWM_SQUARE_WAVE
		
		MOV 	A, PWM_COUNTER
		CJNE	A, PWM_QTDADE_PERIODOS, CONTINUA_PWM

PWM_PARAR:
		LCALL	PWM_STOP
		
		MOV		PWM_COUNTER, #00h
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE_CONFIG_PERIOD				//
// DESCRICAO: 										//
// P.ENTRADA: R0-> QUANTIDADE DE PERIODOS ATE PARAR //
//			  R2-> PWM_PERIODO_MSB					//
//			  R3-> PWM_PERIODO_MED					//
//			  R4-> PWM_PERIODO_LSB					//
// P.SAIDA: R6; R7 									//
// ALTERA: R6; R7 									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE_CONFIG_PERIOD:
		MOV		PWM_PERIODO_MSB, R2
		MOV		PWM_PERIODO_MED, R3
		MOV		PWM_PERIODO_LSB, R4
		
		// PWM_QTDADE_PERIODOS soma 2x R0 pois o PWM_COUNTER (que trabalha juntamente com esse outro registrador)
		// e incrementado toda vez que o PWM_PIN muda de estado
		MOV		A, R0
		ADD		A, R0
		MOV		PWM_QTDADE_PERIODOS, A
		
		MOV		R6, PWM_PERIODO_MED
		MOV		R7, PWM_PERIODO_MSB
		
		MOV 	TH0, #0FFh
		MOV		TL0, PWM_PERIODO_LSB
		
		RET

//////////////////////////////////////////////////////
// NOME: PWM_STOP									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
PWM_STOP:
		CLR 	TR0
		
		RET
	
//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE							//
// DESCRICAO: 										//
// P.ENTRADA: R6; R7					 	 		//
//			  R5-> FLAG PARA PINOS A SEREM ATIVADOS //
//				bit 0 = PINO_LED_VERDE				//
//				bit 1 = PINO_LED_VERMELHO			//
//				bit 2 = PINO_LED_AMARELO			//
//				bit 3 = BUZZER						//
// P.SAIDA: - 										//
// ALTERA: R6, R7									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE:	
		JNB 	TF0, $
	
		DJNZ	R6, CONTINUE_SQUARE
		MOV		R6, PWM_PERIODO_MED
		
		DJNZ	R7, CONTINUE_SQUARE
		MOV		R7, PWM_PERIODO_MSB	

		// Se chegou ate aqui, incrementa o contador do PWM (para sinalizar a quantidade de vezes que queremos chamar o PWM)
		INC		PWM_COUNTER

		JB		PWM_FLAG, HIGH_DONE
	
LOW_DONE:			
		SETB 	PWM_FLAG
		
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV		TH0, #0FFh
		MOV 	TL0, PWM_DUTY_CYCLE		
		
		CLR 	TF0
		
		RET
				
HIGH_DONE:
		CLR 	PWM_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
			
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE
		
		MOV 	TH0, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		CLR 	TF0					// Clear the Timer 1 interrupt flag
		
		RET

CONTINUE_SQUARE:
		JNB		PWM_FLAG, CONTINUE_SQUARE_LOW
	
CONTINUE_SQUARE_HIGH:
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE
		
		MOV 	TH0, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL0, A
		
		CLR 	TF0

		RET
		
CONTINUE_SQUARE_LOW:
		MOV		TH0, #0FFh
		MOV 	TL0, PWM_DUTY_CYCLE
		
		CLR 	TF0
		
		RET

//////////////////////////////////////////////////////
// NOME: DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS	//
// DESCRICAO: 										//
// P.ENTRADA: R5-> FLAG PARA PINOS					//
//				bit 0 = PINO_LED_VERMELHO			//
//				bit 1 = BUZZER						//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS:
		MOV		A, #01h
		ANL		A, R5
		JZ		NAO_ATIVA_BIT_0
		
		CPL 	PINO_LED_VERMELHO
		
NAO_ATIVA_BIT_0:
		MOV		A, #02h
		ANL		A, R5
		JZ		NAO_ATIVA_BIT_1
		
		CPL 	BUZZER

NAO_ATIVA_BIT_1:
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
		//SETB	EX1
		SETB	ET1
		
		// Bits da palavra IP - Interrupt Priority
		CLR		PX0		// Baixa prioridade para o SENSOR_EXTERNO_1
		//SETB	PX1		// Alta prioridade para o SENSOR_EXTERNO_2
		SETB	PT1		// Alta prioridade para o TIMER/COUNTER 1
		
		// Bits da palavra TCON - Timer Control
		CLR	IE0		// Interrupcao por Borda
		//SETB	IE1		// Interrupcao por Borda
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
		
		MOV 	R0, #05h 		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no teclado matricial
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
		/*PUSH 	ACC
		PUSH	PSW
		
		MOV 	R0, #05h 		// R0 x 20 ms de delay - para nao sentir o efeito de bounce no teclado matricial
		ACALL 	TIMER_DELAY_20_MS
		
		MOV		A, FLAG_PASSOU_PRIMEIRO_SENSOR
		JZ		FINALIZA_INT_EXT1	
		
		CLR		TR1
		
		MOV		FLAG_CALCULAR_VELOCIDADE, #01h
		
FINALIZA_INT_EXT1:
		POP		PSW
		POP		ACC*/
		
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