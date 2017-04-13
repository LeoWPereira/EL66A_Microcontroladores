//////////////////////////////////////////////////////////////////////////////
//																			//
//           		PROJETO 02 - LOMBADA ELETRONICA 						//
//																			//
// Requisitos: 																//
// - mostre a velocidade em dois displays de sete segmentos vermelhos		//
// - A medida de velocidade e estruturada a partir de dois lacos			//
// indutivos, em uma distancia previamente conhecida						//
// - Cada laco indutivo consta de um conjunto de espiras, formando uma  	//
// indutancia conhecida. Cada laco indutivo consta de um conjunto de		//
// espiras, formando uma indutancia conhecida. Esta indutancia e a base 	//
// de um circuito oscilador com frequencia padrao (normalmente Colpitts)	//
// - Quando um veiculo passa, por ser metalico, ele perturba a indutancia,  //
// que automaticamente varia esta indutancia, e que varia a frequencia de 	//
// oscilacao.																//
// - O circuito microcontrolado deve capturar estas variabilidades de 		//
// frequencia e assim chavear o disparo da contagem de tempo referente a 	//
// passagem pelo primeiro laco ate o segundo.								//
// - Esta janela de tempo voce converte em velocidade e assim mostra.		//
// - O sistema devera, ainda, ter um alarme em forma de led e buzzer quando	//
// a velocidade ultrapassar os 40 km/h.
// 																			//
// @author: Leonardo Winter Pereira 										//
// @author: Rodrigo Yudi Endo												//
//																			//
//////////////////////////////////////////////////////////////////////////////

org 00h//2000h // Origem do codigo 
ljmp __STARTUP__

org 03h//2003h // Inicio do codigo da interrupcao externa INT0
ljmp INT_INT0

org 0Bh//200Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 0
ljmp INT_TIMER0

org 013h//2013h // Inicio do codigo da interrupcao externa INT1
ljmp INT_INT1

org 01Bh//201Bh // Inicio do codigo da interrupcao interna gerada pelo TIMER/COUNTER 1
ljmp INT_TIMER1

org 023h//2023h // Inicio do codigo da interrupcao SERIAL
ljmp INT_SERIAL

//////////////////////////////////////////////////
//       TABELA DE EQUATES DO PROGRAMA		    //
//////////////////////////////////////////////////

//////////////////////////////////////////////////
// REGIAO DA MEMORIA DE PROGRAMA COM AS STRINGS //
//////////////////////////////////////////////////

//////////////////////////////////////////////////
// 				INICIO DO PROGRAMA			    //
//////////////////////////////////////////////////

__STARTUP__:

//////////////////////////////////////////////////
//  INICIO DOS CODIGOS GERADOS POR INTERRUPCAO  //
//////////////////////////////////////////////////

//////////////////////////////////////////////////////
// NOME: INT_CONFIGURA_INTERRUPCOES					//
// DESCRICAO: 										//
// P.ENTRADA:					 	 				//
// P.SAIDA: 										//
// ALTERA: 											//
//////////////////////////////////////////////////////
INT_CONFIGURA_INTERRUPCOES:
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
	
FIM:
		JMP $
		END