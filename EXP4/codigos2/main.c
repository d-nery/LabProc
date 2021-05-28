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

#define BTNS_PORT *PBDR
#define CLE       0
#define CLD       1
#define TECL1     3
#define TECL2     4

#define DELAY_MIN 0x000004BF
#define DELAY_MAX 0xFFFFFFFF

#define DELAY 0x05BF

void init();

void direita(long delay);
void esquerda(long delay);

void delay(long d);

int passo_atual = 0;
int posicao1 = 0;
int posicao2 = 0;

void main() {
    //_trap(15); // Simulation
    //_word(31);
    //_trap(15); // Simulation
    //_word(32);

    init();
    MOTOR_PORT = 0;

    for (;;) {
        // Letra P
        // if (BTNS_PORT & (1 << TECL1)) {
        //     esquerda(DELAY);
        //  passo_atual--;
        //     LEDS_PORT |= (1 << L1);
        // } else if (BTNS_PORT & (1 << TECL2)) {
        //     direita(DELAY);
        //  passo_atual++;
        //     LEDS_PORT |= (1 << L2);
        // } else {
        //     LEDS_PORT = 0;
        // }
        // _D0 = passo_atual;

        // Letra Q
        // while (!(BTNS_PORT & (1 << CLD))) {
        //     esquerda(DELAY);
        //     LEDS_PORT |= (1 << L1);
        // }
        // LEDS_PORT = 0;
        // while (!(BTNS_PORT & (1 << CLE))) {
        //     direita(DELAY);
        //     LEDS_PORT |= (1 << L2);
        // }

        // 6.3 3a etapa
        posicao1 = 0;
        posicao2 = 0;
        passo_atual = 0;

        while (!(BTNS_PORT & (1 << TECL1))); // Espera tecla1 ser apertada

        LEDS_PORT |= (1 << L1);              // Sinaliza memorização da tecla1
        posicao1 = passo_atual;

        while (posicao2 == 0) {              // Anda enquanto nao tem posicao 2
            while (!(BTNS_PORT & (1 << CLD))) {
                esquerda(DELAY);
                passo_atual--;

                if (BTNS_PORT & (1 << TECL2)) {
                    posicao2 = passo_atual;
                    LEDS_PORT |= (1 << L2);  // Sinaliza memorização da tecla2
                    break;
                }
            }

            while (!(BTNS_PORT & (1 << CLE)) && posicao2 == 0) {
                direita(DELAY);
                passo_atual++;

                if (BTNS_PORT & (1 << TECL2)) {
                    posicao2 = passo_atual;
                    LEDS_PORT |= (1 << L2);
                    break;
                }
            }
        }

        while (passo_atual > posicao1) {   // anda ate chegar na posicao1
            esquerda(DELAY);
            passo_atual--;
        }

        while (passo_atual < posicao1) {
            direita(DELAY);
            passo_atual++;
        }
        MOTOR_PORT = 0; // Para e termina
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

void direita(long _delay) {
    MOTOR_PORT |=   (1 << MOTOR_ORANGE) | (1 << MOTOR_BLACK);
    MOTOR_PORT &= ~((1 << MOTOR_YELLOW) | (1 << MOTOR_BROWN));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_ORANGE) | (1 << MOTOR_BROWN);
    MOTOR_PORT &= ~((1 << MOTOR_YELLOW) | (1 << MOTOR_BLACK));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_YELLOW) | (1 << MOTOR_BROWN);
    MOTOR_PORT &= ~((1 << MOTOR_ORANGE) | (1 << MOTOR_BLACK));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_YELLOW) | (1 << MOTOR_BLACK);
    MOTOR_PORT &= ~((1 << MOTOR_ORANGE) | (1 << MOTOR_BROWN));
    delay(_delay);
}

void esquerda(long _delay) {
    MOTOR_PORT |=   (1 << MOTOR_YELLOW) | (1 << MOTOR_BLACK);
    MOTOR_PORT &= ~((1 << MOTOR_ORANGE) | (1 << MOTOR_BROWN));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_YELLOW) | (1 << MOTOR_BROWN);
    MOTOR_PORT &= ~((1 << MOTOR_ORANGE) | (1 << MOTOR_BLACK));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_ORANGE) | (1 << MOTOR_BROWN);
    MOTOR_PORT &= ~((1 << MOTOR_YELLOW) | (1 << MOTOR_BLACK));
    delay(_delay);

    MOTOR_PORT |=   (1 << MOTOR_ORANGE) | (1 << MOTOR_BLACK);
    MOTOR_PORT &= ~((1 << MOTOR_YELLOW) | (1 << MOTOR_BROWN));
    delay(_delay);
}

void delay(long d) {
    while(d--);
}
