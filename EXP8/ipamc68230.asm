// Sub-rotina que programa a Porta A do MC 68230 (PI/T)
// para utilizar um teclado 4x4

// Declara os registradores do MC 68230 (PI/T)
typedef unsigned char BYTE;

// Registrador de Controle Geral do MC 68230
BYTE *const xPGCR = (BYTE* ) 0xFE8001; // MC 68230 - registrador de controle geral

// Registradores da Porta A do MC 68230
BYTE *const xPACR = (BYTE* ) 0xFE800D; // registrador de controle
BYTE *const xPADDR = (BYTE* ) 0xFE8005; // registrador de direção de dados
BYTE *const xPADR = (BYTE* ) 0xFE8011; // registrador de dados

// Registradores da Porta B do MC 68230
BYTE *const xPBCR = (BYTE* ) 0xFE800F; // registrador de controle
BYTE *const xPBDDR = (BYTE* ) 0xFE8007; // registrador de direção de dados
BYTE *const xPBDR = (BYTE* ) 0xFE8013; // registrador de dados

// Inicializa Porta A
void inicpia (void){
    *xPGCR = 0x80; // programa modo 2: PGCR7-6 = 1,0 - portas bidirecionais de 8 bits
    // PGCR5-0 = 0,0,0,0,0,0 (se utilidade)
    *xPACR = 0xA0; // submodo A
    *xPADDR = 0x0F; // programa direção da Porta A (0-3:saída, 4-7:entrada)
}