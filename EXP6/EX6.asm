; Experiencia 06 - Exemplo: Teste do Módulo LCD
; Para executar na Placa Experimental
; Author: Carlos E. Cugnasca
; Este programa exibe uma mensagem em cada linha do Módulo LCD duas vezes e solicita ao
; usuário digitar 1 para repetir o teste, ou qualquer tecla para retornar ao Programa Tutor


; Funções TRAP #14: número da função deve ser colocado em d7
TUTOR equ 228 ; função que retorna ao Programa Tutor
INCHE equ 247 ; funcao que pega um caractere do teclado
OUTCH equ 248 ; funcao que envia um caractere para a tela
OUTPUT equ 243 ; funcao que envia uma string para a tela
OUT1CR equ 227 ; funcao que envia CR e LF ao terminal

; Endereços de Registradores do MC68230
PGCR equ $FE8001 ; registrador de controle geral
PACR equ $FE800D ; Porta A - registrador de controle
PBCR equ $FE800F ; Porta B - registrador de controle
PADDR equ $FE8005 ; Porta A - registrador de direção de dados
PBDDR equ $FE8007 ; Porta B - registrador de direção de dados
PADR equ $FE8011 ; Porta A - registrador de dados
PBDR equ $FE8013 ; Porta B - registrador de dados

; Códigos de configuração do módulo LCD
LCD2L5X7 equ $38 ; LCD 2 linhas 5 X 7
LIMLCD equ $01 ; Limpa Display e Retorna o Cursor
HOME equ $02 ; Coloca Cursor na Posição Inicial (Home)
LCDOFF equ $08 ; Display Apagado
CESQ equ $10 ; Desloca somente o Cursor para a Esquerda
CMESQ equ $18 ; Desloca o Cursor e a Mensagem para a Esquerda
CDIR equ $14 ; Desloca somente o Cursor para a Direita
CMDIR equ $1C ; Desloca o Cursor e a Mensagem para a Direita
LCDONSC equ $0C ; Display Aceso sem Cursor
LCDONCF equ $0E ; Display Aceso com Cursor Fixo
LCDONCP equ $0F ; Display Aceso com Cursor Intermitente
C1L1P equ $80 ; Desloca o Cursor para a 1a. linha, 1a. posição
C2L1P equ $C0 ; Desloca o Cursor para a 2a. linha, 1a. posição
WDCESQ equ $04 ; Escreve deslocando o Cursor para a Esquerda
WDCDIR equ $06 ; Escreve deslocando o Cursor para a Direita
WDMESQ equ $07 ; Escreve deslocando a Mensagem para a Esquerda
WDMDIR equ $05 ; Escreve deslocando a Mensagem para a Direita

; Programa Principal
                       org $1000
TLCD                   move.l #$8000,a7 ; inicia a pilha: última posição da RAM + 1
                       bsr INICPIA ; Inicializa MC 68230
                       bsr DPINIT ; Inicializa Modulo LCD
TLCD1                  move.b #C1L1P,d0 ; seleciona 1a. linha
                       bsr WRITEC
                       lea (MEN01,pc),a0 ; (a0)<= end. inicial da mensagem
                       bsr PRINT ; imprime mensagem
                       move.b #C2L1P,d0 ; seleciona 2a. linha
                       bsr WRITEC
                       lea (MEN02,pc),a0 ; (a0)<= end. inicial da mensagem
                       bsr PRINT ; imprime mensagem
                       bsr ESPERA2 ; espera tempo grande
                       move.b #LIMLCD,d0 ; apaga display
                       bsr WRITEC
                       bsr ESPERA2 ; espera tempo grande
                       move.b #C1L1P,d0 ; seleciona 1a. linha
                       bsr WRITEC
                       lea (MEN01,pc),a0 ; (a0)<= end. inicial da mensagem
                       bsr PRINT ; imprime mensagem
                       move.b #C2L1P,d0 ; seleciona 2a. linha
                       bsr WRITEC
                       lea (MEN02,pc),a0 ; (a0)<= end. inicial da mensagem
                       bsr PRINT ; imprime mensagem
                       move.b #OUT1CR,d7 ; envia CR e LF ao terminal
                       trap #14
                       lea.l MEN03,a5 ; a5 aponta para o inicio da mensagem
                       lea.l MEN04,a6 ; a6 aponta para o fim da mensagem +1
                       move.b #OUTPUT,d7 ; envia mensagem – repetir ou terminar o programa
                       trap #14 ;
                       move.b #INCHE,d7 ; pega caractere em do.b
                       trap #14
                       move.b #OUTCH,d7 ; envia caractere recebido em d0.b para tela
                       trap #14
                       cmpi.b #$31,d0 ; digitou 1: repete teste
                       beq TLCD1
                       move.b #TUTOR,d7 ; termina o programa
                       trap #14 ; e retorna ao Programa Tutor
