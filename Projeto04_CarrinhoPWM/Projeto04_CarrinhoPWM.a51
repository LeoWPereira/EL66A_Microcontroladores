//////////////////////////////////////////////////////////
//														//
//           		PROJETO 03 - RFID 					//
//														//
// Requisitos: 											//
// 														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

$NOMOD51
#include <at89c5131.h>
#include "lcd16x2.a51"
#include "timer.a51"
#include "teclado_matricial_4x4.a51"
#include "buzzer.a51"
#include "pwm_com_timer_duty_cycle_por_int.a51"

ORG 0000h // Origem do codigo 
		LJMP __STARTUP__

ORG 0003h // Inicio do codigo da interrupcao externa INT0
		LJMP INT_INT0

ORG 000Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
		LJMP INT_TIMER0

ORG 0013h // Inicio do codigo da interrupcao externa INT1
		LJMP INT_INT1

ORG 001Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
		LJMP INT_TIMER1

ORG 0023h // Inicio do codigo da interrupcao SERIAL
		LJMP INT_SERIAL

ORG	0043h
		LJMP INT_I2C_TWI
	
//////////////////////////////////////////////////
//       TABELA DE EQUATES DA BIBLIOTECA		//
////										  ////
////// 		A finalizar no endereco 0xE7 	//////
////////			(OBRIGATORIO)		  ////////
//////////////////////////////////////////////////

// 00h - 
// 01h - 
// 02h - 
// 03h -
// 04h -
// 05h -
// 06h -
// 07h -
// 08h -
// 09h -
// 0Ah -
// 0Bh -
// 0Ch - Inc. Velocidade
// 0Dh - Dec. Velocidade
// 0Eh -
// 0Fh -
// 10h -
COMANDO					EQU 035h
VELOCIDADE_MOTOR_1		EQU 036h
VELOCIDADE_MOTOR_2		EQU 037h
	
//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

org 0050h
STR_LEONARDO_PEREIRA:
        DB      'Leonardo Pereira',00H
STR_RODRIGO_ENDO:
        DB      '  Rodrigo Endo  ',00H
STR_COMANDOS_DISPONIVEIS_LINHA_1:
		DB		'F1/F2: Muda Vel.',00H
STR_COMANDOS_DISPONIVEIS_LINHA_2:
		DB		'ENTER: Init/Para',00H
STR_VELOCIDADE_MOTOR_1:
		DB      'Vel. PWM 1: ',00H
STR_VELOCIDADE_MOTOR_2:
		DB      'Vel. PWM 2: ',00H
			
__STARTUP__:
		LCALL	INIT_VALORES
		//LCALL	INIDISP
		
		LCALL	INT_CONFIGURA_INTERRUPCOES
		
		MOV		R0, #00h
		MOV		R2, #0Ah
		MOV		R3, #0Ah
		MOV		R4, #0Ch
		MOV		R5, #00000011b
		LCALL	PWM_SQUARE_WAVE_SETUP_AND_START
		
		JMP		$
		
		/*MOV		DPTR, #STR_LEONARDO_PEREIRA
		LCALL	ESC_STR1
		
		MOV		DPTR, #STR_RODRIGO_ENDO
		LCALL	ESC_STR2
		
		MOV		R2, #02h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
LIMPA_LCD_E_INICIA_SISTEMA:
		// Limpa ambas as linhas do display
		LCALL 	CLR1L
		LCALL 	CLR2L
		
		MOV		DPTR, #STR_COMANDOS_DISPONIVEIS_LINHA_1
		LCALL	ESC_STR1
		
		MOV		DPTR, #STR_COMANDOS_DISPONIVEIS_LINHA_2
		LCALL	ESC_STR2
		
		MOV		R2, #02h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
VARRE_FUNCAO:
		LCALL 	CLR2L
		LCALL 	CLR1L
		
		MOV		R1, #COMANDO
		LCALL	VARREDURA_TECLADO
		
		MOV		R2, #00h
		MOV		R1, #01h
		MOV		R0, #32h
		LCALL	TIMER_DELAY
		
		LCALL	DECODER_FUNCAO

		JMP		VARRE_FUNCAO*/

//////////////////////////////////////////////////////
// NOME: INIT_VALORES								//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INIT_VALORES:
		MOV		PWM_DUTY_CYCLE_PIN_1, #128d
		MOV		PWM_DUTY_CYCLE_PIN_2, #20d
		
		MOV		PWM_DUTY_AUX_1,		#128d
		MOV		PWM_DUTY_AUX_2,		#20d
		
		MOV		WAVE_FORM, #WAVE_FORM_SQUARE // wave form
		
		RET

