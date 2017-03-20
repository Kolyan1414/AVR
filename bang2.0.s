;Инициализация
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

;Interrupts
	nop;				;0 rjmp RESET
	rjmp INT0			;1
	rjmp INT1			;2
	nop					;3
	nop					;4
	nop					;5
	nop					;6
	nop					;7
	nop					;8
	nop					;9
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

;Начальные установки(вход/выход, стек, таймер и проч)
	ldi r16, 0x2 		;setting stack pointer
	out SPH, r16
	ldi r16, 0x5F
	out SPL, r16

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

	ldi r16,0x01		;Запуск таймера (на вход поступает тактовая частота)
	out TCCR0,r16	

	ldi r16,0x00		;Запрет обработки прерываний таймера
	out TIMSK,r16		
	
	ldi r16,0xC0 		;r16=11000000
	out GICR, r16		;allow interrupt int1/0

	ldi r16, 0x0A		;Выработка прерывания при переходе от высокого уровня к низкому
	out MCUCR, r16

	cli					;bun interrupt global

NEW_GAME:
	ldi r30, 0x00		;Обнуление счета
	ldi r31, 0x00

	NEW_ROUND:
		ldi r16, 0xFF
		mov r1, r16	;PORTA не потушен кнопкой
		mov r2, r16	;PORTB не потушен кнопкой

		ldi r16, 0x00
		mov r0, r16	;Игроки к игре не готовы(0й бит - игрок A, 1й бит - игрок В)
		mov r4, r16	;BOOT_LED не активен

		rcall SHOW_SCORE				;Показывать счет в течение 2с
		ldi r20, 0xA0
		rcall DELAY
		
		clr r16							;Очистка буфера прерываний int1/int0
		out GIFR, r16
		sei 							;Разешение прерываний
	
		rcall BOOT_LED	
		clr r16				;"ПРОБЕГАНИЕ ДИОДОВ" до тех пор пока игроки не объявят о готовности
		mov r4, r16					;BOOT_LED не активен

		cli
		clr r16
		out GICR, r16
		ldi r20, 0x01
		rcall DELAY

		ser r16
		mov r0, r16					;Игроки к игре готовы

		clr r16							;Очистка буфера прерываний int1/int0
		out GIFR, r16
		ldi r16,0xC0 		;r16=11000000
		out GICR, r16		;allow interrupt int1/0
		sei	
		clr r16							;Очистка буфера прерываний int1/int0
		out GIFR, r16

		rcall RANDOM


TAP:
pop r17
pop	r17
clr r17
out PORTC, r17  		;Потушить сигнаьлные диоды
		
cpi r30, 0xFF			;Если один из игроков набрал 8 очков,
breq NEW_GAME			;то игра начинается заново
cpi r31, 0xFF	
breq NEW_GAME

	rjmp NEW_ROUND		;Начинается новый раунд


;!!!ПРЕРЫВАНИЯ
;"ПРЕРЫВАНИЕ_0"
INT0:
	ser r16
	cp r4, r16 		;Активен ли BOOT_LED?
	brne READY0	
		clr r16		;Нет - проверка на готовность играть
		mov	r1, r16
		ldi r17, 0x80
		out GICR, r17
		reti

	READY0:
		ser r16
		cp r0, r16 	;Готовы ли игроки к игре?
		brne RI0 		;Нет - вернуться к исполнению программы
			in r16, PINC
			cpi r16, 0x00 				;Горит ли PORTC?	
			breq MINUS0					;Нет - снять очко у игрока А
				lsl r30						;Да - добавить очко игроку А
				ori r30, 0x01
				cli
				rjmp TAP
MINUS0:
	rcall PUNISH1
	cpi r30, 0x00
	breq MIN0
		lsr r30
	MIN0:
		cli
		rjmp TAP
RI0:
	reti

;"ПРЕРЫВАНИЕ_1"
INT1:
	ser r16
	cp r4, r16 		;Активен ли BOOT_LED?
	brne READY1	
		clr r16		;Нет - проверка на готовность играть
		mov	r2, r16
		ldi r17, 0x40
		out GICR, r17
		reti

	READY1:
		ser r16
		cp r0, r16 	;Готовы ли игроки к игре?
		brne RI1		;Нет - вернуться к исполнению программы
			in r16, PINC
			cpi r16, 0x00 				;Горит ли PORTC?	
			breq MINUS1					;Нет - снять очко у игрока А
				lsl r31						;Да - добавить очко игроку А
				ori r31, 0x01
				cli
				rjmp TAP
MINUS1:
	rcall PUNISH2
	cpi r31, 0x00
	breq MIN1
		lsr r31
	MIN1:
		cli
		rjmp TAP
RI1:
	reti



;!!!ФУНКЦИИ

;!"ЗАДЕРЖКА" на r20*25ms
;требует инициализации r20 (r20 зарезервирован для работы с DELAY) 
DELAY:				;25ms when r20 = 0x01								
	push r19 		
	push r18
	push r20

	ldi r19, 0xFF

	for1:
		ldi r18, 0xF0
		for2:
			pop r20
			push r20
			for3:
				dec r20
				brne for3
			dec r18
		brne for2
		dec r19
	brne for1

	pop r20
	pop r18
	pop r19
ret

;!"ПРОБЕГАНИЕ ДИОДОВ" PORTB, PORTA
BOOT_LED:
	ser r16
	mov r4, r16		;Активация BOOT_LED
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
	ldi r20, 0x03
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
	sei
	breq EXIT

	rjmp CYCLE
EXIT:
	cli
	clr r16							;Очистка буфера прерываний int1/int0
	out GIFR, r16
ret

;!"РАНДОМ" зажигает PORTC c заранее не известной задержкой
RANDOM:					;Подает сигнал к началу раунда с задержкой 1.6+random с
	
	in r17,TCNT0			;Считываем время из таймера

	rcall CSR17				;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2
	rcall CSR17 			;Multiplies r17 by 2
	lsr r17
	mov r20, r17
	rcall DELAY
	ldi r20, 0x28
	rcall DELAY

	ldi r17, 0x20			;Зажигание сигнальных диодов(весь PORTC) на 2,4 с
	out PORTC, r17
	ldi r20, 0x60
	rcall DELAY
	clr r17
	out PORTC, r17			;Сигнальные диоды гаснут

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

SHOW_SCORE:
	out PORTA, r30
	out PORTB, r31
ret

PUNISH1:
	push r17

	ldi r17, 0x08
	out PORTC, r17

	ldi r20, 0x01
	rcall DELAY

	clr r17
	out PORTC, r17

	pop r17
	ret

PUNISH2:
	push r17

	ldi r17, 0x10
	out PORTC, r17

	ldi r20, 0x01
	rcall DELAY

	clr r17
	out PORTC, r17

	pop r17
	ret
