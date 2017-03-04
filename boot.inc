BOOT:				;set MCU configuration like ports, pins, registers...
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	
	ldi r16, 0x5F
	out SPL, r16

	ser r16			;r16=11111111
	out DDRA, r16		;ALL PORTA IS OUTPUT
	out DDRB, r16		;ALL PORTB IS OUTPUT
	out DDRC, r16		;ALL PORTC IS OUTPUT
	
	clr r16
	out PORTA, r16		;all PORTA pins are set to 0 output
	out PORTB, r16		;all PORTB pins are set to 0 output
	out PORTC, r16		;all PORTC pins are set to 0 output
	
	ldi r16, 0xF9		;r16=11111001
	out DDRD, r16		;int0/1 are input, other are output

	;timer settings
	

	ldi r16, 0x8		;TOP is 8 <==> 1 ms 
	out OSR0,r16

	ldi r16, 0xD		;00001101 == cs/1024
	out TCCR0,r16		;interrupt in 1ms

	ldi r16, 0x1		;00000001
	out TIMSK,r16		;allow interrupt t0
	
	ldi r16,0xC0
	out GICR, r16		;allow interrupt int1/0

	sei			;allow interrupt global

	clr r16			;player #1 points
	clr r17			;player #2 points

	rjmp MAIN
