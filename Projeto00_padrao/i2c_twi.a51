//////////////////////////////////////////////////////////
//														//
//    CODIGOS RELACIONADOS AO PROTOCOLO I2C POR TWI		//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG	0900h

// Bits do SSCON 
SSIE	EQU 0x40
STA		EQU 0x20
STO		EQU 0x10	
SI		EQU 0x08
AA 		EQU 0x04
	
// Pinos Usados I2C
I2C_SDA EQU P4.1
I2C_SCL EQU P4.0
	
