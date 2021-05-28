// Experiencia 07 - Exemplo: Cronometro e Teste de Interrupçoes
// Para executar no simulador IDE68k
// Autor: Carlos E. Cugnasca
// I5: start/stop; I6: zera; I7: sai do programa
// I1, I2, I3: mostra no LED o estado da chave
// I4: le valor do slider e o envia ao terminal
// Cada interrupçao envia uma mensagem ao terminal
//
// Interrupçoes - autovetores
void *int1vec = 0x0064; // int 1
void *int2vec = 0x0068; // int 2
void *int3vec = 0x006C; // int 3
void *int4vec = 0x0070; // int 4
void *int5vec = 0x0074; // int 5
void *int6vec = 0x0078; // int 6
void *int7vec = 0x007C; // int 7

// Ponteiros para os dispositivos de E/S
unsigned short *const display = (unsigned short *) 0xE010; // display[0]: digito + a esquerda
unsigned long *const timer = (unsigned long *) 0xE040; // timer

// padrao de bits para o display de 7 segmentos: 0 - 9
unsigned short const bitpat[] = {0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F};
unsigned char *leds = 0xE003; // end. do array de LEDs
unsigned char *bar = 0xE007; // end. do display de barra
unsigned char *switches = 0xE001; // endereço das chaves
unsigned char *slider = 0xE005; // endereço das chaves
unsigned char chaveaux, estadochaves, conta, para, zera;
unsigned long counter = 0;
unsigned long aux, aux1, posslider;

char mens [] = "Ocorreu interrupcao ";
char mens4 [] = " Valor do Slider: ";
char mens5 [] = " Inicia/Para";
char mens6 [] = " Zera";
char mens7 [] = " Aborta o Programa";
char mensCRLF [] = "\r\n";

// SR so' pode ser alterado no modo supervisor:
// nivel da mascara de interrupcoes deve ser
// colocado antes da execucao do programa
// $2000: habilita todas ... $2600: apenas I7 (nao masc.)
void delay(void){ //atraso
    int i = 0;
    do {++i;}
    while (i < 30000);
}

void showslider(void){ // mostra slider
    _trap(15);
    _word(33);
}

void show7seg(void){ // mostra display 7-seg
    _trap(15);
    _word(35);
}

void showleds(void){ // mostra LEDs
    _trap(15);
    _word(31);
}

void showswitches(void){ // mostra chaves
    _trap(15);
    _word(32);
}

void showbar(void){ // mostra bar
    _trap(15);
    _word(34);
}

void clear7seg(void){ // limpa display 7-seg
    int i;
    for (i = 0; i < 3; i++) display[i] = 0; // limpa 1os. 3 dig.
    display[3] = bitpat[0];
} // ultimo dig.= '0'

void write7seg(long n, int i){ // escreve no display 7-seg (recursiva)
    if (n > 9) write7seg(n / 10, i - 1);
    display[i] = bitpat[n % 10];
}

void contar (void){ // realiza contagem
    long cntr = *timer / 10;
    (*bar)++; // incrementa display BAR
    delay(); // temporiza
    if (counter != cntr) { // timer mudou
        counter = cntr;
        write7seg(counter, 3);
    }
}

void CRLF (void){ // envia CR e LF ao terminal
    _A0 = mensCRLF; // A0: ponteiro para a string
    _trap(15);
    _word(7);
} // system call PRTSTR

void print (long num){ // envia numero ao terminal
    _D0 = num; // D0: numero com sinal para imprimir
    _trap(15);
    _word(5);
} // system call PRTNUM

void envmen (long ender) { // envia mensagem
    _A0 = ender; // A0: ponteiro para a string
    _trap(15);
    _word(7);
} // system call PRTSTR

interrupt void int1proc(void){ // le/atualiza so estado chave 1
    chaveaux = *switches & 0x02;
    estadochaves = ((estadochaves & 0xFD)|chaveaux);
    envmen (mens);
    print (1);
    CRLF ();
}

