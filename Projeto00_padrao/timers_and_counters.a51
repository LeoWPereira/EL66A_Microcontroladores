//////////////////////////////////////////////////////////
//														//
//  CODIGOS RELACIONADOS A TEMPORIXADORES / CONTADORES 	//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0F00h

TIMER_CONFIGURA_TIMER:
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
TIMER_DELAY_1_S:
	mov R0, #20d // 20 vezes
	
//////////////////////////////////////////////////////
// NOME: TIMER_DELAY_50_MS							//
// DESCRICAO: INTRODUZ UM ATRASO DE 50 MS			//
// P.ENTRADA: R0 = y => (y x 50) ms  				//
// P.SAIDA: -										//
// ALTERA: R0										//
//////////////////////////////////////////////////////
TIMER_DELAY_50_MS:
	mov TH0, #HIGH(65535 - 49987) 	// 0x3Ch
	mov TL0, #LOW(65535 - 49987)	// 0xBCh
	
	clr TF0
	setb TR0
	
	jnb TF0, $
		
	clr TF0
	clr TR0
	
	djnz R0, TIMER_DELAY_50_MS

//////////////////////////////////////////////////////
// NOME: ATRASO										//
// DESCRICAO: Introduz um atraso (delay) de			//
// T = (60 x R0 + 48)/fosc							//
// Para fosc =24MHz => R0=1 => T=4,5us a R0=0 =>	//
// 0,642ms se R0= 199 => 0,5ms						//
// ENTRADA: R0 = Valor que multiplica por 60 na		//
// formula (OBS.: R0 = 0 => 256)					//
// SAIDA: -											//
// ALTERA: R0										//
//////////////////////////////////////////////////////
ATRASO:
	NOP				// 12
	NOP				// 12
	NOP				// 12
	
	DJNZ R0,ATRASO	// 24
	
	RET				// 24

//////////////////////////////////////////////////////
// NOME: ATRASO_MS									//
// DESCRICAO: INTRODUZ UM ATRASO DE 1ms A 256ms		//
// ENTRADA: R2 = 1 => 1ms  A R2 = 0 => 256ms		//
// SAIDA: -											//
// ALTERA: R0,R2									//
//////////////////////////////////////////////////////
ATRASO_MS:
	MOV		R0,#199		// VALOR PARA ATRASO DE 0,5ms
	CALL	ATRASO
	
	MOV		R0,#199		// VALOR PARA ATRASO DE 0,5ms
	CALL	ATRASO
	
	DJNZ	R2,ATRASO_MS
	
	RET	