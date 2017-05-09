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
	
// Serao utilizados para chamar as funcoes do i2c
B2W		EQU 0966h 	// bytes to write
B2R 	EQU 0967h 	// bytes to read
ADDR 	EQU 0968h 	// internal register address
DBASE 	EQU 0969h 	// endereco base dos dados a serem escritos
	
///////////////////////
// Bits endereçáveis //
///////////////////////
// Uma vez que o HW I2C executa "paralelo" ao 51 e o SW é totalmente composto de interrupções
// devemos evitar que uma comunicação se inicie antes de outra terminar
I2C_BUSY EQU 00h // 0 - I2C livre, 1 - I2C ocupada
	
