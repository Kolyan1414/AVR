.include "delay.s"

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
