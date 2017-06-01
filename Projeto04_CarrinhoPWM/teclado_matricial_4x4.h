extern bit COL1;
extern bit COL2;
extern bit COL3;
extern bit COL4;

extern bit LIN1;
extern bit LIN2;
extern bit LIN3;
extern bit LIN4;

#define COMANDO_0			0x00
#define COMANDO_1			0x01
#define COMANDO_2			0x02
#define COMANDO_3			0x03
#define COMANDO_4			0x04
#define COMANDO_5			0x05
#define COMANDO_6			0x06
#define COMANDO_7			0x07
#define COMANDO_8			0x08
#define COMANDO_9			0x09
#define COMANDO_ENT		0x0A
#define COMANDO_CLR		0x0B
#define COMANDO_F1		0x0C
#define COMANDO_F2		0x0D
#define COMANDO_F3		0x0E
#define COMANDO_F4		0x0F

extern unsigned char COMANDO_TECLADO;

extern void VARREDURA_TECLADO(void);