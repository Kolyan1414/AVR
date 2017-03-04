BOOT:					;set MCU configuration like ports, pins, registers...
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	
	ldi r16, 0x5F
	out SPL, r16

	ser r16				;r16=11111111
	out DDRA, r16		;ALL PORTA IS OUTPUT
	out DDRB, r16		;ALL PORTB IS OUTPUT
	
	clr r16
	out PORTA, r16		;all PORTA pins are set to 0 output
	out PORTB, r16		;all PORTB pins are set to 0 output
	
	ldi r17,0xF8		;11111000 1st, 2nd and 3d are input, other are output
	out DDRC,r17
	
	ldi r17,0x7			;00000111 LEDs off, buttons on
	out PORTC,r17

	rjmp MAIN
