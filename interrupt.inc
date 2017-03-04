SET_INTERRUPT			;timer settings
	ldi r16,0x8			;TOP is 8 <==> 1 ms 
	out OSR0,r16

	ldi r16,0xD			;00001101 == cs/1024
	out TCCR0,r16		;interrupt in 1ms

	ldi r16,0x1			;00000001
	out TIMSK,r16		;allow interrupt t0

	sei					;allow interrupt global

TIM0_OVR:
	rcall BUTTON_TAP
	reti
