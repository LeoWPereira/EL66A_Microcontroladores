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
		LCALL	INIDISP
		
		//LCALL	INT_CONFIGURA_INTERRUPCOES
		
		MOV		R0, #00h
		MOV		R2, #0Ah
		MOV		R3, #0Ah
		MOV		R4, #0Ch
		MOV		R5, #00000001b
		LCALL	PWM_1_SQUARE_WAVE_SETUP_AND_START
		
		MOV		R0, #00h
		MOV		R2, #0Ah
		MOV		R3, #0Ah
		MOV		R4, #0Ch
		MOV		R5, #00000010b
		LCALL	PWM_2_SQUARE_WAVE_SETUP_AND_START
		
		MOV		DPTR, #STR_LEONARDO_PEREIRA
		LCALL	ESC_STR1
		
		MOV		DPTR, #STR_RODRIGO_ENDO
		LCALL	ESC_STR2
		
		MOV		R2, #00h
		MOV		R1, #00h
		MOV		R0, #0FFh
		LCALL	TIMER_DELAY
		
		MOV		R2, #00h
		MOV		R1, #00h
		MOV		R0, #0FFh
		LCALL	TIMER_DELAY
		
		MOV		R2, #00h
		MOV		R1, #00h
		MOV		R0, #0FFh
		LCALL	TIMER_DELAY
		
		MOV		R2, #00h
		MOV		R1, #00h
		MOV		R0, #0FFh
		LCALL	TIMER_DELAY
		
LIMPA_LCD_E_INICIA_SISTEMA:
		// Limpa ambas as linhas do display
		LCALL 	CLR1L
		LCALL 	CLR2L
		
		MOV		DPTR, #STR_COMANDOS_DISPONIVEIS_LINHA_1
		LCALL	ESC_STR1
		
		MOV		DPTR, #STR_COMANDOS_DISPONIVEIS_LINHA_2
		LCALL	ESC_STR2
		
VARRE_FUNCAO:
		MOV		R1, #COMANDO
		LCALL	VARREDURA_TECLADO
		
		MOV		R2, #00h
		MOV		R1, #00h
		MOV		R0, #0FAh
		LCALL	TIMER_DELAY
		
		LCALL	DECODER_FUNCAO

		JMP		VARRE_FUNCAO

//////////////////////////////////////////////////////
// NOME: INIT_VALORES								//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INIT_VALORES:
		MOV		PWM_DUTY_CYCLE_PIN_0, #200d
		MOV		PWM_DUTY_CYCLE_PIN_1, #50d
		
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
		MOV		IEN0, #10001010b // Configura interrupcao apenas para o TIMER_0
		MOV		IPL0, #00001111b // da prioridade alta para o TIMER_0
		
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
				
		END