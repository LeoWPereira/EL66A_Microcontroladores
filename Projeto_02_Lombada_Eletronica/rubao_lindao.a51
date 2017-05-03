ORG 00H                // origin

MOV P1,#00000000B      // sets P1 as output port
MOV P0,#00000000B      // sets P0 as output port
CLR P3.0               // sets P3.0 as output for sending trigger
SETB P3.1              // sets P3.1 as input for receiving echo
MOV TMOD,#00100000B    // sets timer1 as mode 2 auto reload timer
MAIN: MOV TL1,#130D    // loads the initial value to start counting from
      MOV TH1,#130D    // loads the reload value
      MOV A,#00000000B // clears accumulator
      SETB P3.0        // starts the trigger pulse
      ACALL DELAY1     // gives 10uS width for the trigger pulse
      CLR P3.0         // ends the trigger pulse
HERE: JNB P3.1,HERE    // loops here until echo is received
BACK: SETB TR1         // starts the timer1
HERE1: JNB TF1,HERE1   // loops here until timer overflows (ie;48 count)
      CLR TR1          // stops the timer
      CLR TF1          // clears timer flag 1
      INC A            // increments A for every timer1 overflow
      JB P3.1,BACK     // jumps to BACK if echo is still available
      MOV R4,A         // saves the value of A to R4
      ACALL DLOOP      // calls the display loop
      SJMP MAIN        // jumps to MAIN loop

DELAY1: MOV R6,#2D     // 10uS delay
LABEL1: DJNZ R6,LABEL1
        RET     

DLOOP: MOV R5,#100D    // loads R5 with 100D
BACK1: MOV A,R4        // loads the value in R4 to A
       MOV B,#100D     // loads B with 100D
       DIV AB          // isolates the first digit
       SETB P1.0       // activates LED display unit D1
       ACALL MOSTRA_VELOCIDADE_DISPLAY   // calls DISPLAY subroutine
       ACALL DELAY     // 1mS delay
       ACALL DELAY
       MOV A,B         // moves the remainder of 1st division to A
       MOV B,#10D      // loads B with 10D
       DIV AB          // isolates the second digit
       CLR P1.0        // deactivates LED display unit D1
       SETB P1.1       // activates LED display unit D2
       ACALL MOSTRA_VELOCIDADE_DISPLAY
       ACALL DELAY
       ACALL DELAY
       MOV A,B         // moves the remainder of 2nd division to A
       CLR P1.1        // deactivates LED display unit D2
       SETB P1.2       // activates LED display unit D3
       ACALL MOSTRA_VELOCIDADE_DISPLAY
       ACALL DELAY
       ACALL DELAY
       CLR P1.2       // deactivates LED display unit D3
       DJNZ R5,BACK1  // repeats the display loop 100 times
       RET

DELAY: MOV R7,#250D        // 1mS delay
LABEL2: DJNZ R7,LABEL2
        RET

TAB7SEG:
	DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH
		 
//////////////////////////////////////////////////////
// NOME: MOSTRA_VELOCIDADE_DISPLAY					//
// DESCRICAO: 										//
// P.ENTRADA: 					 					//
// P.SAIDA: 										//
// ALTERA:  										//
//////////////////////////////////////////////////////
MOSTRA_VELOCIDADE_DISPLAY:
		MOV DPTR,#TAB7SEG          // moves the address of LUT to DPTR
		
		MOVC A,@A+DPTR   // gets the digit drive pattern for the content in A
        CPL A            // complements the digit drive pattern (see Note 1)
		MOV P0,A        // moves digit drive pattern for 1st digit to P0

		RET
END