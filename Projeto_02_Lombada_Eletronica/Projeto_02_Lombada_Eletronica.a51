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
// a velocidade ultrapassar os 40 km/h.
// 																			//
// @author: Leonardo Winter Pereira 										//
// @author: Rodrigo Yudi Endo												//
//																			//
//////////////////////////////////////////////////////////////////////////////

org 00h//2000h // Origem do codigo 
ljmp __STARTUP__

org 03h//2003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_EXT0

org 0Bh//200Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 013h//2013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_EXT1

org 01Bh//201Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 023h//2023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

//////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		    //
//////////////////////////////////////////////////

// BUZZER
BUZZER						EQU P3.0
	
SENSOR_EXTERNO_1			EQU P3.2 // Bit do PORT P3 reservado para a INT0
SENSOR_EXTERNO_2			EQU P3.3 // Bit do PORT P3 reservado para a INT1

// LEDS DA PLACA
LED_SEG 					EQU	P3.6
LED1   						EQU	P3.7
	
DISTANCIA_SENSORES			EQU 31h	 // Distancia entre os dois sensores (em cm)

FLAG_CALCULAR_VELOCIDADE	EQU 32h  // Se essa flag esta em 1 -> calcula a velocidade e mostra no display de 7 segmentos
	
VELOCIDADE_VEICULO_UNIDADE	EQU	33h
VELOCIDADE_VEICULO_DEZENA	EQU	34h

// Registradores disponibilizados para medir tempo com variacao de 200 us (0.2 ms)
// Com esses 3 registradores (configurados na rotina INT_TIMER1) e possivel registrar um tempo de medicao de ate 255000 ms (255 s)
TIMER_MEDICOES_LOW			EQU	35h
TIMER_MEDICOES_HIGH			EQU	36h
TIMER_MEDICOES_X1S			EQU	37h
	
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

//////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			    //
//////////////////////////////////////////////////

__STARTUP__:
		LCALL	SETA_VARIAVEIS_INICIAIS
		LCALL	TIMER_CONFIGURA_TIMER
		LCALL	INT_CONFIGURA_INTERRUPCOES

INICIO:
		LCALL	RESETA_TIMER_MEDICOES
		
ESPERA_SENSOR_2:
		MOV		A, FLAG_CALCULAR_VELOCIDADE
		CJNE	A, #01h, ESPERA_SENSOR_2
		
		LCALL	CALCULA_VELOCIDADE
		
		LCALL	SETA_VARIAVEIS_INICIAIS
		AJMP	INICIO

//////////////////////////////////////////////////////
// NOME: SETA_VARIAVEIS_INICIAIS					//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: -										//
// ALTERA:  										//
//////////////////////////////////////////////////////
SETA_VARIAVEIS_INICIAIS:
		MOV		DISTANCIA_SENSORES, #100d  		// (distancia de 1m entre sensores)
		MOV		FLAG_CALCULAR_VELOCIDADE, #00h
		MOV		VELOCIDADE_VEICULO_UNIDADE, #00h
		MOV		VELOCIDADE_VEICULO_DEZENA, #00h
		
		RET
		
//////////////////////////////////////////////////////
// NOME: RESETA_TIMER_MEDICOES						//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: -										//
// ALTERA:  										//
//////////////////////////////////////////////////////
RESETA_TIMER_MEDICOES:
		MOV		TIMER_MEDICOES_LOW, #00h
		MOV		TIMER_MEDICOES_HIGH, #00h
		MOV		TIMER_MEDICOES_X1S, #00h
		
		RET

//////////////////////////////////////////////////////
// NOME: CALCULA_VELOCIDADE							//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: 										//
// ALTERA:  										//
//////////////////////////////////////////////////////
CALCULA_VELOCIDADE:
		
		RET	

//////////////////////////////////////////////////
// 	      CODIGOS RELACIONADOS AO BUZZER		//
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: ACIONA_BUZZER_X20MS						//
// DESCRICAO: ACIONA O BUZZER NA FAIXA [20,5100] MS	//
// P.ENTRADA: R0 -> R0 * 20 MS					 	//
// P.SAIDA: -										//
// ALTERA: R0 										//
//////////////////////////////////////////////////////
ACIONA_BUZZER_X20MS:
		SETB 	BUZZER
		ACALL 	TIMER_DELAY_20_MS
		CLR 	BUZZER
		
		RET
		
