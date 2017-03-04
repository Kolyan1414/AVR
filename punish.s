; Функции "PUNISH_1" and "PUNISH_2", наказывают игрока за преждевременное нажатие кнопки
;!!!Пины 0 и 1 PORTD сделать выходами 
;!!!

PUNISH_1:
	push r18							
	push r17
	push r16
	in r18,PORTD						;Напряжение на PD0, земля на PD1				
	ori r18, 0x01
	out PORTD,r18
	
	ldi r17,0x0B						;Мотор работает 0.1с
	ldi r16,0x01
	rcall DELAY

	andi r18,0xFC						;Напряжение на PD1, земля на PD0
	ori r18, 0x02
	out PORTD,r18					
	rcall DELAY							;Мотор работает 0,1с

	andi r18,0xFC
	out PORTD,r18						;PD0 и PD1 - земля

	pop r16
	pop r17
	pop r18
ret

PUNISH_2:
	push r18							
	push r17
	push r16
	in r18,PORTD						;Напряжение на PD1, земля на PD2				
	ori r18, 0x02
	out PORTD,r18
	
	ldi r17,0x0B						;Мотор работает 0.1с
	ldi r16,0x01
	rcall DELAY

	andi r18,0xFC						;Напряжение на PD0, земля на PD1
	ori r18, 0x01
	out PORTD,r18					
	rcall DELAY							;Мотор работает 0,1с

	andi r18,0xFC
	out PORTD,r18						;PD0 и PD1 - земля

	pop r16
	pop r17
	pop r18
ret


	
