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
// Descri��o:										//
// Par�metros: R0 -> PCON				 			//
//			   #10000000b para serial no modo 1		//
//			   R1 -> SCON							//
//			   #01010000b para habilitar SM1 		//
//			   (coloca o serial para seguir TIMER1)	//	
// Retorna:											//
// Destr�i:											//
//////////////////////////////////////////////////////
CONFIGURA_SERIAL:
		MOV 	PCON, R0
		MOV 	SCON, R1
		
		CLR		RI
		CLR		TI

		RET
	
//////////////////////////////////////////////////////
// Nome:											//
// Descri��o:										//
// Par�metros: R0 -> TMOD							//
//			   #00100000b para Timer 1 no modo 1	//
//			   R1 -> Baud Rate				 		//
//             para o AT89C5131A, 9600 = #243h		//
// Retorna:											//
// Destr�i:											//
//////////////////////////////////////////////////////
CONFIGURA_BAUD_RATE:
		MOV 	TMOD, R0 // Timer 1 no modo 2
		MOV 	TH1, R0  // seta timer1 para baud rate desejado 
		
		SETB 	TR1

		RET
		
//////////////////////////////////////////////////////
// Nome:											//
// Descri��o: 										//
// Par�metros: 				 						//
// Retorna:											//
// Destr�i: 										//
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