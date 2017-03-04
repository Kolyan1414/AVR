bang :
	avr-as -mmcu=atmega8535 -o bang.o bang.s
	avr-ld -o bang.elf bang.o
	avr-objcopy --output-target ihex bang.elf bang.hex
burn :
	avrdude -c usbasp -p m8535 -U flash:w:bang.hex