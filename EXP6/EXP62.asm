; Experiencia 06 - 6.2 - Envio de comandos e dados ao LCD
; Para executar na Placa Experimental

; Fun��es TRAP #14: n�mero da fun��o deve ser colocado em d7
TUTOR equ 228 ; fun��o que retorna ao Programa Tutor
INCHE equ 247 ; funcao que pega um caractere do teclado
OUTCH equ 248 ; funcao que envia um caractere para a tela
OUTPUT equ 243 ; funcao que envia uma string para a tela
OUT1CR equ 227 ; funcao que envia CR e LF ao terminal

; Endere�os de Registradores do MC68230
PGCR equ $FE8001 ; registrador de controle geral
PACR equ $FE800D ; Porta A - registrador de controle
PBCR equ $FE800F ; Porta B - registrador de controle
PADDR equ $FE8005 ; Porta A - registrador de dire��o de dados
PBDDR equ $FE8007 ; Porta B - registrador de dire��o de dados
PADR equ $FE8011 ; Porta A - registrador de dados
PBDR equ $FE8013 ; Porta B - registrador de dados

; C�digos de configura��o do m�dulo LCD
LCD2L5X7 equ $38 ; LCD 2 linhas 5 X 7
LIMLCD equ $01 ; Limpa Display e Retorna o Cursor
HOME equ $02 ; Coloca Cursor na Posi��o Inicial (Home)
LCDOFF equ $08 ; Display Apagado
CESQ equ $10 ; Desloca somente o Cursor para a Esquerda
CMESQ equ $18 ; Desloca o Cursor e a Mensagem para a Esquerda
CDIR equ $14 ; Desloca somente o Cursor para a Direita
CMDIR equ $1C ; Desloca o Cursor e a Mensagem para a Direita
LCDONSC equ $0C ; Display Aceso sem Cursor
LCDONCF equ $0E ; Display Aceso com Cursor Fixo
LCDONCP equ $0F ; Display Aceso com Cursor Intermitente
C1L1P equ $80 ; Desloca o Cursor para a 1a. linha, 1a. posi��o
C2L1P equ $C0 ; Desloca o Cursor para a 2a. linha, 1a. posi��o
WDCESQ equ $04 ; Escreve deslocando o Cursor para a Esquerda
WDCDIR equ $06 ; Escreve deslocando o Cursor para a Direita
WDMESQ equ $07 ; Escreve deslocando a Mensagem para a Esquerda
WDMDIR equ $05 ; Escreve deslocando a Mensagem para a Direita

; Programa Principal
                       org $1000
TLCD                   move.l #$8000,a7 ; inicia a pilha: �ltima posi��o da RAM + 1
                       bsr INICPIA ; Inicializa MC 68230
                       bsr DPINIT ; Inicializa Modulo LCD
INICIO                 move.b #C1L1P,d0 ; seleciona 1a. linha
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
                       move.b #OUTPUT,d7 ; envia mensagem � repetir ou terminar o programa
                       trap #14 ;
                       move.b #INCHE,d7 ; pega caractere em do.b
                       trap #14
                       move.b #OUTCH,d7 ; envia caractere recebido em d0.b para tela
                       trap #14
                       cmpi.b #$31,d0 ; digitou 1: inicia sub-rotina para capturar codigo em hex do comando
                       beq COMANDO
                       cmpi.b #$32, d0 ; digitou 2: inicia sub-rotina para capturar codigo em hex do caractere
                       beq CARACTERE
                       move.b #TUTOR,d7 ; termina o programa
                       trap #14 ; e retorna ao Programa Tutor
; ************** fim do programa **************



; Sub-rotina para inicializar a porta paralela (configura as portas A e B do MC 68230)
INICPIA                move.b #$30,PGCR ; programa modo
                       move.b #$A0,PACR ; programa submodo Porta A
                       move.b #$A0,PBCR ; programa submodo Porta B
                       move.b #$FF,PADDR ; programa dire��o da Porta A (sa�da)
                       move.b #$FF,PBDDR ; programa dire��o da Porta B (sa�da)
                       rts
