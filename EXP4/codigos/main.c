/**
 * Laboratorio de Microprocessadores
 * Experiência 4
 */

#include "m68_io.h"

#define MOTOR_PORT    *PADR
#define MOTOR_YELLOW  0
#define MOTOR_BROWN   1
#define MOTOR_ORANGE  2
#define MOTOR_BLACK   3

#define LEDS_PORT *PADR
#define L1        4
#define L2        5

#define BTNS_PORT *PABR
#define CLE       0
#define CLD       1
#define TECL1     3
#define TECL2     4

void init();
void delay(long d);

void main() {
    _trap(15); // Simulation
    _word(31);
    _trap(15); // Simulation
    _word(32);

    init();
    MOTOR_PORT = 0;

    for (;;) {
        MOTOR_PORT = (1 << MOTOR_ORANGE) | (1 << MOTOR_BLACK);
        delay(0x7FFF);
        MOTOR_PORT = (1 << MOTOR_ORANGE) | (1 << MOTOR_BROWN);
        delay(0x7FFF);
        MOTOR_PORT = (1 << MOTOR_YELLOW) | (1 << MOTOR_BROWN);
        delay(0x7FFF);
        MOTOR_PORT = (1 << MOTOR_YELLOW) | (1 << MOTOR_BLACK);
        delay(0x7FFF);
    }
}

void init() {
    *PGCR = 0x30;   // Unidirectional 8-bit mode | H34 and H12 enabled

    // Initilize port A
    *PACR = 0xA0;   // Submode 1X, Bit I/O | Output Pin - negated, H2S always cleared
    *PADDR = 0xFF;  // All port pins as output

    // Initialize port B
    *PBCR = 0xA0;
    *PBDDR = 0x00;  // All port pins as input
}

void delay(long d) {
    while(d--);
}
