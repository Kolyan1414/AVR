.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C			;TOP
.EQU GICR,0x3B			;register for int0/1 interruption
.EQU MCUCR, 0x35		;MCU control register

.EQU PORTA,0x1B			;PORTA is 1st player points
.EQU DDRA,0x1A
.EQU PINA,0x19

.EQU PORTB,0x18			;PORTB is 2nd player points
.EQU DDRB,0x17
.EQU PINB,0x16

.EQU PORTC,0x15			;PORTC is buttons and indicating LEDs
.EQU DDRC,0x14
.EQU PINC,0x13

.EQU PORTD,0x12			;PORTD is punishment
.EQU DDRD,0x11
.EQU PIND,0x10

rjmp BOOT			;0
rjmp INT0			;1 rjmp INT0
rjmp INT1			;2 rjmp INT1
nop					;3
nop					;4
nop					;5
nop					;6
nop					;7
nop					;8
nop;rjmp TIM0_OVR		;9 rjmp TIM0_OVR
nop					;10
nop					;11
nop					;12
nop					;13
nop					;14
nop					;15
nop					;16
nop					;17
nop					;18
nop					;19
nop					;20

MAIN:
	nop
	nop
	nop
	rjmp MAIN

INT0:
	push r18		;save this registers

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME0
	
	clr r1			;r1=0 ==> 1st player is ready
	clr r16
	out PORTA, r16

	mov r18, r2	
	cpi r18, 0x0
	brne EXIT_INT0
	
	clr r0

	rjmp EXIT_INT0

THE_GAME0:

	in r18, PINC
	cpi r18, 0xFF		;if there is signal --> 1st won
	brne SECOND_WON		;otherwise 2nd won
	
	lsl r16  		;00001111 --> 00011111
	inc r16
	out PORTA, r16

	mov r18, r16
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN

SECOND_WON:
	lsl r17
	inc r17
	out PORTB, r17

	mov r18, r17
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN

EXIT_INT0:
	pop r18

	reti

INT1:
	push r18		;save this registers

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME1
	
	clr r2			;r2=0 ==> 2nd player is ready
	clr r17
	out PORTB, r17

	mov r18, r1	
	cpi r18, 0x0
	brne EXIT_INT1
	
	clr r0
	
	rjmp EXIT_INT1

THE_GAME1:
	in r18, PINC
	cpi r18, 0xFF		;if there is signal --> 2nd won	
	brne FIRST_WON		;else --> 1st won
	
	lsl r17  		;00001111 --> 00011111
	inc r17
	out PORTB, r17

	mov r18, r17
	cpi r18, 0xFF
	brne EXIT_INT1		;if <8 ==> exit; else call WIN
	
	rcall WIN

FIRST_WON:
	lsl r16
	inc r16
	out PORTA, r16
	
	mov r18, r16
	cpi r18, 0xFF
	brne EXIT_INT1

EXIT_INT1:
	pop r18

	reti


BOOT:				;set MCU configuration like ports, pins, registers...
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	
	ldi r16, 0x5F
	out SPL, r16

	ser r16
	mov r0, r16
	ser r16
	mov r1, r16
	ser r16
	mov r2, r16

	ser r16			;r16=11111111
	out DDRA, r16		;ALL PORTA IS OUTPUT
	out DDRB, r16		;ALL PORTB IS OUTPUT
	out DDRC, r16		;ALL PORTC IS OUTPUT
	
	ser r16
	out PORTA, r16		;all PORTA pins are set to 1 output
	out PORTB, r16		;all PORTB pins are set to 1 output
	out PORTC, r16		;all PORTC pins are set to 1 output
	
	ldi r16, 0xF9		;r16=11111001
	out DDRD, r16		;int0/1 are input, other are output
	ldi r16, 0x06		;r16=00000110
	out PORTD, r16		;input pins turn pull resistance on

	;timer settings
	;ldi r16, 0x8		;TOP is 8 <==> 1 ms 
	;out OCR0,r16

	;ldi r16, 0xD		;00001101 == cs/1024
	;out TCCR0,r16		;interrupt in 1ms

	;ldi r16, 0x1		;00000001
	;out TIMSK,r16		;allow interrupt t0
	
	ldi r16,0xC0
	out GICR, r16		;allow interrupt int1/0

	ldi r16, 0x0A		;high-to-low
	out MCUCR, r16

	sei					;allow interrupt global

	clr r16				;player #1 points
	clr r17				;player #2 points

	rjmp MAIN