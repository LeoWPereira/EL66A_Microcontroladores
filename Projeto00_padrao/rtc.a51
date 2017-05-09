//////////////////////////////////////////////////////////
//														//
//    			CODIGOS RELACIONADOS AO RTC				//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0800h

// Endereços de leitura e escrita do RTC
RADDR 	EQU 0xD1
WADDR 	EQU 0xD0
	
// Deve ser colocado na posição correta do JP5
RTC_SQW	EQU P2.1
	
// Serao utilizados para setar e pegar a data/hora do RTC
SEC 	EQU 0850h
MIN 	EQU 0851h
HOU 	EQU 0852h
DAY 	EQU 0853h
DAT 	EQU 0854h
MON 	EQU 0855h
YEA 	EQU 0856h
CTR 	EQU 0857h
LSB		EQU	0858h
MSB		EQU 0859h
	
