//////////////////////////////////////////////////////////
//														//
//  		CODIGOS RELACIONADOS A BUZZERS		  		//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG		0500h

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
//////////////////////////////////////////////////

BUZZER			EQU P3.1	

//////////////////////////////////////////////////////
// NOME: ACIONA_BUZZER								//
// DESCRICAO: ACIONA O BUZZER DE ACORDO COM OS		//
// VALORES EM R0, R1 E R2, ESSES VALORES DEVEM SER	//
// NO RANGE [0, 255] E DEVEM SER PASSADOS ANTES DA	//
// CHAMADA											//
// P.ENTRADA: R0 => (R0 x 1) ms  					//
//			  R1 => (R1 x 200) ms					//
//			  R2 => (R2 x 1) s						//
// P.SAIDA: -										//
// ALTERA: R2, R1, R0								//
//////////////////////////////////////////////////////
ACIONA_BUZZER:
		SETB 	BUZZER
		LCALL 	TIMER_DELAY
		CLR 	BUZZER
		
		RET