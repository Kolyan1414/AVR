.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C			;TOP
.EQU GICR,0x3B			;register for int0/1 interruption
.EQU MCUCR, 0x35		;MCU control register
.EQU GIFR,0x3A			;

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
nop;rjmp TIM0_OVR;nop					;9 rjmp TIM0_OVR
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
	rcall BOOT_LED

	push r16
	clr r16
	out PORTC, r16
	pop r16
metk:
	rcall RANDOM			;random?
	rjmp metk

BOOT:				;set MCU configuration like ports, pins, registers...
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	
	ldi r16, 0x5F
	out SPL, r16

	ser r16
	mov r0, r16
	mov r1, r16
	mov r2, r16

	ser r16			;r16=11111111
	out DDRA, r16		;ALL PORTA IS OUTPUT
	out DDRB, r16		;ALL PORTB IS OUTPUT
	out DDRC, r16		;ALL PORTC IS OUTPUT
	
	clr r16
	out PORTA, r16		;all PORTA pins are set to 0 output
	out PORTB, r16		;all PORTB pins are set to 0 output
	out PORTC, r16		;all PORTC pins are set to 0 output
	
	ldi r16, 0xF3		;r16=11110011
	out DDRD, r16		;int0/1 are input, other are output
	ldi r16, 0x0C		;r16=00001100
	out PORTD, r16		;input pins turn pull resistance on

	ldi r16,0x03		;Запуск таймера (на вход поступает тактовая частота / 64)
	out TCCR0,r16	

	ldi r16,0x01		;Запрет^-1 обработки прерываний таймера
	out TIMSK,r16		
	
	ldi r16,0xC0
	out GICR, r16		;allow interrupt int1/0

	ldi r16, 0x0A
	out MCUCR, r16

	sei			;allow interrupt global

	rjmp MAIN

DELAY:				;25ms when r17 = 0x01								
	push r19 		
	push r18
	push r17

	ldi r19, 0xFF

	for1:
		ldi r18, 0xF0
		for2:
			pop r17
			push r17
			for3:
				dec r17
				brne for3
			dec r18
		brne for2
		dec r19
	brne for1

	pop r17
	pop r18
	pop r19
ret

;players LEDs flash in the beginning of the game
BOOT_LED:
	push r18
	push r19
	push r17
	push r16

	ldi r19, 0x80
LED1:
	ldi r18, 0x01
	and r18, r1
	out PORTA, r18
	ldi r18, 0x01
	and r18, r2
	out PORTB, r18
	ldi r18, 0x01
CYCLE:
	ldi r17, 0x03
	rcall DELAY

	cp r18, r19			;if the last LED is flashing
	breq LED1			;flash the first LED
	lsl	r18				;flash the next one

	push r18
	push r18
	and r18, r1
	out PORTA, r18
	pop r18
	and r18, r2
	out PORTB, r18
	pop r18

	mov r16, r1
	mov r17, r2
	or r16, r17
	cpi r16, 0
	breq EXIT

	rjmp CYCLE

EXIT:
	pop r16
	pop r17
	pop r19
	pop r18
	ret

RANDOM:					;Подает сигнал к началу раунда с задержкой 3+random с
	push r17
	
	in r17,TCNT0			;Считываем время из таймера

	rcall CSR17			;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2

	rcall DELAY

	ser r17				;Зажигание сигнальных диодов(весь PORTC)
	out PORTC, r17
	ldi r17, 0x25
	rcall DELAY
	clr r17
	out PORTC, r17			;Сигнальные диоды гаснут

	pop r17
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

INT0:
	cli
	push r18		;save this registers
	push r17

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME0
	
	clr r1			;r1=0 ==> 1st player is ready
	
	clr r30
	out PORTA, r30

	mov r18, r2	
	cpi r18, 0x0
	brne EXIT_INT0
	
	clr r0

	rjmp EXIT_INT0

THE_GAME0:

	in r18, PINC
	
	cpi r18, 0xFF		;if there is signal --> 1st won
	
	brne SECOND_WON		;otherwise 2nd won
	
	lsl r30  		;00001111 --> 00011111
	inc r30
	
	out PORTA, r30

	mov r18, r30
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN
	
	rjmp WIN

SECOND_WON:
	lsl r31
	inc r31

	out PORTB, r31

	mov r18, r31
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN
	
	rjmp WIN

EXIT_INT0:

	clr r17
	out PORTC,r17

	ldi r17,0x1
	rcall DELAY
	
	mov r17,GIFR
	ANDI r17,0x3F
	out GIFR,r17

	pop r17
	pop r18
	
	sei

	reti

INT1:
	cli

	push r18		;save this registers
	push r17

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME1
	
	clr r2			;r2=0 ==> 2nd player is ready
	
	clr r31
	out PORTB, r31

	mov r18, r1	
	cpi r18, 0x0
	brne EXIT_INT1
	
	clr r0
	
	rjmp EXIT_INT1

THE_GAME1:
	in r18, PINC
	
	cpi r18, 0xFF		;if there is signal --> 2nd won
	
	brne FIRST_WON		;else --> 1st won
	
	lsl r31 		;00001111 --> 00011111
	inc r31
	
	out PORTB, r31

	mov r18, r31
	cpi r18, 0xFF
	brne EXIT_INT1		;if <8 ==> exit; else call WIN
	
	rjmp WIN

FIRST_WON:
	lsl r30
	inc r30
	
	out PORTA, r30

	mov r18, r30
	cpi r18, 0xFF
	brne EXIT_INT1
	
	rjmp WIN

EXIT_INT1:

	clr r17
	out PORTC,r17

	ldi r17,0x1
	rcall DELAY

	mov r17,GIFR
	ANDI r17,0x3F
	out GIFR,r17

	pop r17
	pop r18
	
	sei

	reti

WIN:
	clr r16			;PORTC = 0x00
	mov PORTC, r16

	cpi r30,0xFF
	breq FIRST_PROF
	
	ser r16
	out PORTB, r16
	clr r16
	out PORTA, r16

	ldi r17, 0x78
	rcall DELAY

	rjmp BOOT

FIRST_PROF:
	clr r16
	out PORTB, r16
	ser r16
	out PORTA, r16

	ldi r17,0x78
	rcall DELAY

	rjmp BOOT

TIM0_OVR:
	push r16
	posh r17	

	in r16, PORTD
	ANDI r16, 0XC
	mov r17, r16

	cpi r17, 0x4
	brne METOCKA

	rcall INT0

	rjmp EXIT_TIM0

METOCKA:
	mov r17,r16
	cpi r17, 0xC
	brne EXIT_TIM0
	
	rcall INT1

EXIT_TIM0:
	pop r17
	pop r16
	reti