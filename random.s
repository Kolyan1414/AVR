;ФУНКЦИЯ "random"(на основе timer0)
;!!!Добавить в boot (если этого еще нет)
.EQU TIMSK,0x39		;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33		;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32		;T/C FLAG REG

	push r16
	ldi r16,0x1								;Запуск таймера (на вход поступает тактовая частота)
	out TCCR0,r16	

	ldi r16,0x0								;Запрет обработки прерываний таймера
	out TIMSK,r16		
	pop r16
;!!!

RANDOM:										;Подает сигнал к началу раунда с задержкой 3+random с
	push r16
											;Задержка 3с после нажатия двух кнопок о готовности(перед началом рандомного времени)
	ldi r16,0x1E
	rcall delay
	pop r16

	push r16							
	in r16,TCNT0							;Считываем время из таймера	
	lsr r16									;Делим на 8, чтобы получить время рандомной задержки ~r16*delay
	lsr r16
	lsr r16
	recall delay							;Рандомная задержка ~r16*delay
	
	ldi r16,0xFF							;Зажигание сигнальных диодов(весь PORTC)
	out PORTC,r16							
	ldi r16,0x14							;Сигнальные диоды горят 2с
	rcall delay 
	ldi r16,0x00
	out PORTC,r16							;Сигнальные диоды гаснут

	pop r16
ret	 