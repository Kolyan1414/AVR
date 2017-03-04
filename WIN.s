WIN:
	cpi r16,0xFF
	breq 1ST_PROFI
	
	cer r16
	our PORTB, r16
	clr r16
	out PORTA, r16

1ST_PROFI
	clr r16
	our PORTB, r16
	cer r16
	out PORTA, r16

	ldi r17,0x0B
	ldi r16,0x1E

rcall DELAY

	rjmp BOOT
	ret