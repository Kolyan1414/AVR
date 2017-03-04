;Задержка = r16*10^(-1)с (частота МК 8МГц)
DELAY:		
	push r16							
	push r17 		
	push r18
	push r19					
	ldi r17, 0xFF
	ldi r18, 0xFF
	ldi r19, 0x0B

	delay_iter:
		dec r17
		brne delay_iter					;256*
			dec r18	
			brne delay_iter				;256*
				dec r19
				brne delay_iter			;12
					dec r16
					brne delay_iter
	pop r19
	pop r18
	pop r17
	pop r16
ret 									;=1/(8*10^(6)) * 256*256*12 =  0.098304 (плюс накладные расходы) 							
