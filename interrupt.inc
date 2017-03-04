TIM0_OVR:
	reti

INT0:
	push r18		;save this registers

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME#0
	
	clr r1			;r1=0 ==> 1st player is ready
	
	mov r18, r2	
	cpi r18, 0x0
	brne EXIT_INT0
	
	clr r0

	rjmp EXIT_INT0

THE_GAME#0:

	in r18, PINC
	
	cpi r18, 0xFF		;if there is signal --> 1st won
	
	brne 2ND_WON		;else --> 2nd won
	
	lsl r16  		;00001111 --> 00011111
	inc r16
	
	out PORTA, r16

	rcall PUNISH_2

	mov r18, r16
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN
	
	rcall WIN

2ND_WON:
	lsl r17
	inc r17
	
	out PORTB, r17
	
	rcall PUNISH_1	

	mov r18, r17
	cpi r18, 0xFF
	brne EXIT_INT0		;if <8 ==> exit; else call WIN
	
	rcall WIN

EXIT_INT0:
	pop r18

	reti


INT1:
	push r18		;save this registers

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME#1
	
	clr r2			;r2=0 ==> 2nd player is ready
	
	mov r18, r1	
	cpi r18, 0x0
	brne EXIT_INT1
	
	clr r0
	
	rjmp EXIT_INT1

THE_GAME#1:
	in r18, PINC
	
	cpi r18, 0xFF		;if there is signal --> 2nd won
	
	brne 1ST_WON		;else --> 1st won
	
	lsl r17  		;00001111 --> 00011111
	inc r17
	
	out PORTB, r17

	rcall PUNISH_1

	mov r18, r17
	cpi r18, 0xFF
	brne EXIT_INT1		;if <8 ==> exit; else call WIN
	
	rcall WIN

1ST_WON:
	lsl r16
	inc r16
	
	out PORTA, r16
	
	rcall PUNISH_1	

	mov r18, r16
	cpi r18, 0xFF
	brne EXIT_INT1
	
	rcall

EXIT_INT1:
	pop r18

	reti
