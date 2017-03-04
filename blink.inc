.include "delay.s"						


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
