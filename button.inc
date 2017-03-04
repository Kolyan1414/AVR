BUTTON_TAP:
	in r18,PINC
	ANDI r18,0x7		;mask for last 3 bits
	breq out_button_tap	;all bits are 0, ==> ret
	
	mov r20,r18
	ANDI r20,0x4		;100
	brne RESET			;there are 1, its 3d button ==> reset
	
	mov r20,r18			;1st + 2nd
	ANDI r20,0x3		;mask 011	
	cpi r20,0x3
	breq skip			;draw
	
	mov r20,r18			;1st or 2nd?	010
	ANDI r20,0x2		;2nd
	breq 1st_cmp		

	cpi r21,0x1
	brne 2nd_lose

	inc r17
	cpi r17,0xFF
	ret
