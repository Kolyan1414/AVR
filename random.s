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
nop;rjmp INT0			;1 rjmp INT0
nop;rjmp INT1			;2 rjmp INT1
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
	;ser r16
	;out PORTA, r16
	;ldi r17, 0xA0
	;rcall DELAY

	;rcall RANDOM
;NOP_CYCLE:
	;nop
	;rjmp NOP_CYCLE
	rjmp MAIN

BOOT:					;set MCU configuration like ports, pins, registers...
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

	ser r16				;r16=11111111
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

	push r16
	ldi r16,0x01								;Запуск таймера (на вход поступает тактовая частота)
	out TCCR0,r16	

	ldi r16,0x00								;Запрет обработки прерываний таймера
	out TIMSK,r16		
	pop r16
	
	ldi r16,0xC0
	out GICR, r16		;allow interrupt int1/0

	ldi r16, 0x0A
	out MCUCR, r16

	sei					;allow interrupt global

	clr r16				;player #1 points
	clr r17				;player #2 points

	rjmp MAIN

RANDOM:										;Подает сигнал к началу раунда с задержкой 3+random с
	push r16
	push r17
	clr r16
	out PORTA, r16
	ldi r16, 0x01
	ldi r17, 0x0F
	rcall DELAY
	pop r17
	pop r16

	push r16
	push r17								;Задержка 3с после нажатия двух кнопок о готовности(перед началом рандомного времени)
	ldi r16,0x01
	ldi r17,0x70
	rcall DELAY
	
	in r16,TCNT0							;Считываем время из таймера

	out PORTA, r16
	push r16
	ldi r16, 0x01
	ldi r17, 0x5F
	rcall DELAY
	pop r16

	lsr r16									;Рандомная задержка ~r16*delay
	lsr r16
	out PORTA, r16
	mov r17, r16	
	ldi r16, 0x01
	rcall DELAY
	clr r16
	out PORTA, r16

	ser r16									;Зажигание сигнальных диодов(весь PORTC)
	out PORTC, r16							
	ldi r17, 0x14
	ldi r16,0x01
	rcall DELAY
	clr r16
	out PORTC, r16							;Сигнальные диоды гаснут

	pop r17
	pop r16
ret

DELAY:										;6ms when r17 = 0x01								
	push r19 		
	push r18
	push r17

	ldi r19, 0xFF

	for1:
		ldi r18, 0x40
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
