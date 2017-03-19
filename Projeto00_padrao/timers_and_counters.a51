//////////////////////////////////////////////////////////
//														//
//  CODIGOS RELACIONADOS A TEMPORIXADORES / CONTADORES 	//
//														//
// @author: Leonardo Winter Pereira 					//
// @author: Rodrigo Yudi Endo							//
//														//
//////////////////////////////////////////////////////////

timer_configura_timer:
	mov TMOD, #01h // Seta o timer_0 para o modo 01 (16 bits)
	
timer_delay_1_s:
	mov R0, #14h // 20 vezes
	
timer_delay_50_ms:
	// 65535 - 49987 = 15548 ()
	mov TH0, #HIGH(65535 - 49987) // 0x3Ch
	mov TL0, #LOW(65535 - 49987)	// 0xBCh
	
	clr TF0
	setb TR0
	
	jnb TF0, $
		
	clr TF0
	clr TR0
	
	djnz R0, timer_delay_50_ms

end