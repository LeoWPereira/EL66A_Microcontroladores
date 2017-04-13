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
BUZZER				EQU P3.0
	
SENSOR_EXTERNO_1	EQU P3.2 // Bit do PORT P3 reservado para a INT0
SENSOR_EXTERNO_2	EQU P3.3 // Bit do PORT P3 reservado para a INT1

// LEDS DA PLACA
LED_SEG 			EQU	P3.6
LED1   				EQU	P3.7
	
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

//////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			    //
//////////////////////////////////////////////////

__STARTUP__:
		LCALL	TIMER_CONFIGURA_TIMER
		LCALL	INT_CONFIGURA_INTERRUPCOES
		
		LJMP	FIM

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
		MOV 	TMOD, #00000001b // Seta o TIMER_0 para o modo 01 (16 bits)
		
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 20ms
		MOV 	TH0, #HIGH(65535 - 43350)
		MOV 	TL0, #LOW(65535 - 43350)
				
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
		
		// Bits da palavra IP - Interrupt Priority
		SETB	PX0		// Alta prioridade para o SENSOR_EXTERNO_1
		SETB	PX1		// Alta prioridade para o SENSOR_EXTERNO_2
		
		// Bits da palavra TCON - Timer Control
		SETB	IE0		// Interrupcao para Borda
		SETB	IE1		// Interrupcao para Borda
		
		RET

//////////////////////////////////////////////////////
// NOME: INT_EXT0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_EXT0:
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
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER1:
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