//////////////////////////////////////////////////////
// NOME: DECODER_FUNCAO								//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
DECODER_FUNCAO:
		MOV	 	A, COMANDO
		SUBB 	A, #0Ch
		JZ	 	CHAMA_INCREMENTA_VELOCIDADE
		
		MOV	 	A, COMANDO
		SUBB 	A, #0Dh
		JZ		CHAMA_DECREMENTA_VELOCIDADE
		
		AJMP	FIM_DECODER_FUNCAO
		
CHAMA_INCREMENTA_VELOCIDADE:
		LCALL	MOSTRA_VELOCIDADES
		
		MOV		R2, #02h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
		LCALL	INCREMENTA_VELOCIDADE
		
		AJMP	FIM_DECODER_FUNCAO

CHAMA_DECREMENTA_VELOCIDADE:
		LCALL	MOSTRA_VELOCIDADES
		
		MOV		R2, #02h
		MOV		R1, #00h
		MOV		R0, #00h
		LCALL	TIMER_DELAY
		
		LCALL	DECREMENTA_VELOCIDADE
		
		AJMP	FIM_DECODER_FUNCAO

FIM_DECODER_FUNCAO:
		RET
		
//////////////////////////////////////////////////////
// NOME: MOSTRA_VELOCIDADES							//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
MOSTRA_VELOCIDADES:
		MOV 	DPTR, #STR_VELOCIDADE_MOTOR_1
		LCALL	ESC_STR1
		
		MOV		A, VELOCIDADE_MOTOR_1
		LCALL	ESC_DADO_NUMERO_COMPLETO
		
		MOV 	DPTR, #STR_VELOCIDADE_MOTOR_2
		LCALL	ESC_STR2
		
		MOV		A, VELOCIDADE_MOTOR_2
		LCALL	ESC_DADO_NUMERO_COMPLETO
		
		RET
		
//////////////////////////////////////////////////////
// NOME: INCREMENTA_VELOCIDADE						//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INCREMENTA_VELOCIDADE:
		RET

//////////////////////////////////////////////////////
// NOME: DECREMENTA_VELOCIDADE						//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
DECREMENTA_VELOCIDADE:
		RET

////////////////////////////////////////////////
// INICIO DOS CODIGOS GERADOS POR INTERRUPCAO //
////////////////////////////////////////////////

INT_CONFIGURA_INTERRUPCOES:
		MOV		IEN0, #10001000b // Configura interrupcao apenas para o TIMER_0
		MOV		IPL0, #00000000b // da prioridade alta para o TIMER_0
		
		RET

//////////////////////////////////////////////////////
// NOME: INT_INT0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_INT0:
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER0									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER0:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_INT1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_INT1:
		RETI

//////////////////////////////////////////////////////
// NOME: INT_TIMER1									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_TIMER1:
		PUSH	ACC
		
		LCALL	PWM_SQUARE_WAVE
		
		POP		ACC
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_SERIAL									//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_SERIAL:
		RETI
	
//////////////////////////////////////////////////////
// NOME: INT_I2C_TWI								//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_I2C_TWI:
		RETI
		
		
		
		
		
		
		
		
		
		
		
		//////////////////////////////////////////////////////
// NOME: PWM_SQUARE_WAVE							//
// DESCRICAO: 										//
// P.ENTRADA: R6, R7					 	 		//
//			  R5-> FLAG PARA PINOS A SEREM ATIVADOS //
//				bit 0 = PINO_LED_VERDE				//
//				bit 1 = PWM_PIN_0					//
//				bit 2 = PWM_PIN_1					//
//				bit 3 = PWM_PIN_2					//
// P.SAIDA: - 										//
// ALTERA: R6, R7									//
//////////////////////////////////////////////////////
PWM_SQUARE_WAVE:	
		CLR 	TF1
	
		DJNZ	R6, CONTINUE_SQUARE
		MOV		R6, PWM_PERIODO_MED
		
		DJNZ	R7, CONTINUE_SQUARE
		MOV		R7, PWM_PERIODO_MSB	
		
		LCALL	VERIFICA_DUTY_CYCLES

		JB		PWM_FLAG, HIGH_DONE
	
LOW_DONE:			
		SETB 	PWM_FLAG
		
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV		TH1, #0FFh
		MOV 	TL1, PWM_DUTY_CYCLE_ATUAL//PWM_DUTY_CYCLE_PIN_1		
		
		RET
				
