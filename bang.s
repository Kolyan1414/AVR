.EQU SREG,0x3F			;STATUS REG.
.EQU SPH,0x3E			;ST.POINTER(HIGH)
.EQU SPL,0x3D			;ST.POINTER(LOW)
	
.EQU TIMSK,0x39			;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33			;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32			;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C			;TOP
.EQU GICR,0x3B			;TOP

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
nop					;1 rjmp INT0
nop					;2 rjmp INT1
nop					;3
nop					;4
nop					;5
nop					;6
nop					;7
nop					;8
nop 				;9 rjmp TIM0_OVR
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
	rjmp BOOT_LED
	rjmp MAIN

BOOT:				;set MCU configuration like ports, pins, registers...
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	
	ldi r16, 0x5F
	out SPL, r16

	ser r16
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
	
	ldi r16, 0xF9		;r16=11111001
	out DDRD, r16		;int0/1 are input, other are output
	ldi r16, 0x06		;r16=00000110
	out PORTD, r16		;input pins turn pull resistance on

	;timer settings
	

	ldi r16, 0x8		;TOP is 8 <==> 1 ms 
	out OCR0,r16

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

;Задержка = r16*r17*10^(-1)с (частота МК 8МГц)
DELAY:		
	push r16							
	push r17 		
	push r18
	push r19
	ldi r18, 0xFF
	ldi r19, 0xFF

	delay_iter:
		dec r19
		brne delay_iter					;256*
			dec r18	
			brne delay_iter				;256*
				dec r17	
				brne delay_iter			;r17*
					dec r16
					brne delay_iter		;r16*
	pop r19
	pop r18
	pop r17
	pop r16
ret 									;=1/(8*10^(6)) * 256*256*1 =  0.008192

;players LEDs flash in the beginning of the game
BOOT_LED:
	
	push r18
	push r19
	push r17
	push r16

	ldi r19, 0x80

LED1:
	ldi r18, 0x01
	out PORTA, r18
	out PORTB, r18
CYCLE:
	ldi r16, 0x01
	ldi r17, 0x03
	rcall DELAY

	cp r18, r19			;if the last LED is flashing
	breq LED1			;flash the first LED
	lsl	r18				;flash the next one

	;and r18, r1
	out PORTA, r18
	;and r18, r2
	out PORTB, r18

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

	reti

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
		rcall DELAY
			
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
		rcall DELAY

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

;ФУНКЦИЯ "random"(на основе timer0)
;!!!Добавить в boot (если этого еще нет)
.EQU TIMSK,0x39		;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33		;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32		;T/C FLAG REG

	push r16
	ldi r16,0x01								;Запуск таймера (на вход поступает тактовая частота)
	out TCCR0,r16	

	ldi r16,0x00								;Запрет обработки прерываний таймера
	out TIMSK,r16		
	pop r16
;!!!

;!!!PORTC все выходы

RANDOM:										;Подает сигнал к началу раунда с задержкой 3+random с
	push r16
	push r17								;Задержка 3с после нажатия двух кнопок о готовности(перед началом рандомного времени)
	ldi r16,0x1E
	ldi r17,0x0C
	rcall DELAY
	
	in r16,TCNT0							;Считываем время из таймера	
	lsr r16									;Делим на 8, чтобы получить время рандомной задержки ~r16*delay
	lsr r16
	lsr r16
	ldi r17,0x0B	
	rcall DELAY							;Рандомная задержка ~r16*delay
	
	ldi r16,0xFF							;Зажигание сигнальных диодов(весь PORTC)
	out PORTC,r16							
	ldi r16,0x14							;Сигнальные диоды горят 2с
	rcall DELAY 
	ldi r16,0x00
	out PORTC,r16							;Сигнальные диоды гаснут

	pop r17
	pop r16
ret
