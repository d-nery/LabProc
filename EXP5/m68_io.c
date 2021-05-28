#include "m68_io.h"

#define IDE68K 0

creg_t PGCR =  _addr8(0x00);     // Port General Control Register
creg_t PSRR =  _addr8(0x01);     // Port Service Request Register

// Port X Data Direction Registers
creg_t PADDR = _addr8(0x02);
creg_t PBDDR = _addr8(0x03);
creg_t PCDDR = _addr8(0x04);

creg_t PIVR =  _addr8(0x05);    // Port Interrupt Vector Register

// Port X Control Registers
creg_t PACR =  _addr8(0x06);
creg_t PBCR =  _addr8(0x07);

// Port X Data Registers
creg_t PADR =  _addr8(0x08);
creg_t PBDR =  _addr8(0x09);
creg_t PCDR =  _addr8(0x0C);

// Port X Alternate Register
creg_t PAAR =  _addr8(0x0A);
creg_t PBAR =  _addr8(0x0B);

creg_t PSR  =  _addr8(0x0D);    // Port Status Register
creg_t TCR  =  _addr8(0x10);    // Timer Control Register
creg_t TIVR =  _addr8(0x11);    // Timer Interrupt Vecto Register

// Counter Preload Register High, Middle, Low
creg_t CPRH =  _addr8(0x13);
creg_t CPRM =  _addr8(0x14);
creg_t CPRL =  _addr8(0x15);

// Count Register High, Middle, Low
creg_t CNTRH = _addr8(0x17);
creg_t CNTRM = _addr8(0x18);
creg_t CNTRL = _addr8(0x19);

creg_t TSR   = _addr8(0x1A);    // Timer Status Register

void putc(char c) {
    _D0 = c;
#if IDE68K == 1
    _trap(15);
    _word(1);
#else
    _D7 = 248;
    _trap(14);
#endif
}

char* gets() {
    char buff[64];
#if IDE68K == 1
    _A0 = buff;
    _trap(15);
    _word(8);
#else
    char c;
    int count = 0;
    do {
        c = getc(1);
        buff[count++] = c;
    } while (c != '\n');
    buff[count] = '\0';
    _D0 = count;
#endif
    return buff;
}

char getc(int echo) {
#if IDE68K == 1
    if (echo) {
        _trap(15);
        _word(2);
    } else {
        _trap(15);
        _word(3);
    }
#else
    _D7 = 247;
    _trap(14);
#endif
    return _D0;
}

void printnum(int num) {
#if IDE68K == 1
    _D0 = num;
    _trap(15);
    _word(5);
#else
    char buff[8];
    int i;

    _D0 = num;
    _A6 = buff;
    _D7 = 236;
    _trap(14);
    for (i = 7; i >= 0; i++) {
        putc(buff[i]);
    }
#endif
}

int getnum(void) {
#if IDE68K == 1
    _trap(15);
    _word(6);
#else
    char* n = gets();
    int num = 0;
    int i, qtd = _D0;
    for (i = 0; i < qtd; i++) {
        _A5 = &n[i];
        _A6 = &n[i] + 1;
        _D7 = 226;
        _trap(14);

        num *= 10;
        num += _D0;
    }
    return num;
#endif
    return _D0;
}

void puts(char* str) {
#if IDE68K == 1
    _A0 = str;
    _trap(15);
    _word(7);
#else
    while (str != '\0') {
        putc(*str);
        str++;
    }
#endif
}

void exit(void) {
#if IDE68K == 1
    _trap(15);
    _word(0);
#else
    _D7 = 228;
    _trap(14);
#endif
}
