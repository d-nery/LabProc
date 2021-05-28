// Experiencia 06 - 6.2 - Entrada de comando ou dado
// Para executar no simulador

/* #define S1 '1' // para o caso de digitar código de comando
#define S2 '2' // para o caso de digitar código de caracter

void main()
{
    char ENTRADA; // variavel que armazena comando inicial do usuario
    char COMANDO[2]; // variavel que armazena comando em hexadecimal
    char CARACTERE[2]; //variavel que armazena caractere em hexadecimal
    int i;

    _A0 = "1. Enviar Comando \n2. Enviar Dado\nDigite a opção:\r\n"; // A0: ponteiro para a string
    _trap(14);
    _word(7); // system call PRTSTR

    ENTRADA= _D0;

    if (ENTRADA == S1) {
	    _A0 = "\r\n\Digite o código do Comando(em hexadecimal):\r\n"; // A0: ponteiro para a string
        _trap(14);
        _word(7); // system call PRTSTR

        for (i = 0; i <= 2; ++i) // pega digitos do comando
        {
            _trap(14);
            _word(3); // system call GETCH
            COMANDO[i] = _D0;
            _A0 = "*"; // A0 is pointer to string
            _trap(14);
            _word(7); // system call PRTSTR
        }
    }



    else {


        _A0 = "\r\n\Digite o código do Caractere(em hexadecimal):\r\n"; // A0: ponteiro para a string
        _trap(14);
        _word(7); // system call PRTSTR

        for (i = 0; i <= 2; ++i) // pega digitos do caractere
        {
            _trap(14);
            _word(3); // system call GETCH
            CARACTERE[i] = _D0;
            _A0 = "*"; // A0 is pointer to string
            _trap(14);
            _word(7); // system call PRTSTR
        }
    }

    _trap(14);
    _word(0); // system call EXIT PROGRAM
} */