; Sub-rotina para inicializar o Modulo LCD
; C�digos de programa��o: $38, $38, $38, $06, $0C, $01
DPINIT                 move.b #LCD2L5X7,d0 ; LCD 2 linhas, caractere 5x7
                       bsr WRITEC ; Envia programa�ao 3 vezes
                       move.b #LCD2L5X7,d0 ; recomenda�ao dos fabricantes
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
; Entrada: d0.b = c�digo de controle
WRITEC                 move.b #$A8,PBCR ; RS = 0
                       move.b #$A8,PACR ; E = 0
                       move.b d0,PADR ; Comando na via
                       move.b #$A0,PACR ; E = 1
                       move.b #$A8,PACR ; E = 0
                       bsr ESPERA ; Espera exigida pelo sinal
                       rts


; Sub-rotina que envia sinais de dados ao Modulo LCD
; Entrada: d0.b = dado em c�digo ASCII
WRITED                 move.b #$A0,PBCR ; RS = 1
                       move.b #$A8,PACR ; E = 0
                       move.b d0,PADR ; Dado na via
                       move.b #$A0,PACR ; E = 1
                       move.b #$A8,PACR ; E = 0
                       bsr ESPERA ; Espera exigida pelo sinal
                       rts

; Sub-rotina para esperar um certo tempo para a gera��o dos sinais
; no M�dulo LCD
; Registradores que utiliza: d1.w e flags
ESPERA                 move.w #20480,d1
ESP1                   subq.w #1,d1
                       bne ESP1
                       rts


; Sub-rotina para esperar um tempo grande
; no M�dulo LCD
; Registradores que utiliza: d1.w d2.l e flags
; chama n vezes ESPERA, d2.l = n
ESPERA2                move.l #10,d2
ESP2                   bsr ESPERA
                       subq.l #1,d2
                       bne ESP2
                       rts


; Sub-rotina imprime uma string no M�dulo LCD
; Registradores que utiliza: d0.b, a0.l e flags
; Entrada: a0.l = endere�o inicial da string
PRINT                  move.b (a0)+,d0 ; ao = endere�o do 1o. caractere
                       beq PRL1 ; imprime ate encontrar 00
                       bsr WRITED
                       bra PRINT
PRL1                   rts

; Sub-rotina que imprime mensagem perguntando codigo do comando
COMANDO                lea.l MEN05,a5 ; a5 aponta para o inicio da mensagem
                       lea.l MEN06,a6 ; a6 aponta para o fim da mensagem +1
                       move.b #OUTPUT,d7 ; envia mensagem � repetir ou terminar o programa
                       trap #14 ;
                       move.b #INCHE,d7 ; pega caractere em do.b
                       trap #14
                       move.b #OUTCH,d7 ; envia caractere recebido em d0.b para tela
                       trap #14
                       bsr INICIO
                       rts


CARACTERE              lea.l MEN07,a5 ; a5 aponta para o inicio da mensagem
                       lea.l MEN08,a6
                       move.b #OUTPUT,d7 ; envia mensagem � repetir ou terminar o programa
                       trap #14 ;
                       move.b #INCHE,d7 ; pega caractere em do.b
                       trap #14
                       move.b #OUTCH,d7 ; envia caractere recebido em d0.b para tela
                       trap #14
                       bsr INICIO
                       rts

; �rea de mensagens
                       org $2000
MEN01                  dc.b "1- Enviar Comando"
                       dc.b $00 ; fim de mensagem
MEN02                  dc.b "2- Enviar Dado"
                       dc.b $00 ; fim de mensagem
MEN03                  dc.b 'Digite a op��o:'
MEN04                  ; endere�o seguinte ao da string anterior
MEN05                  dc.b 'Digite o c�digo do Comando (em hexadecimal):'
MEN06                  ; endere�o seguinte ao da string anterior
MEN07                  dc.b 'Digite o c�digo do Caractere (em hexadecimal):'
MEN08                  ; endere�o seguinte ao da string anterior