; ************** fim do programa **************



; Sub-rotina para inicializar a porta paralela (configura as portas A e B do MC 68230)
INICPIA                move.b #$30,PGCR ; programa modo
                       move.b #$A0,PACR ; programa submodo Porta A
                       move.b #$A0,PBCR ; programa submodo Porta B
                       move.b #$FF,PADDR ; programa direção da Porta A (saída)
                       move.b #$FF,PBDDR ; programa direção da Porta B (saída)
                       rts
; Sub-rotina para inicializar o Modulo LCD
; Códigos de programação: $38, $38, $38, $06, $0C, $01
DPINIT                 move.b #LCD2L5X7,d0 ; LCD 2 linhas, caractere 5x7
                       bsr WRITEC ; Envia programaçao 3 vezes
                       move.b #LCD2L5X7,d0 ; recomendaçao dos fabricantes
                       bsr WRITEC
                       move.b #LCD2L5X7,d0
                       bsr WRITEC
                       move.b #WDCDIR,d0 ; Escreve deslocando o Cursor para a Direita
                       bsr WRITEC
                       move.b #LCDONSC,d0 ; Display Aceso sem Cursor
                       bsr WRITEC
                       move.b #LIMLCD,d0 ; Limpa Display e Retorna o Cursor
                       bsr WRITEC
                       rts


; Sub-rotina que envia sinais de controle ao Modulo LCD
; Entrada: d0.b = código de controle
WRITEC                 move.b #$A8,PBCR ; RS = 0
                       move.b #$A8,PACR ; E = 0
                       move.b d0,PADR ; Comando na via
                       move.b #$A0,PACR ; E = 1
                       move.b #$A8,PACR ; E = 0
                       bsr ESPERA ; Espera exigida pelo sinal
                       rts


; Sub-rotina que envia sinais de dados ao Modulo LCD
; Entrada: d0.b = dado em código ASCII
WRITED                 move.b #$A0,PBCR ; RS = 1
                       move.b #$A8,PACR ; E = 0
                       move.b d0,PADR ; Dado na via
                       move.b #$A0,PACR ; E = 1
                       move.b #$A8,PACR ; E = 0
                       bsr ESPERA ; Espera exigida pelo sinal
                       rts

; Sub-rotina para esperar um certo tempo para a geração dos sinais
; no Módulo LCD
; Registradores que utiliza: d1.w e flags
ESPERA                 move.w #20480,d1
ESP1                   subq.w #1,d1
                       bne ESP1
                       rts


; Sub-rotina para esperar um tempo grande
; no Módulo LCD
; Registradores que utiliza: d1.w d2.l e flags
; chama n vezes ESPERA, d2.l = n
ESPERA2                move.l #10,d2
ESP2                   bsr ESPERA
                       subq.l #1,d2
                       bne ESP2
                       rts


; Sub-rotina imprime uma string no Módulo LCD
; Registradores que utiliza: d0.b, a0.l e flags
; Entrada: a0.l = endereço inicial da string
PRINT                  move.b (a0)+,d0 ; ao = endereço do 1o. caractere
                       beq PRL1 ; imprime ate encontrar 00
                       bsr WRITED
                       bra PRINT
PRL1                   rts


; Área de mensagens
                       org $2000
MEN01                  dc.b " PCS 3432 "
                       dc.b $00 ; fim de mensagem
MEN02                  dc.b "1o.Semestre 2018"
                       dc.b $00 ; fim de mensagem
MEN03                  dc.b 'Digite 1 para repetir o teste ou outra tecla para sair: '
MEN04                  ; endereço seguinte ao da string anterior
