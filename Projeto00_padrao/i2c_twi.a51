//////////////////////////////////////////////////////////
//														//
//    CODIGOS RELACIONADOS AO PROTOCOLO I2C POR TWI		//
//														//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

ORG 	0800h

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
B2W		EQU 005Dh 	// bytes to write
B2R 	EQU 005Eh 	// bytes to read
ADDR 	EQU 005Fh 	// internal register address
DBASE 	EQU 0060h 	// endereco base dos dados a serem escritos
	
NACKS   EQU 0061h 	// contador de nacks recebidos
	
// Uma vez que o HW I2C executa "paralelo" ao 51 e o SW e totalmente composto de interrupcoes
// devemos evitar que uma comunicacao se inicie antes de outra terminar
I2C_BUSY EQU 00h // 0 - I2C livre, 1 - I2C ocupada
	
//////////////////////////////////////////////////////
// Nome:	i2c_int									//
// Descricao: Rotina de atendimento da interrupcao	//
// do TWI (I2C)										//
// Parametros:										//
// Retorna:											//
// Destroi: A, DPH, DPL (DPTR)						//
//////////////////////////////////////////////////////
i2c_int:
		MOV 	A, SSCS // pega o valor do Status	(b4 b3 b2 b1 b0 00 00 00)
		RR 		A		// faz 1 shift (divide por 2)(00 b4 b3 b2 b1 b0 00 00)

		LCALL 	decode // opera o PC, faz cair exatamente no local correto abaixo!
									 
		// Como:
		// cada LJMP tem 3 bytes, NOP 1 byte.
		// LJMP + NOP = 4 bytes.
		// os códigos de retorno do SSCS sao multiplos de 8, dividindo por 2 ficam multiplos de 4
		// quando "chamamos" decode com LCALL, o PC de retorno 
		// (que é o primeiro LJMP abaixo deste comentário)
		// fica salvo na pilha.
		// capturo o PC de retorno da pilha e somo esse multiplo.
		// quando acontecer o RET, estaremos no LJMP exato para atender a int!
		
		// Erro no Bus (00h)
		LJMP 	ERRO // 0
		NOP
		
		// start	(8h >> 1 = 4)
		LJMP 	START
		NOP	
		
		// re-start (10h >> 1 = 8)
		LJMP 	RESTART
		NOP
		
		// W ADDR ack (18h >> 1 = 12)
		LJMP 	W_ADDR_ACK
		NOP
		
		// W ADDR Nack (20h >> 1 = 16)
		LJMP 	W_ADDR_NACK
		NOP
		
		// Data ack W (28h >> 1 = 20)
		LJMP 	W_DATA_ACK
		NOP
		
		// Data Nack W (30h >> 1 = 24)
		LJMP 	W_DATA_NACK
		NOP
		
		// Arb-Lost (38h >> 1  = 28)
		LJMP 	ARB_LOST
		NOP
		
		// R ADDR ack (40h >> 1 = 32)
		LJMP 	R_ADDR_ACK
		NOP
		
		// R ADDR Nack (48h >> 1 = 36)
		LJMP 	R_ADDR_NACK
		NOP
		
		// Data ack R (50h >> 1 = 40)
		LJMP 	R_DATA_ACK
		NOP
		
		// Data Nack R (58h >> 1 = 44)
		LJMP 	R_DATA_NACK
		NOP

		// slave receive nao implementado
		LJMP 	not_impl
		NOP // 60
		
		LJMP 	not_impl
		NOP // 68
		
		LJMP 	not_impl
		NOP // 70
		
		LJMP 	not_impl
		NOP // 78
		
		LJMP 	not_impl
		NOP // 80
		
		LJMP 	not_impl
		NOP // 88
		
		LJMP 	not_impl
		NOP // 90
		
		LJMP 	not_impl
		NOP // 98
		
		LJMP 	not_impl
		NOP // A0
		
		//slave transmit nao implementado
		LJMP 	not_impl
		NOP // A8
		
		LJMP 	not_impl
		NOP // B0
		
		LJMP 	not_impl
		NOP // B8
		
		LJMP 	not_impl
		NOP // C0
		
		LJMP 	not_impl
		NOP // C8

		// codigos não implementados
		LJMP 	not_impl
		NOP // D0
		
		LJMP 	not_impl
		NOP // D8
		
		LJMP 	not_impl
		NOP // E0
		
		LJMP 	not_impl
		NOP // E8
		
		LJMP 	not_impl
		NOP // F0

		// nada a ser feito (apenas "cai" no fim da int)
		LJMP 	end_i2c_int
		NOP // F8

