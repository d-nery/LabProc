/**
 * Laboratorio de Microprocessadores
 * Experiência 5
 */

#include "m68_io.h"

void main() {
    unsigned int num1 = 0, num2 = 0, digito;
    int i = 0;

    puts("Numero 1 (8 digitos): ");

    num1 = getnum();
    puts("\r\nNumero digitado: ");
    printnum(num1);

    puts("\r\nNumero 2 (8 digitos): ");

    num2 = getnum();
    puts("\nNumero digitado: ");
    printnum(num2);

    num1 += num2;
    if (num1 > 99999999)
        puts("\r\nOverflow!");

    num1 %= 100000000;

    puts("\r\nResultado: ");
    printnum(num1);

    exit();
}
