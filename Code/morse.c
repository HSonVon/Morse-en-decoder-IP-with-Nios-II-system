/*
 * morse.c
 *
 *  Created on: 26 Dec 2024
 *      Author: USER
 */


#include <sys/alt_stdio.h>
#include <unistd.h>
#include "system.h"
#include "altera_avalon_pio_regs.h"
#include <io.h>
#include <stdint.h>
#include <stdio.h>

const int table[12] = {0x32,0x30,0x32,0x30,0x30,0x33,0x33,0x31,0x20,0x73,0x4F,0x43};

void delay_ms(uint32_t ms) {
    volatile uint32_t count;
    while (ms--) {
        for (count = 0; count < 1000; count++) {
        }
    }
}
void SendCommand (alt_u8 cmd){
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO_BASE, 0x0100 | cmd);
	delay_ms(40);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO_BASE, 0x0000 | cmd);
	delay_ms(40);
}
void SendData (alt_u8 data){
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO_BASE, 0x0500 | data);
	delay_ms(40);
	IOWR_ALTERA_AVALON_PIO_DATA(GPIO_BASE, 0x0400 | data);
	delay_ms(40);
}
int main()
{

	SendCommand(0x01);
	SendCommand(0x38);
	SendCommand(0x000F);
	SendCommand(0x0001);
	SendCommand(0x0006);
	SendCommand(0x80);
	for(int i=0; i<12; i++){
		SendData(table[i]);
	}
	SendCommand(0xC0);

	while (1) {
		unsigned int btn = IORD(BUTTON_BASE, 0) ;
		//IOWR(MORSE_HW_0_BASE, 3, bit_cnt);
		//IOWR(MORSE_HW_0_BASE, 2, reg);
		IOWR(MORSE_HW_0_BASE, 0, (btn & 0x3));
		unsigned int reg_val = IORD(MORSE_HW_0_BASE, 1);
		unsigned int bit_val = IORD(MORSE_HW_0_BASE, 2);
		unsigned int ascii_code = IORD(MORSE_HW_0_BASE , 3);
		unsigned int mode = IORD(MORSE_HW_0_BASE, 0);
		if (mode == 0) {
			if (((btn & 0b100) >> 2) == 0) {
				SendData(ascii_code);
				printf("Mode work: 0x%X\n", mode);
				printf("setup: 0x%X\n", reg_val);
				printf("bit set: 0x%X \n", bit_val);
				printf("ASCII code: 0x%X \n\n", ascii_code);
			}
		} else if (mode == 1) {
			//unsigned int ascii = IORD(MORSE_HW_0_BASE , 5);
			if (((btn & 0b100) >> 2) == 0) {
				SendData(ascii_code);
				printf("Hold mode work: %X\n", mode);
				printf("Hold reg: 0x%X \n", reg_val);
				printf("Hold bit: 0x%X \n", bit_val);
				printf("Hold ASCII code: 0x%X \n\n", ascii_code);
			}
		}
	}

}