HIGH_DONE:
		CLR 	PWM_FLAG			// Make PWM_FLAG = 0 to indicate start of low section
			
		LCALL	DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS
		
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_ATUAL//PWM_DUTY_CYCLE_PIN_1
		
		MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL1, A
		
		CLR 	TF1					// Clear the Timer 1 interrupt flag
		
		RET

CONTINUE_SQUARE:
		JNB		PWM_FLAG, CONTINUE_SQUARE_LOW
	
CONTINUE_SQUARE_HIGH:
		MOV  	A, #0FFh		// Subtract DUTY_CYCLE from A. A = PERIOD_LSB - DUTY_CYCLE
		CLR		C
		SUBB	A, PWM_DUTY_CYCLE_ATUAL//PWM_DUTY_CYCLE_PIN_1
		
		MOV 	TH1, #0FFh			// Load high byte of timer with DUTY_CYCLE
		MOV		TL1, A
		
		CLR 	TF1

		RET
		
CONTINUE_SQUARE_LOW:
		MOV		TH1, #0FFh
		MOV 	TL1, PWM_DUTY_CYCLE_ATUAL//PWM_DUTY_CYCLE_PIN_1
		
		RET

//////////////////////////////////////////////////////
// NOME: DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS	//
// DESCRICAO: 										//
// P.ENTRADA: R5-> FLAG PARA PINOS					//
//				bit 0 = PWM_PIN_0					//
//				bit 1 = PWM_PIN_1					//
//				bit 2 = PWM_PIN_2					//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
DEFINE_PINOS_A_SEREM_ATIVADOS_DESATIVADOS:
		MOV		A, #01h
		ANL		A, PWM_PIN_A_VERIFICAR//R5
		JZ		NAO_ATIVA_BIT_0
		
		CPL 	PWM_PIN_0
		
NAO_ATIVA_BIT_0:
		MOV		A, #02h
		ANL		A, PWM_PIN_A_VERIFICAR//R5
		JZ		NAO_ATIVA_BIT_1
		
		CPL 	PWM_PIN_1

NAO_ATIVA_BIT_1:
		RET

//////////////////////////////////////////////////////
// NOME: VERIFICA_DUTY_CYCLES						//
// DESCRICAO: 										//
// P.ENTRADA: 										//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
VERIFICA_DUTY_CYCLES:
		MOV 	A, PWM_DUTY_CYCLE_PIN_1
		MOV		B, PWM_DUTY_CYCLE_PIN_2
		
		SUBB	A, B
		
		//JZ
		
		JNC		PWM_1_MAIOR_QUE_PWM_2
		
PWM_1_MENOR_QUE_PWM_2:
		MOV		PWM_PIN_A_VERIFICAR, #01h
		MOV		A, PWM_DUTY_CYCLE_PIN_2
		SUBB	A, PWM_DUTY_CYCLE_PIN_1
		MOV		PWM_DUTY_CYCLE_PIN_2, A
		MOV		PWM_DUTY_CYCLE_PIN_1, PWM_DUTY_AUX_1
		
		JMP		FIM_VERIFICA_DUTY_CYCLES
		
PWM_1_MAIOR_QUE_PWM_2:
		MOV		PWM_PIN_A_VERIFICAR, #02h
		MOV		A, PWM_DUTY_CYCLE_PIN_1
		SUBB	A, PWM_DUTY_CYCLE_PIN_2
		MOV		PWM_DUTY_CYCLE_PIN_1, A
		MOV		PWM_DUTY_CYCLE_PIN_2, PWM_DUTY_AUX_2
		
FIM_VERIFICA_DUTY_CYCLES:
		MOV 	A, PWM_DUTY_CYCLE_PIN_1
		MOV		B, PWM_DUTY_CYCLE_PIN_2
		
		SUBB	A, B
		
		JNC		PWM_ATUAL_DUTY_CYCLE_2

PWM_ATUAL_DUTY_CYCLE_1:
		MOV		A, PWM_DUTY_CYCLE_PIN_1
		
		JMP		FIM_PWM_ATUAL

PWM_ATUAL_DUTY_CYCLE_2:
		MOV		A, PWM_DUTY_CYCLE_PIN_2
		
FIM_PWM_ATUAL:
		MOV		PWM_DUTY_CYCLE_ATUAL, A
		
		RET
		
		
		
		
		
		
		END