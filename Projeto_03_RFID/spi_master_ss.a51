//$INCLUDE   (reg_c51.INC)
SPCON EQU 0C3h
IEN1  EQU 0B1h
SPDAT EQU 0C5h
SPSTA EQu 0C4h

transmit_completed BIT 20H.1; software flag
serial_data DATA 08H
data_save DATA 09H
data_example DATA 0AH;

org 000h
ljmp begin

org 04Bh
ljmp it_SPI

;/**
; * FUNCTION_PURPOSE: This file set up spi in master mode with 
; * Fclk Periph/128 as baud rate and with slave select pin.
; * FUNCTION_INPUTS: P1.5(MISO) serial input
; * FUNCTION_OUTPUTS: P1.7(MOSI) serial output
; */
org 2100h
begin:

;init
MOV data_example,#55h;           /* data example */

ORL SPCON,#10h                  /* Master mode */
SETB P1.1;                       /* enable master */
ORL SPCON,#82h;                  /* Fclk Periph/128 */
ANL SPCON,#0F7h;                 /* CPOL=0; transmit mode example */
ORL SPCON,#04h;                  /* CPHA=1; transmit mode example */
ORL IEN1,#04h;                   /* enable spi interrupt */
ORL SPCON,#40h;                  /* run spi */
CLR transmit_completed;          /* clear software transfert flag */
SETB EA;                         /* enable interrupts */

loop:                            /* endless */

   MOV SPDAT,data_example;       /* send an example data */
   JNB transmit_completed,$;     /* wait end of transmition */
   CLR transmit_completed;       /* clear software transfert flag */

   MOV SPDAT,#00h;               /* data is send to generate SCK signal */
   JNB transmit_completed,$;     /* wait end of transmition */
   CLR transmit_completed;       /* clear software transfert flag */
   MOV data_save,serial_data;    /* save receive data */  

LJMP loop


;/**
; * FUNCTION_PURPOSE:interrupt
; * FUNCTION_INPUTS: void
; * FUNCTION_OUTPUTS: transmit_complete is software transfert flag
; */
it_SPI:;                         /* interrupt address is 0x004B */

MOV R7,SPSTA;
MOV ACC,R7
JNB ACC.7,break1;case 0x80:
    MOV serial_data,SPDAT;       /* read receive data */
    SETB transmit_completed;     /* set software flag */
break1:

JNB ACC.4,break2;case 0x10:
;         /* put here for mode fault tasking */	
break2:;
	
JNB ACC.6,break3;case 0x40:
;         /* put here for overrun tasking */	
break3:;

RETI

end
