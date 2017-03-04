TIM0_OVR:
	reti

INT0:
	push r18		;save this registers
	push r19
	push r20	

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME_IS_STARTED#0
	
	clr r1			;r1=0 ==> 1st player is ready
	
	mov r18, r2	
	cpi r18, 0x0
	brne EXIT_INT0
	
	clr r0
	
THE_GAME_IS_STARTED#0:

	in r18, PINC
	
	cpi r18,0xFF



EXIT_INT0:

	pop r20
	pop r19
	pop r18

	reti


INT1:
	push r18		;save this registers
	push r19
	push r20	

	mov r18, r0
	cpi r18, 0x0		;if r0 == 0 ==> game is started	
	breq THE_GAME_IS_STARTED#1
	
	clr r2			;r2=0 ==> 2nd player is ready
	
	mov r18, r1	
	cpi r18, 0x0
	brne EXIT_INT1
	
	clr r0
	
THE_GAME_IS_STARTED#1:





EXIT_INT1:

	pop r20
	pop r19
	pop r18

	reti
