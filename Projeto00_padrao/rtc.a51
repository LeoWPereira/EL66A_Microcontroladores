//////////////////////////////////////////////////////////
//														//
//    			CODIGOS RELACIONADOS AO RTC				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0800h

// Endere�os de leitura e escrita do RTC
RADDR 	EQU 0xD1
WADDR 	EQU 0xD0
	
// Deve ser colocado na posi��o correta do JP5
RTC_SQW	EQU P2.1
	
