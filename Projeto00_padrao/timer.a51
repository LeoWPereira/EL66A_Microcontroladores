//////////////////////////////////////////////////////////
//														//
//  		CODIGOS RELACIONADOS A TEMPORIZADORES  		//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: TIMER_CONFIGURA_TIMER_0_SEM_INT			//
// DESCRICAO: CONFIGURA O TIMER 0					//
// P.ENTRADA: R7 = > TMOD 	 						//
// P.SAIDA: -										//
// ALTERA: R7										//
//////////////////////////////////////////////////////
TIMER_CONFIGURA_TIMER_SEM_INT:
		MOV 	TMOD, R7 // Seta o TIMER_0 para o modo 01 (16 bits)
		
		ACALL	SETA_VALORES_TIMER_SEM_INT
		
		RET
		
//////////////////////////////////////////////////////
// NOME: SETA_VALORES_TIMER_0_SEM_INT				//
// DESCRICAO: CONFIGURA VALORES PARA CONTAR 1 MS	//
// P.ENTRADA: R6 => TH0								// 
//			  R5 =>	TL0								//
// P.SAIDA: -										//
// ALTERA: -										//
//////////////////////////////////////////////////////
SETA_VALORES_TIMER_SEM_INT:
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 1ms
		MOV 	TH0, R6
		MOV 	TL0, R5
		
		RET

//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_10_US							//
// DESCRICAO: INTRODUZ UM ATRASO DE 10 US			//
// P.ENTRADA: 										//
// P.SAIDA: -										//
// ALTERA: R6										//
//////////////////////////////////////////////////////
TIMER_DELAY_10_US: 
		MOV 	R6, #02d     
		DJNZ 	R6, $
		
		RET
		
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_1_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 1 MS			//
// P.ENTRADA: R0 => (R0 x 1) ms  					//
//			  R5 =>	TL0								//
//			  R6 => TL0								//
//			  R7 => TMOD							//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_DELAY_1_MS:
		// Para o TIMER_0, TH0 e TL0 representam o necessario para um delay de 1ms
		MOV		R7, #00000001b
		MOV 	R6, #HIGH(65535 - 1978)
		MOV 	R5, #LOW(65535 - 1978)
		ACALL	TIMER_CONFIGURA_TIMER_SEM_INT

CONTINUA_TIMER_1_MS:
		CLR 	TF0
		SETB 	TR0
	
		JNB 	TF0, $
			
		ACALL	SETA_VALORES_TIMER_SEM_INT
		
		CLR 	TF0
		CLR 	TR0
	
		DJNZ 	R0, CONTINUA_TIMER_1_MS
	
		RET

//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_200_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 200 MS			//
// P.ENTRADA: R1 => (R1 x 200) ms  					//
// P.SAIDA: -										//
// ALTERA: R1, R0									//
//////////////////////////////////////////////////////
TIMER_DELAY_200_MS:
		MOV		R0, #0C8h 

		ACALL 	TIMER_DELAY_1_MS
		
		DJNZ	R1, TIMER_DELAY_200_MS
	
		RET
	
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_1_S							//
// DESCRICAO: INTRODUZ UM ATRASO DE 1 S				//
// P.ENTRADA: R2 => (R2 x 1) s 	 					//
// P.SAIDA: -										//
// ALTERA: R2, R1, R0								//
//////////////////////////////////////////////////////
TIMER_DELAY_1_S:
		MOV		R1, #05h
		ACALL 	TIMER_DELAY_200_MS
		
		DJNZ	R2, TIMER_DELAY_1_S
	
		RET
		
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY								//
// DESCRICAO: INTRODUZ UM ATRASO DE ACORDO COM OS	//
// VALORES EM R0, R1 E R2, ESSES VALORES DEVEM SER	//
// NO RANGE [0, 255] E DEVEM SER PASSADOS ANTES DA	//
// CHAMADA											//
// P.ENTRADA: R0 => (R0 x 1) ms  					//
//			  R1 => (R1 x 200) ms					//
//			  R2 => (R2 x 1) s						//
// P.SAIDA: -										//
// ALTERA: R2, R1, R0								//
//////////////////////////////////////////////////////
TIMER_DELAY:
		PUSH 	ACC
		PUSH	B

		CJNE	R2, #00h, CHAMA_TIMER_1_S

VERIFICA_R1:
		CJNE	R1, #00h, CHAMA_TIMER_200_MS
		
VERIFICA_R0:
		CJNE	R0, #00h, CHAMA_TIMER_1_MS
		
		AJMP	FINALIZA_TIMER_DELAY
		
CHAMA_TIMER_1_MS:
		ACALL	TIMER_DELAY_1_MS
		AJMP	FINALIZA_TIMER_DELAY

CHAMA_TIMER_200_MS:
		MOV		A, R6
		MOV	  	A, R0
		
		ACALL	TIMER_DELAY_200_MS
		
		MOV		R0, A
		
		AJMP	VERIFICA_R0
		
CHAMA_TIMER_1_S:
		MOV	  	A, R0
		MOV		B, R1

		ACALL 	TIMER_DELAY_1_S
		
		MOV		R0, A
		MOV		R1, B
		
		AJMP	VERIFICA_R1

FINALIZA_TIMER_DELAY:
		POP		B
		POP 	ACC
		
		RET