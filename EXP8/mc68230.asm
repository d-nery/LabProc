; Declara os registradores do MC 68230 (PI/T)
; Registrador de Controle Geral do MC 68230

PGCR       equ $FE8001 ; registrador de controle geral

; Registradores da Porta A do MC 68230
PBACR      equ $FE800D ; Porta A - registrador de controle
PADDR      equ $FE8005 ; Porta A - registrador de direção de dados
PADR       equ $FE8011 ; Porta A - registrador de dados

; Registradores da Porta B do MC 68230
PGCR       equ $FE8001 ; registrador de controle geral
PBCR       equ $FE800F ; Porta B - registrador de controle
PBDDR      equ $FE8007 ; Porta B - registrador de direção de dados
PBDR       equ $FE8013 ; Porta B - registrador de dados

; Registradores do Timer do MC 68230
timevec    equ $1D ; Placa SDC68k: interrup. timer = nível 5

; posição 29D ($1D) na tabela
PIT        equ $FE8000 ; endereço base da PI/T na SBC68K
TCR        equ $21 ; offset p/ o reg. contr. timer
TIVR       equ $23 ; offset p/ o reg. do vetor interr. timer
CPR        equ $25 ; offset p/ o reg. de precarga do contador
TSR        equ $35 ; offset p/ o reg. status timer
TIME       equ $4*timevec ; posiçao da sub-rotina trat. inter. no vetor interr.