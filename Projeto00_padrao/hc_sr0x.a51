//////////////////////////////////////////////////////////
//														//
//  	CODIGOS RELACIONADOS AO SENSOR HC-SR0X			//
//														//
// Datasheet do componente e esquematico:				//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
// Necessario ter a biblioteca "timer.a51" como 		//
// dependencia do projeto em questao para funcionar		//
//														//
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
//////////////////////////////////////////////////
TRIGGER_ULTRASSOM_RECEPTOR	EQU P3.0
TRIGGER_ULTRASSOM_ENVIO		EQU P3.1

//////////////////////////////////////////////////////
// NOME: MEDIR_DISTANCIA							//
// DESCRICAO: 										//
// P.ENTRADA: R1 -> ponteiro para endereco de dist.	//
// P.SAIDA: 										//
// ALTERA: R1, A		  					 		//
//////////////////////////////////////////////////////
MEDIR_DISTANCIA:
		PUSH	ACC
		
		CLR 	TRIGGER_ULTRASSOM_RECEPTOR	// P3.0 configurado para enviar sinal de trigger
		SETB 	TRIGGER_ULTRASSOM_ENVIO     // P3.1 configurado para receber sinal de trigger

		MOV		R7, #00100000b	// seta timer 1 para o modo 02
		MOV		R6, #130d		// R6 = TH1
		MOV		R5, #130d		// R5 = TL1
		MOV		R4, #000h		// R4 = TH0
		MOV		R3, #000h		// R3 = TL0
		LCALL	TIMER_CONFIGURA_TIMER_SEM_INT

		MOV 	A, #00h
		
		SETB 	TRIGGER_ULTRASSOM_RECEPTOR	// inicia o pulso para o trigger
		
		LCALL 	TIMER_DELAY_10_US     // o trigger precisa de um pulso de 10 us para funcionar corretamente
		
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
	  
		POP		ACC
	  
		RET