not_impl:
end_i2c_int:
		RETI
		
/////////////////////////////////////////////////////////////////////////////
// Esta e a funcao que opera o PC e faz o retorno ir para o local correto. //
/////////////////////////////////////////////////////////////////////////////
decode:
		// captura o PC "de retorno"
		POP 	DPH
		POP 	DPL			
		
		ADD 	A,   DPL
		MOV 	DPL, A		// soma nele o valor de A (A = SSCS / 2)
		
		JNC 	termina
		
		MOV 	A,   #1
		ADD 	A,   DPH		// se tiver carry, aumenta a parte alta.
		MOV 	DPH, A

termina:
		// poe o novo pc na pilha 
		PUSH 	DPL		
		PUSH 	DPH		

		RET
	
/////////////////////////////////////////////////////////////////////////////
// A partir deste ponto foram implementados os casos definidos na funcao   //
// i2c_int 																   //
/////////////////////////////////////////////////////////////////////////////
ERRO:
		MOV		A, 		SSCON
		ANL 	A, 		#STO // gera um stop
		MOV 	SSCON, 	A
		
		CLR		I2C_BUSY // zera o flag de ocupado
		
		LJMP 	end_i2c_int
		
START:
		// um start SEMPRE vai ocasionar uma escrita
		// pois para ler, preciso primeiro escrever de onde vou ler!
		// SSDAT = SLA + W
		// STO = 0 e SI = 0
		SETB 	I2C_BUSY		// seta o flag de ocupado
		
		MOV 	SSDAT, 	#WADDR
		MOV 	A, 		SSCON
		ANL 	A, 		#~(STO | SI)	// zera os bits STO e SI
		MOV 	SSCON, 	A
		
		LJMP 	end_i2c_int
		
RESTART:
		// o Restart sera utilizado apenas para leituras,
		// onde ha a necessidade de fazer um start->escrita->restart->leitura->stop
		// SSDAT = SLA + R
		// STO = 0 e SI = 0
		MOV 	SSDAT, 	#RADDR
		MOV 	A, 		SSCON
		ANL 	A, 		#~(STO | SI)	// zera os bits STO e SI
		MOV 	SSCON, 	A
		
		LJMP 	end_i2c_int

W_ADDR_ACK:
		// apos um W_addr_ack temos que escrever o registrador interno!
		// SSDAT = ADDR
		// STA = 0, STO = 0, SI = 0
		MOV 	SSDAT, 	ADDR
		MOV 	A, 		SSCON
		ANL 	A, 		#~(STA | STO | SI)	// zera os bits STA, STO e SI
		MOV 	SSCON, 	A

		LJMP 	end_i2c_int

W_ADDR_NACK:
		// em caso de nack, ou o end ta errado ou o slave nAo estA conectado.
		// nao vamos fazer retry, encerrando a comunicacao.
		// STA = 0, SI = 0
		// STO = 1
		MOV 	A, 		SSCON
		ANL 	A, 		#~(STA | SI)	// zera os bits STA e SI
		ORL 	A, 		#STO			// seta STO
		MOV 	SSCON, 	A
		
		CLR		I2C_BUSY // zera o flag de ocupado //correção rev2 RdG
		
		INC 	NACKS

		LJMP 	end_i2c_int
	
W_DATA_ACK:
		// apos o primeiro data ack (registrador interno) temos 2 opcoes:
		// 1 - escrever um novo byte
		// 2 - gerar um restart para leitura
		DJNZ 	B2W, wda1		// enquanto tiver bytes para escrever, pula para wda1

		// se nao tiver mais bytes para escrever, comece a ler
		DJNZ 	B2R, wda2		// se tiver algum byte pra ler, pula para wd
		
		MOV 	A,   	SSCON 
		ANL 	A, 	 	#~(STA | SI)
		ORL 	A,   	#STO			// gera um STOP
		MOV 	SSCON, 	A
		
		CLR		I2C_BUSY // zera o flag de ocupado
		
		LJMP 	end_i2c_int

