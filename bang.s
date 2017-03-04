.include "boot.inc"
.include "score.inc"
.include "interrupt.inc"
.include "button.inc"
.include "engine.inc"
.include "blink.inc"


.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C			;TOP

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

MAIN
	nop
	rjmp MAIN
