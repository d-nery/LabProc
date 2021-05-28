/**
 * Laboratorio de Microprocessadores
 * Experiência 5
 */

#include "m68_io.h"

void main() {
    unsigned int num1 = 0, num2 = 0;
    char buff[64];
    char c;

    //puts("ola");

    puts("Numero 1 (8 digitos): ");

    gets(buff);
    puts("\r\nNumero digitado: ");
    c = buff[0];
    putc(c);
    //printnum(num1);

    //puts("\r\nNumero 2 (8 digitos): ");

    //gets(buff);
    //puts("\nNumero digitado: ");
    //puts(buff);
    //printnum(num2);

    //num1 += num2;
    //if (num1 > 99999999)
    //    puts("\r\nOverflow!");

    //num1 %= 100000000;

    //puts("\r\nResultado: ");
    //printnum(num1);

    exit();
}