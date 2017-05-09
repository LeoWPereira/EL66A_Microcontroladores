//////////////////////////////////////////////////////////
//														//
//    		CODIGOS RELACIONADOS AO SERIAL				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////
	
//////////////////////////////////////////////////////
// Nome: CONFIGURA_SERIAL							//
// Descricao:										//
// Parametros: R0 -> PCON				 			//
//			   #10000000b para serial no modo 1		//
//			   R1 -> SCON							//
//			   #01010000b para habilitar SM1 		//
//			   (coloca o serial para seguir TIMER1)	//	
// Retorna:											//
// Destroi:	R0,	R1									//
//////////////////////////////////////////////////////
CONFIGURA_SERIAL:
		MOV 	PCON, R0
		MOV 	SCON, R1
		
		CLR		RI
		CLR		TI

		RET
	
//////////////////////////////////////////////////////
// Nome: CONFIGURA_BAUD_RATE						//
// Descricao:										//
// Parametros: R0 -> TMOD							//
//			   #00100000b para Timer 1 no modo 1	//
//			   R1 -> Baud Rate				 		//
//             para o AT89C5131A, 9600 = #243h		//
// Retorna:											//
// Destroi: R0, R1									//
//////////////////////////////////////////////////////
CONFIGURA_BAUD_RATE:
		MOV 	TMOD, R0 // Timer 1 no modo 2
		MOV 	TH1, R0  // seta timer1 para baud rate desejado 
		
		SETB 	TR1

		RET
		
//////////////////////////////////////////////////////
// Nome: RECEBE_DADO								//
// Descricao: 										//
// Parametros: 				 						//
// Retorna:	A -> dado recebido						//
// Destroi: A										//
//////////////////////////////////////////////////////
RECEBE_DADO:
		JNB		RI, $
		
		CLR		RI
		
		MOV		A, SBUF

		RET

//////////////////////////////////////////////////////
// Nome: ENVIA_DADO									//
// Descricao: 										//
// Parametros: A -> dado a ser enviado				//
// Retorna:											//
// Destroi: A 										//
//////////////////////////////////////////////////////
ENVIA_DADO:
		MOV		SBUF, A
		
		JNB		TI, $
		
		CLR		TI
		
		RET

//////////////////////////////////////////////////////
// Nome: ENVIA_OK									//
// Descricao: 										//
// Parametros: 				 						//
// Retorna:											//
// Destroi: 										//
//////////////////////////////////////////////////////
ENVIA_OK:
		PUSH	ACC

		CLR 	TI
		
		MOV 	A, #'O'
		MOV		SBUF, A
		
		JNB		TI, $
		
		CLR		TI	
		
		MOV 	A, #'K'
		MOV 	SBUF, A
		
		JNB 	TI, $
		
		CLR		TI
		
		POP		ACC
		
		RET