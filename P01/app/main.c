#include "utils_ctboard.h"

#define Switches7 0x60000200
#define LED7 0x60000100
#define Rotary 0x60000211
#define DS0 0x60000110

uint8_t numbers[16] = {0x3F,0x06,0x5b,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f,  0x77, 0x7C,0x39, 0x5e, 0x79, 0x71};

int main(void) {
	while (1) {
		//led lights and switches
		uint32_t data_byte = read_word(Switches7);
		write_word( LED7, data_byte);
		
		uint8_t rotary = read_byte(Rotary);
		rotary = rotary & 0x0F;
		write_byte(DS0, ~numbers[rotary]);
	} 
}
