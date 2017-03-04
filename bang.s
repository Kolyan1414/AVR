.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C			;TOP

.EQU GICR,0x3B			;register for int0/1 interruption

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

rjmp BOOT				;0
rjmp INT0				;1
rjmp INT1				;2
nop					;3
nop					;4
nop					;5
nop					;6
nop					;7
nop					;8
rjmp TIM0_OVR				;9	
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
nop					;21

MAIN:
	BOOT_FLASH1
	rjmp MAIN

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

;Задержка = r16*10^(-1)с (частота МК 8МГц)
DELAY:		
	push r16							
	push r17 		
	push r18
	push r19					
	ldi r17, 0xFF
	ldi r18, 0xFF
	ldi r19, 0x0B

	delay_iter:
		dec r17
		brne delay_iter					;256*
			dec r18	
			brne delay_iter				;256*
				dec r19
				brne delay_iter			;12
					dec r16
					brne delay_iter
	pop r19
	pop r18
	pop r17
	pop r16
ret 									;=1/(8*10^(6)) * 256*256*12 =  0.098304 (плюс накладные расходы) 	

BOOT_FLASH1:			;players LEDs flash in the beginning of the game
	
	push r18
	push r19
	push r16

	ldi r19, 0x80
	clr r1

SET_PORT:
	ldi r18, 0x01
	out PORTA, r18
CYCLE:
	cp r18, r19			;if the last LED is flashing
	breq SET_PORT		;flash the first LED
	lsl	r18				;flash the next one
	out PORTA, r18

	ldi r16, 0x01
	rcall DELAY

	rjmp CYCLE

	pop r16
	pop r19
	pop r18

	ret

;ФУНКЦИЯ "led_blink"

;r20 = cостояние диодов в PORTA
;r21 = cостояние диодов в PORTB
;r22 = cостояние диодов в PORTC
;r23 = cостояние диодов в PORTD
;r19 = количство миганий
;r16 = длительность исходного состояния [10^(-1)с
;r17 = длительность состояния противоположного исходному [10^(-1)с

led_blink: 								
	led_blink_iter:
		rcall delay
			
		com r20
		com r21
		com r22
		com r23
		out PORTA, r20
		out PORTB, r21
		out PORTC, r22
		out PORTD, r23
		push r16
		mov r16, r17
		rcall delay

		com r20
		com r21
		com r22
		com r23
		out PORTA, r20
		out PORTB, r21
		out PORTC, r22
		out PORTD, r23
		pop r16
		
		dec r19
		brne led_blink_iter
ret