//////////////////////////////////////////////////////
// NOME: ACIONA_BUZZER_X1S							//
// DESCRICAO: ACIONA O BUZZER NA FAIXA [01,255] S	//
// P.ENTRADA: R1 -> R1 * 01 S					 	//
// P.SAIDA: -										//
// ALTERA: R1 										//
//////////////////////////////////////////////////////
ACIONA_BUZZER_X1S:
		SETB 	BUZZER
		ACALL 	TIMER_DELAY_1_S
		CLR 	BUZZER
		
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
		MOV 	TMOD, #00100001b // Seta o TIMER_0 para o modo 01 (16 bits) e o TIMER_1 para o modo 02 (8 bits com reset)
		
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 20ms
		MOV 	TH0, #HIGH(65535 - 43350)
		MOV 	TL0, #LOW(65535 - 43350)
		
		////////////////////////////////////////////////////
		// Aqui configuramos o TIMER_1 (para as medicoes) //
		// 	  Interrupcao a ser chamada a cada 200 us	  //
		////////////////////////////////////////////////////
		
		MOV 	TH1, #0FFh
		MOV		TL1, #05h
				
		RET

//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_20_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 20 MS			//
// P.ENTRADA: R0 => (R0 x 20) MS  					//
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
// P.ENTRADA: R1 => (R1 x 1) S 	 					//
// P.SAIDA: -										//
// ALTERA: R1										//
//////////////////////////////////////////////////////
TIMER_DELAY_1_S:
		MOV		R0, #50d
		CALL 	TIMER_DELAY_20_MS
		
		DJNZ	R1, TIMER_DELAY_1_S
	
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
		SETB	EX1
		SETB	ET1
		
		// Bits da palavra IP - Interrupt Priority
		SETB	PX0		// Alta prioridade para o SENSOR_EXTERNO_1
		SETB	PX1		// Alta prioridade para o SENSOR_EXTERNO_2
		CLR		PT1		// Baixa prioridade para o TIMER/COUNTER 1
		
		// Bits da palavra TCON - Timer Control
		SETB	IE0		// Interrupcao por Borda
		SETB	IE1		// Interrupcao por Borda
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
		
		SETB	TR1
		
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
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_EXT1:
		PUSH 	ACC
		PUSH	PSW
		
		CLR		TR1
		
		MOV		FLAG_CALCULAR_VELOCIDADE, #01h
		
		POP		PSW
		POP		ACC
		
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER1									//
// DESCRICAO: ESTA ROTINA SERA CHAMADA A CADA 200US //
// TODA VEZ QUE A INT_EXT0 FOR ACIONADA. PERMITE 	//
// CALCULAR O TEMPO GASTO PELO VEICULO PARA SAIR DO //
// PRIMEIRO SENSOR E ALCANCAR O SEGUNDO				//
// P.ENTRADA: -				 	 					//
// P.SAIDA: TIMER_MEDICOES_LOW; TIMER_MEDICOES_HIGH //
// ALTERA: TIMER_MEDICOES_LOW; TIMER_MEDICOES_HIGH	//
//////////////////////////////////////////////////////
INT_TIMER1:
		PUSH 	ACC
		PUSH	PSW
		
		MOV		TL1, #05h
		CLR		TF1
		
		MOV		A, TIMER_MEDICOES_LOW
		CJNE	A, #0FFh, INCREMENTA_TIMER_MEDICOES_LOW
	
		MOV		A, TIMER_MEDICOES_HIGH
		CJNE	A, #01Eh, INCREMENTA_TIMER_MEDICOES_HIGH
		
		MOV		TIMER_MEDICOES_LOW, #00h
		MOV		TIMER_MEDICOES_HIGH, #00h
		INC		TIMER_MEDICOES_X1S
		AJMP	FINALIZA_TIMER_1
	
INCREMENTA_TIMER_MEDICOES_LOW:
		INC		TIMER_MEDICOES_LOW
		AJMP	FINALIZA_TIMER_1
		
INCREMENTA_TIMER_MEDICOES_HIGH:
		MOV		TIMER_MEDICOES_LOW, #00h
		INC		TIMER_MEDICOES_HIGH

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