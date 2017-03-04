.EQU SREG,0x3F		;STATUS REG.
.EQU SPH,0x3E		;ST.POINTER(HIGH)
.EQU SPL,0x3D		;ST.POINTER(LOW)

.EQU TIMSK,0x39		;TIME COUNT OUTPUT COMPARE MATH INTERRUPT ENAB
.EQU TCCR0,0x33		;TIME COUNTER CONTROL REG.
.EQU TCNT0,0x32		;T/C FLAG REG			!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
.EQU OCR0,0x3C		;TOP

.EQU PORTA,0x1B		;=porta is 1st player points
.EQU DDRA,0x1A
.EQU PINA,0x19

.EQU PORTB,0x18		;porta is 2nd player points
.EQU DDRB,0x17
.EQU PINB,0x16

.EQU PORTC,0x15
.EQU DDRC,0x14
.EQU PINC,0x13

rjmp RESET		;0
nop			;1
nop			;2
nop			;3
nop			;4
nop			;5
nop			;6
nop			;7
nop			;8
rjmp TIM0_OVR		;9	
nop			;a
nop			;b
nop			;c
nop			;d
nop			;e
nop			;f
nop			;10
nop			;11
nop			;12
nop			;13
nop			;14
nop			;15

main:
	nop
	rjmp main

RESET:			;start SETTING PROG
	ldi r16,0x2
	out SPH,r16
	
	ldi r16,0x5F
	out SPL,r16



	ser r16		;r16=11111111
	out DDRA,r16	;ALL PORTA IS OUTP.
	out DDRB,r16	;ALL PORTB IS OUTPUT
	
	ldi r16,0x0
	out PORTA,r16	;off
	out PORTB,r16	;off
	
	ldi r17,0xF8	;11111000 1st, 2nd and 3d are inrut, other is output
	out DDRC,r17
	
	ldi r17,0x7	;00000111; diods off, buttons +vcc
	out PORTC,r17	;resistor +vcc подт€гивающий резистор. да, так можно. нет, это не кз.


	
	ldi r16,0x8	;TOP is 8 <==> 1 ms 
	out OSR0,r16

	ldi r16,0xD	;00001101 == cs/1024; 2nd режим работы
	out TCCR0,r16	;interrupt in 1ms

	ldi r16,0x1	;00000001
	out TIMSK,r16	;allow interrupt t0

	sei		;allow interrupt global



	clr r17		;players status
	mov r16,r17	;1st and 2nd

	rjmp main

TIM0_OVR:
	rcall BUTTON_TAP
	reti

BUTTON_TAP:
	in r18,PINC
	ANDI r18,0x7		;mask for last 3 bits
	breq out_button_tap	;all bits are 0, ==> ret
	
	mov r20,r18
	ANDI r20,0x4		;100
	brne RESET		;there are 1, its 3d button ==> reset
	
	mov r20,r18		;1st + 2nd
	ANDI r20,0x3		;mask 011	
	cpi r20,0x3
	breq skip		;draw
	
	mov r20,r18		;1st or 2nd?	010
	ANDI r20,0x2		;2nd
	breq 1st_cmp		

	cpi r21,0x1
	brne 2nd_lose

	inc r17
	cpi r17,0xFF
	=
	
2nd_lose:
	rcal PUNISH_2
	rcal BLINK

	inc 16

1st_cmp:



skip:
	rcall BLINK

out_button_tap:
	ret

BLINK:
	cli	;glob interrupt disable

;blink 3 times
	sei	;gl int enable
	ret

random:
	ret
PUNISH_1:
	ret
PUNISH_2:
	ret
