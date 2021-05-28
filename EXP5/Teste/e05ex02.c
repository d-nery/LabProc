// Experiencia 05 - Exemplo 02 - entrada de n.USP e senha
// Para executar no simulador
// Author: Carlos E. Cugnasca

#define S1 '1' // 1o. digito da senha
#define S2 '2' // 2o. digito da senha
#define S3 '3' // 3o. digito da senha
#define S4 '4' // 4o. digito da senha

void main()
{
    char CPWD[4]; // variaveis que armazenam digitos da senha
    int i;

    _A0 = "Digite o seu n. USP com 6 caracteres:\r\n"; // A0: ponteiro para a string
    _trap(15);
    _word(7); // system call PRTSTR

    for (i = 0; i <= 5; ++i) // pega 6 digitos do n.USP
    {
        _trap(15);
        _word(2); // system call GETCHE
    }

    _A0 = "\r\n\Digite a sua senha com 4 caracteres:\r\n"; // A0: ponteiro para a string
    _trap(15);
    _word(7); // system call PRTSTR

    for (i = 0; i <= 3; ++i) // pega 4 digitos da senha
    {
        _trap(15);
        _word(3); // system call GETCH
        CPWD[i] = _D0;
        _A0 = "*"; // A0 is pointer to string
        _trap(15);
        _word(7); // system call PRTSTR
    }
    // verifica se a senha esta correta
    if ((CPWD[0]==S1)&&(CPWD[1]==S2)&&(CPWD[2]==S3)&&(CPWD[3]==S4))
    {
        _A0 = "\r\n\Senha Correta\r\n"; // A0: ponteiro para a string
        _trap(15);
        _word(7); // system call PRTSTR
    }
    else
    {
        _A0 = "\r\n\Senha Incorreta\r\n"; // A0: ponteiro para a string
        _trap(15);
        _word(7); // system call PRTSTR
    }

    _trap(15);
    _word(0); // system call EXIT PROGRAM
}
