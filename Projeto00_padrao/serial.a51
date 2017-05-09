//////////////////////////////////////////////////////////
//														//
//    		CODIGOS RELACIONADOS AO SERIAL				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0700h
	
//////////////////////////////////////////////////////
// Nome:											//
// Descrição:										//
// Parâmetros: R0 -> PCON				 			//
//			   #10000000b para serial no modo 1		//
//			   R1 -> SCON							//
//			   #01010000b para habilitar SM1 		//
//			   (coloca o serial para seguir TIMER1)	//	
// Retorna:											//
// Destrói:											//
//////////////////////////////////////////////////////
CONFIGURA_SERIAL:
		MOV 	PCON, R0
		MOV 	SCON, R1
		
		CLR		RI
		CLR		TI

		RET
	
//////////////////////////////////////////////////////
// Nome:											//
// Descrição:										//
// Parâmetros: R0 -> TMOD							//
//			   #00100000b para Timer 1 no modo 1	//
//			   R1 -> Baud Rate				 		//
//             para o AT89C5131A, 9600 = #243h		//
// Retorna:											//
// Destrói:											//
//////////////////////////////////////////////////////
CONFIGURA_BAUD_RATE:
		MOV 	TMOD, R0 // Timer 1 no modo 2
		MOV 	TH1, R0  // seta timer1 para baud rate desejado 
		
		SETB 	TR1

		RET
		
//////////////////////////////////////////////////////
// Nome:											//
// Descrição: 										//
// Parâmetros: 				 						//
// Retorna:											//
// Destrói: 										//
//////////////////////////////////////////////////////
RECEBE_DADO:
		JNB		RI, $
		
		CLR		RI
		
		MOV		A, SBUF

		RET
	
ENVIA_DADO:
		MOV		SBUF, A
		
		JNB		TI, $
		
		CLR		TI
		
		RET

ENVIA_OK:
		CLR 	TI
		
		MOV 	A, #'O'
		MOV		SBUF, A
		
		JNB		TI, $
		
		CLR		TI	
		
		MOV 	A, #'K'
		MOV 	SBUF, A
		
		JNB 	TI, $
		
		CLR		TI
		
		RET