//////////////////////////////////////////////////////////
//														//
//  	CODIGOS RELACIONADOS AO MOTOR DE PASSOS			//
//														//
// Driver Necessario para poder utiliza-lo:	XXXXX		//
// Datasheet do componente e esquematico:				//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

// ESTADOS DO MOTOR DE PASSO
ESTADO_UM 		EQU P3.1
ESTADO_DOIS 	EQU P3.2
ESTADO_TRES 	EQU P3.3
ESTADO_QUATRO 	EQU P3.4

//////////////////////////////////////////////////////
// NOME: INICIA_MOTOR_DE_PASSOS						//
// DESCRICAO: INICIA O MOTOR DE PASSOS COM TEMPOS	//
// PRE DEFINIDOS									//
// ENTRADA: R0 => DELAY (R0 * 1 MS)					//
//          R1 => DELAY (R1 * 200 MS)				//
//			R2 => DELAY (R2 * 1 S)					//
//			R3 => QTDADE CHAMADAS PARA A FUNCAO		//
// SAIDA: -											//
// DESTROI: 										//
//////////////////////////////////////////////////////
INICIA_MOTOR_DE_PASSOS:
		SETB	ESTADO_UM
		CLR		ESTADO_DOIS
		CLR		ESTADO_TRES
		CLR		ESTADO_QUATRO
		
		ACALL 	TIMER_DELAY
		
		CLR		ESTADO_UM
		SETB	ESTADO_DOIS
		
		ACALL 	TIMER_DELAY
		
		CLR		ESTADO_DOIS
		SETB	ESTADO_TRES
		
		ACALL 	TIMER_DELAY
		
		CLR		ESTADO_TRES
		SETB	ESTADO_QUATRO
		
		ACALL 	TIMER_DELAY
		
		DJNZ 	R3, INICIA_MOTOR_DE_PASSOS
		
		RET

//////////////////////////////////////////////////////
// NOME: RETORNA_MOTOR_DE_PASSOS					//
// DESCRICAO: RETORNA O MOTOR DE PASSOS COM TEMPOS	//
// PRE DEFINIDOS									//
// ENTRADA: R0 => DELAY (R0 * 1 MS)					//
//          R1 => DELAY (R1 * 200 MS)				//
//			R2 => DELAY (R2 * 1 S)					//
//			R3 => QTDADE CHAMADAS PARA A FUNCAO		//
// SAIDA: -											//
// DESTROI: 										//
//////////////////////////////////////////////////////
RETORNA_MOTOR_DE_PASSOS:
		CLR		ESTADO_UM
		CLR		ESTADO_DOIS
		CLR		ESTADO_TRES
		SETB	ESTADO_QUATRO
		
		ACALL 	TIMER_DELAY
		
		SETB	ESTADO_TRES
		CLR		ESTADO_QUATRO
		
		ACALL 	TIMER_DELAY
		
		SETB	ESTADO_DOIS
		CLR		ESTADO_TRES
		
		ACALL 	TIMER_DELAY
		
		SETB	ESTADO_UM
		CLR		ESTADO_DOIS
		
		ACALL 	TIMER_DELAY
		
		DJNZ 	R3, RETORNA_MOTOR_DE_PASSOS

		RET

//////////////////////////////////////////////////////
// NOME: PRESS_ENT									//
// DESCRICAO: ESPERA PRESSIONAR ENTER				//
// ENTRADA: -										//
// SAIDA: -											//
// DESTROI: A										//
//////////////////////////////////////////////////////
