.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.

.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

.EQU GICR,0x3B			;register for int0/1 interruption
.EQU MCUCR, 0x35		;MCU control register
.EQU GIFR, 0x3A			;General Interrupt Flag Register

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

rjmp BOOT 			;0
rjmp INT0			;1
rjmp INT1			;2
nop					;3
nop					;4
nop					;5
nop					;6
nop					;7
nop					;8
nop					;9 rjmp TIM0_OVR
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

NEW_GAME:
	rcall BOOT_LED

BOOT:
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
	
	ldi r16, 0x38
	out DDRC, r16
	clr r16
	out PORTC, r16

	clr r16
	out DDRD, r16
	ldi r16, 0x0C
	out PORTD, r16

	ldi r16, 0x01		;Запуск таймера (на вход поступает тактовая частота)
	out TCCR0, r16	

	ldi r16, 0x00		;Запрет обработки прерываний таймера
	out TIMSK, r16

	ldi r16, 0x0A		;int0 and int1 interupts occur when PORTD input pins change from +VCC to GND 
	out MCUCR, r16

	ser r20				;player_a readiness
	ser r21				;player_b readiness
	clr r30				;player_a score
	clr r31				;player_b score

	sei					;allow interrupt global
	rjmp NEW_GAME

INT0:
	ser r16
	out PORTA, r16
NOP_CYCLE:
	nop
	rjmp NOP_CYCLE
	clr r20
	reti

INT1:
	ser r16
	out PORTB, r16
NOP_CYCLE1:
	nop
	rjmp NOP_CYCLE1
	clr r21
	reti

;==============================Functions=================================

;!"ПРОБЕГАНИЕ ДИОДОВ" PORTB, PORTA
BOOT_LED:
	ldi r19, 0x80

LED1:
	ldi r18, 0x01
	and r18, r20
	out PORTA, r18
	ldi r18, 0x01
	and r18, r21
	out PORTB, r18
	ldi r18, 0x01

CYCLE:
	ldi r16, 0x03
	rcall DELAY

	cp r18, r19			;if the last LED is flashing
	breq LED1			;flash the first LED
	lsl	r18				;flash the next one

	push r18
	push r18
	and r18, r20
	out PORTA, r18
	pop r18
	and r18, r21
	out PORTB, r18
	pop r18

	mov r16, r20
	or r16, r21
	cpi r16, 0
	breq EXIT

	rjmp CYCLE
EXIT:
ret

;================================================================
;================================================================
;================================================================

DELAY:				;(r16 * 25)ms
	push r19 		
	push r18
	push r16

	ldi r19, 0xFF

	for1:
		ldi r18, 0xF0
		for2:
			pop r16
			push r16
			for3:
				dec r16
				brne for3
			dec r18
		brne for2
		dec r19
	brne for1

	pop r16
	pop r18
	pop r19
ret

RANDOM:						;1s + random
	in r17,TCNT0

	rcall CSR17				;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2
	lsr r17
	mov r16, r17
	rcall DELAY

	ldi r17, 0x28
	rcall DELAY

	ser r17					;light portc for 2 seconds
	out PORTC, r17
	ldi r16, 0x50
	rcall DELAY
	clr r17
	out PORTC, r17			;Сигнальные диоды гаснут

	clr r17
	out PORTC, r17  		;Потушить сигнаьлные диоды

	ret

CSR17:			;CycleShiftRight, works only with r17; Example: 0x11000101 -> 0x11100010 -> 0x01110001 -> 0x10111000
	push r18

	ldi r18, 0x01
	push r17
	and r17, r18
	cpi r17, 0x00
	brne ADD_ONE

	pop r17
	lsr r17
	rjmp ADD_ZERO

ADD_ONE:
	ldi r18, 0x80
	pop r17
	lsr r17
	add r17, r18

ADD_ZERO:
	pop r18
ret
