//LCD Functions Developed by electroSome

//LCD Module Connections
extern bit BUSYF;
extern bit RS;   
extern bit RW;
extern bit E_LCD;

extern bit D0;
extern bit D1;
extern bit D2;
extern bit D3;
extern bit D4;
extern bit D5;
extern bit D6;
extern bit D7;
//End LCD Module Connections 

extern void INIDISP(void);

extern void ESCINST(unsigned char instruction, unsigned char time_ms);

extern void GOTOXY(unsigned char linha, unsigned char coluna);

extern void CLR1L(void);

extern void CLR2L(void);

extern void ESCDADO(unsigned char charToWrite);

extern void MSTRING(unsigned char *stringToWrite, unsigned char tamanho_string);

extern void ESC_STR1(unsigned char *stringToWrite, unsigned char tamanho_string);

extern void ESC_STR2(unsigned char *stringToWrite, unsigned char tamanho_string);

extern void CUR_ON(void);

extern void CUR_OFF(void);

extern unsigned char CONV_NUMBER_TO_ASCII(unsigned char dataToConvert);

extern void ESC_DADO_NUMERO_COMPLETO(unsigned char numero, unsigned char tamanho_digitos);