interrupt void int2proc(void){ // le/atualiza so estado chave 2
    chaveaux = *switches & 0x04;
    estadochaves = ((estadochaves & 0xFB)|chaveaux);
    envmen (mens);
    print (2);
    CRLF ();
} // CR e LF

interrupt void int3proc(void){ // le/atualiza so estado chave 3
    chaveaux = *switches & 0x08;
    estadochaves = ((estadochaves & 0xF7)|chaveaux);
    envmen (mens);
    print (3);
    CRLF ();
} // CR e LF

interrupt void int4proc(void){ // envia valor slider ao terminal
    envmen (mens);
    print (4);
    envmen (mens4);
    posslider = *slider;
    _D0 = posslider; // D0: numero com sinal para imprimir
    _trap(15);
    _word(5); // system call PRTNUM
    CRLF ();
} // CR e LF

interrupt void int5proc(void){ // inicia/para/continua contagem
    envmen (mens);
    print (5);
    envmen (mens5);
    CRLF (); // CR e LF
    if (conta == 0){ // esta parado, pedido de contagem
        conta = 1;
    }
    if (conta == 2){ // contando, pedido de parada
        conta = 3;
    }
    if (conta == 4){ // contando, pedido de parada
        conta = 1;
    }
}

interrupt void int6proc(void){ // zera contagem
    envmen (mens);
    print (6);
    envmen (mens6);
    CRLF (); // CR e LF
    zera = 1;
}

interrupt void int7proc(void){ // termina o programa
    envmen (mens);
    print (7);
    envmen (mens7);
    CRLF ();
    _trap(15); // aborta o Programa
    _word(0);
} // system call EXIT

int pausa = 0;

// Programa Principal
void main(void){
    // carrega enderecos das sub-rotinas de trat. int. no vetor
    *int1vec = int1proc;
    *int2vec = int2proc;
    *int3vec = int3proc;
    *int4vec = int4proc;
    *int5vec = int5proc;
    *int6vec = int6proc;
    *int7vec = int7proc;

    showslider(); // mostra slider
    showleds(); // mostra LEDs
    showswitches(); // mostra chaves
    showbar(); // mostra bar
    show7seg(); // mostra display 7-seg
    clear7seg(); // limpa display 7-seg

    conta = 1; // estado do contador
    zera = 0; // zerar contador
    *timer = 0; // inicializa timer
    counter = 0; // valor do coontador
    aux, aux1 = 0; // variaveis auxiliares

    for (;;) {
        *leds = estadochaves; // atualiza estado das chaves
        if (zera == 1){ // pedido para zerar:
            zera = 0; // limpa pedido de zerar
            *timer = 0; // zera timer
            counter = 0; // zera contador
            aux = 0;
            aux1 = 0;
            write7seg(counter, 3); // atualiza display com 0s
            clear7seg();
        } // limpa display
        else if (*switches & 0x01 && pausa == 0) {
            pausa = 1;
            if (conta == 2){ // contando, pedido de parada
                conta = 3;
            }
            if (conta == 4){ // contando, pedido de parada
                conta = 1;
            }
        } else if (!(*switches & 0x01) && pausa == 1) {
            pausa = 0;
            if (conta == 2){ // contando, pedido de parada
                conta = 3;
            }
            if (conta == 4){ // contando, pedido de parada
                conta = 1;
            }
        }
        else {
            if (conta == 1) {  // inicio de parada
                conta = 2; // estado = parado
                aux = *timer; // salva valor do timer
                aux1 = counter;
            } // salva valor do contador
            if (conta == 2) { // parado
            } // nada faz
            if (conta == 3){ // voltando a contar contar
                conta = 4; // estado = contado
                *timer = aux; // restaura valor do timer
                counter = aux1; // restaura valor do contador
                contar();
            } // contar
            if (conta == 4){ // contando
                contar();
            } // contar
        }
        if (counter == 10000)
            break; // para apos contar ate 9999
    }
}