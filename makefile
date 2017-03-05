PROJECT_NAME = bang

$(PROJECT_NAME) :
	avr-as -mmcu=atmega8535 -o $(PROJECT_NAME).o $(PROJECT_NAME).s
	avr-ld -o $(PROJECT_NAME).elf $(PROJECT_NAME).o
	avr-objcopy --output-target ihex $(PROJECT_NAME).elf $(PROJECT_NAME).hex
burn :
	avrdude -c usbasp -p m8535 -U flash:w:$(PROJECT_NAME).hex
clean :
	rm -f *.elf *.hex *.o