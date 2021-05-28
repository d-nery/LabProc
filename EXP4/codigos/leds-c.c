// LEDS-C.C - Light 4 LEDs in sequence
// To run this program in the 68000 Visual Simulator, you must enable the
// LED's windows from the Peripherals menu and adjust its address to FE8011.
// The 'const' qualifier makes sure that the pointer 'leds'
// are stored in ROM.
// Although this program can be run in Single-step and Auto-step mode,
// Run mode is preferred.
// Based on Cswitches of: Peter J. Fondse (pfondse@hetnet.nl)
// Authors: Andre Hirakawa & Danilo Miguel & Carlos Cugnasca

typedef unsigned char BYTE;

BYTE *const PGCR = (BYTE* ) 0xFE8001; //INICIALIZAÇÃO GERAL
BYTE *const PACR = (BYTE* ) 0xFE800D; //INICIALIZAÇÃO SUBMODO
BYTE *const PADDR = (BYTE* ) 0xFE8005; //INICIALIZAÇÃO DIREÇÃO
BYTE *const leds = (BYTE* ) 0xFE8011; //ENDEREÇO DA PORTA A

void main() {
    long i;

    // activate I/O devices for simulation
    _trap(15);
    _word(32); // show LEDs

    *PGCR = 0x30;
    *PACR = 0xA0;
    *PADDR = 0xFF;

    for (;;) {
        *leds = 0x01;
        espera (20000);

        *leds = 0x02;
        espera (20000);

        *leds = 0x04;
        espera (20000);

        *leds = 0x08;
        espera (20000);
    }
}

void espera (long i) {
    long j;
    for(j=0 ; j <= i; j++);
}
