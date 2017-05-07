// PARA PLACA USB VERMELHA
RS				EQU	P2.7			// COMANDO RS LCD
RW				EQU	P2.6			// READ/WRITE
E_LCD			EQU	P2.5			// COMANDO E (ENABLE) LCD

BUSYF			EQU	P0.7			// BUSY FLAG

// LEDS DA PLACA
LED_SEG 		EQU	P3.6
LED1   			EQU	P3.7
	
ORG 000H                     //origin
	JMP __STARTUP__

__STARTUP__:
MOV TMOD,#00100001B          //Timer1=Mode2 timer & Timer0=Mode1 timer
MOV TH1,#253D                //loads TH1 with 253D(9600 baud)
MOV SCON,#50H                //sets serial port to Mode1 and receiver enabled
SETB TR1                     //starts Timer1

MAIN:ACALL DINT              //calls DINT subroutine
     ACALL TEXT1             //calls TEXT1 subroutine        
     ACALL LINE2             //calls LINE2 subroutine
     ACALL TEXT2             //calls TEXT2 subroutine
     ACALL READ              //calls READ subroutine
     CLR REN                 //disables serial data receive
     ACALL LINE2             //calls LINE2 subroutine
     ACALL WRITE             //calls WRITE subroutine
     ACALL DELAY1            //calls DELAY1 subroutine
     SETB REN                //enables serial data receive
     SJMP MAIN               //jumps back to MAIN label

DELAY1:MOV R3,#46D           //loads R3 with 46D
BACK:  MOV TH0,#00000000B    //loads TH0 with all 0's 
       MOV TL0,#00000000B    //loads TL0 with all 0's
       SETB TR0              //starts Timer 0            
HERE1: JNB TF0,HERE1         //loops here until TFO flag is 1     
       CLR TR0               //stops TR1      
       CLR TF0               //clears TF0 flag
       DJNZ R3,BACK          //iterates the loop 46 times for 3s delay
       RET                   //returns from subroutine

READ:MOV R0,#12D             //loads R0 with 12D
     MOV R1,#160D            //loads R1 with 160D
WAIT:JNB RI,WAIT             //loops here until RI flag is set
     MOV A,SBUF              //moves SBUF to A         
     MOV @R1,A               //moves A to location pointed by R1
     CLR RI                  //clears RI flag
     DJNZ R0,WAIT            //iterates the loop 12 times
     RET                     //return from subroutine

WRITE:MOV R2,#12D            //loads R2 with 12D
      MOV R1,#160D           //loads R1 with 160D
BACK1:MOV A,@R1              //loads A with data pointed by R1
      ACALL DISPLAY          //calls DISPLAY subroutine
      INC R1                 //incremets R1
      DJNZ R2,BACK1          //iterates the loop 160 times
      RET                    //return from subroutine
      

TEXT1: MOV A,#52H            //loads A with ascii of "R"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#46H               //loads A with ascii of "F"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#49H               //loads A with ascii of "I"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#44H               //loads A with ascii of "D"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#20H               //loads A with ascii of "space"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#52H               //loads A with ascii of "R"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#45H               //loads A with ascii of "E"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#41H               //loads A with ascii of "A"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#44H               //loads A with ascii of "D"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#45H               //loads A with ascii of "E"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#52H               //loads A with ascii of "R"
    ACALL DISPLAY            //calls DISPLAY subroutine
    RET                      //returns from subroutine
     
TEXT2: MOV A,#53H            //loads A with ascii of "S"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#77H               //loads A with ascii of "w"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#69H               //loads A with ascii of "i"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#70H               //loads A with ascii of "p"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#65H               //loads A with ascii of "e"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#20H               //loads A with ascii of "space"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#63H               //loads A with ascii of "c"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#61H               //loads A with ascii of "a"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#72H               //loads A with ascii of "r"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#64H               //loads A with ascii of "d"
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#2EH               //loads A with ascii of "."
    ACALL DISPLAY            //calls DISPLAY subroutine
    MOV A,#2EH               //loads A with ascii of "."
    ACALL DISPLAY            //calls DISPLAY subroutine
    RET                      //return from subroutine

DINT:MOV A,#0FH              //display ON cursor blinking ON           
    ACALL CMD                //calls CMD subroutine
    MOV A,#01H               //clear display screen
    ACALL CMD                //calls CMD subroutine
    MOV A,#06H               //increment cursor
    ACALL CMD                //calls CMD subroutine
    MOV A,#83H               //cursor line 1 position 3
    ACALL CMD                //calls CMD subroutine
    MOV A,#3CH               //activate 2nd line
    ACALL CMD                //calls CMD subroutine 
    RET                      //return from subroutine

LINE2:MOV A,#0C0H            //force cursor to line 2 position 1
    ACALL CMD                //calls CMD subroutine
    RET                      //return from subroutine

CMD: MOV P0,A                //moves content of A to Port 0
    CLR RS                   //clears register select pin
    CLR RW                   //clears read/write pin
    SETB E_LCD                   //sets enable pin
    CLR E_LCD                    //clears enable pin
    ACALL DELAY              //calls DELAY subroutine
    RET                      //return from subroutine

DISPLAY:MOV P0,A             //moves content of A to Port 0
    SETB RS                  //sets register select pin
    CLR RW                   //clears read/write pin
    SETB E_LCD                   //sets enable pin
    CLR E_LCD                    //clears enable pin
    ACALL DELAY              //calls DELAY subroutine         
    RET                      //return from subroutine

DELAY: CLR E_LCD                 //clears enable pin
    CLR RS                   //clears register select pin
    SETB RW                  //clears read/write pin
    MOV P0,#0FFh             //moves all 0's to Port 0
    SETB E_LCD                   //sets enable pin
    MOV A,P0                 //moves Port 0 to A
    JB ACC.7,DELAY           //jumps back to label DELAY if ACC.7 is set
    CLR E_LCD                   //clears enable pin
    CLR RW                   //clears read/write pin
    RET                      //return from subroutine

    END                      //end statement