wda2:
		MOV 	A, 		SSCON 
		ANL 	A, 		#~(STO | SI)
		ORL 	A, 		#STA			// gera um restart!
		MOV 	SSCON, 	A
		LJMP 	end_i2c_int

wda1:
		MOV 	R0, 	DBASE
		MOV 	SSDAT, 	@R0	// escreve o proximo
		MOV 	A, 		SSCON
		ANL 	A, 		#~(STA | STO | SI) // zera STA, STO e SI
		MOV 	SSCON, 	A
		
		INC 	DBASE		// incrementa o indice do buffer
		
		LJMP 	end_i2c_int

W_DATA_NACK:
		// apos um data_nack, podemos repetir ou encerrar
		// vamos encerrar
		MOV 	A, 		SSCON 
		ANL 	A, 		#~(STA | SI)
		ORL 	A, 		#STO			// gera um STOP
		MOV 	SSCON, 	A

		CLR		I2C_BUSY // zera o flag de ocupado

		LJMP 	end_i2c_int

ARB_LOST:
		// apos um arb-lost podemos acabar sendo enderecados como slave
		// o arb-lost costuma ocorrer em 2 situacoes:
		// 1 - problemas fisicos no BUS
		// 2 - ambiente multi-master (nao e o caso)
		// em ambos os casos, nao vamos fazer nada!
		// pois nao estamos implementando a comunicacao em modo slave.
		LJMP 	end_i2c_int	

R_ADDR_ACK:
		// depois de um R ADDR ACK, recebemos os bytes!
		MOV 	A, 	SSCON
		ANL 	A, 	#~(STA | STO | SI) // receberemos o proximo byte
	
		DJNZ 	B2R, raa1	// decrementa a quantidade de bytes a receber!
	
		// se der 0, e o ultimo byte a ser recebido
		ANL 	A, 	#~AA	// retorne NACK
	
		SJMP 	raa2
	
raa1:
		ORL 	A, #AA	// retorne ACK para o slave!

raa2:	
		MOV 	SSCON, A
		
		LJMP 	end_i2c_int	

R_ADDR_NACK:
		// idem ao w_addr_nack
		MOV 	A, 		SSCON 
		ANL 	A, 		#~(STA | SI)
		ORL 	A, 		#STO	// gera um STOP
		MOV 	SSCON, 	A
		
		CLR		I2C_BUSY // zera o flag de ocupado
		
		INC 	NACKS
		
		LJMP 	end_i2c_int

R_DATA_ACK:
		// se tiver mais bytes pra ler, de um ack, senao de um nack

		MOV 	R0, 	DBASE
		MOV		@R0, 	SSDAT // le o byte que ja chegou

		MOV 	A, 		SSCON
		ANL 	A, 		#~(STA | STO | SI) // receberemos o proximo byte
		
		DJNZ 	B2R, rda1	// decrementa a quantidade de bytes a receber!
		
		// se der 0, e o ultimo byte a ser recebido
		ANL 	A, 	#~AA	// retorne NACK
		
		SJMP 	rda2
		
rda1:
		ORL 	A, 	#AA	// retorne ACK para o slave!

rda2:	
		MOV 	SSCON, A
	
		INC 	DBASE // incrementa o buffer
	
		LJMP 	end_i2c_int

R_DATA_NACK:
		// salva o ultimo byte e termina

		MOV 	R0, 	DBASE
		MOV		@R0, 	SSDAT // le o byte que ja chegou

		MOV 	A, 		SSCON 
		ANL 	A, 		#~(STA | SI)
		ORL 	A, 		#STO	// gera um STOP
		MOV 	SSCON, 	A

		INC 	DBASE // inc o buffer

		CLR		I2C_BUSY // zera o flag de ocupado
		
		LJMP 	end_i2c_int	