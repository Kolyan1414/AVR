bang :
	avr-as -mmcu=atmega8535 -o bang.o bang.s
	avr-ld -o bang.elf bang.o
	avr-objcopy --output-target ihex bang.elf bang.hex