; Programa que aguarda interrupçao periodica do Timer,
; enviando uma mensagem ao terminal a cada interrupção,
; exibindo o n. de interrupções ocorrido (8 bits em hexa)

; Funcoes TRAP #14: n. de cada uma deve ser colocado em d7
TUTOR     equ 228 ; função que retorna ao Programa Tutor ;;;; ALT
INCHE     equ 247 ; funcao que pega um caractere do teclado;;;; ALT
OUTCH     equ 248 ; envia 1 caractere p/ a tela
OUTPUT    equ 243 ; envia 1 string p/ a tela
PNT2HX    equ 233 ; converte 2 digitos hexa(D0) p/ ASCII(A6)=pont.
BACKSPACE equ 08  ; codigo ASCII do Backspace
CR        equ 13
LF        equ 10

; Registradores da Porta B do MC 68230
PGCR  equ $FE8001 ; registrador de controle geral
PACR  equ $FE800D ; Porta A - registrador de controle ;;;; ALT
PBCR  equ $FE800F ; Porta B - registrador de controle
PADDR equ $FE8005 ; Porta A - registrador de direção de dados ;;;; ALT
PBDDR equ $FE8007 ; Porta B - registrador de direção de dados
PADR  equ $FE8011 ; Porta A - registrador de dados ;;;; ALT
PBDR  equ $FE8013 ; Porta B - registrador de dados

; Códigos de configuração do módulo LCD ;;;; ALT
LCD2L5X7  equ $38 ; LCD 2 linhas 5 X 7
LIMLCD    equ $01 ; Limpa Display e Retorna o Cursor
HOME      equ $02 ; Coloca Cursor na Posição Inicial (Home)
LCDOFF    equ $08 ; Display Apagado
CESQ      equ $10 ; Desloca somente o Cursor para a Esquerda
CMESQ     equ $18 ; Desloca o Cursor e a Mensagem para a Esquerda
CDIR      equ $14 ; Desloca somente o Cursor para a Direita
CMDIR     equ $1C ; Desloca o Cursor e a Mensagem para a Direita
LCDONSC   equ $0C ; Display Aceso sem Cursor
LCDONCF   equ $0E ; Display Aceso com Cursor Fixo
LCDONCP   equ $0F ; Display Aceso com Cursor Intermitente
C1L1P     equ $80 ; Desloca o Cursor para a 1a. linha, 1a. posição
C2L1P     equ $C0 ; Desloca o Cursor para a 2a. linha, 1a. posição
WDCESQ    equ $04 ; Escreve deslocando o Cursor para a Esquerda
WDCDIR    equ $06 ; Escreve deslocando o Cursor para a Direita
WDMESQ    equ $07 ; Escreve deslocando a Mensagem para a Esquerda
WDMDIR    equ $05 ; Escreve deslocando a Mensagem para a Direita

; Registradores do Timer do MC 68230
timevec   equ $1D ; Placa SDC68k: interrup. timer = nível 5

; posição 29D ($1D) na tabela
PIT       equ $FE8000 ; endereço base da PI/T na SBC68K
TCR       equ $21 ; offset p/ o reg. contr. timer
TIVR      equ $23 ; offset p/ o reg. do vetor interr. timer
CPR       equ $25 ; offset p/ o reg. de precarga do contador
TSR       equ $35 ; offset p/ o reg. status timer
TIME      equ $4*timevec ; posiçao da sub-rotina trat. inter. no vetor interr.

; tempo entre interrupçoes TINT=(CLK/32)/CONTAGEM = 0,25 MHz, CLK = 8MHz
; PARA TINT = 1Hz, CONTAGEM = 0,25M/1 = 250000 = $0003D090
CONTAGEM equ 62500 ; valor da divisao para 1Hz
INIPILHA equ $007FFF+1 ; inicio da pilha: ultima posicao da RAM + 1

BS macro ; envia 1 backspace ao terminal
           move.b #BACKSPACE,D0
           move.b #OUTCH,D7
           trap   #14
   endm

           org $1000
PROGR      move.l #INIPILHA,a7 ; carrega base da pilha
           lea.l  TRATINT,a0   ; carrega end. rotina trat. interrupcao
           move.l #TIME,a1     ; carrega a posicao do vetor de exceçoes
           move.l a0,(a1)      ; carrega no vetor o end. da rotina trat. int.
           move.b #$0,CONINT   ; inicializa contador (8 bits) de int.
           move.b #$0,MIN      ; inicializa contador (8 bits) de int.
           move.b #$0,HORA     ; inicializa contador (8 bits) de int.
           move.b #$0,FIM      ; inicializa contador (8 bits) de int.
           bsr    PTIMER       ; programa timer e dispara contagem
           move.w #$2400,sr    ; habilita nivel interrupcao > 4 e limpa flags
           lea.l  mensg0,a5    ; a5 aponta para o inicio da mensagem
           lea.l  msgend,a6     ; a6 aponta para o fim da mensagem +1
           move.b #OUTPUT,d7   ; envia mensagem inicial para tela
           trap   #14
           bsr    INICPIB      ; inicia a Porta B (bip)
           bsr    DPINIT

VOLTA      cmpi.b  #60,CONINT
           beq     SOMAMIN
v1         cmpi.b  #60,MIN
           beq     SOMAHORA
v2         bra     VOLTA ; loop infinito, aguardando interrupçao
; ************* fim do programa **************

; Sub-rotina para inicializar o Modulo LCD
; Códigos de programação: $38, $38, $38, $06, $0C, $01
DPINIT     move.b #LCD2L5X7,d0 ; LCD 2 linhas, caractere 5x7
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
WRITEC     move.b #$A8,PBCR ; RS = 0
           move.b #$A8,PACR ; E = 0
           move.b d0,PADR ; Comando na via
           move.b #$A0,PACR ; E = 1
           move.b #$A8,PACR ; E = 0
           bsr ESPERA ; Espera exigida pelo sinal
           rts


; Sub-rotina que envia sinais de dados ao Modulo LCD
; Entrada: d0.b = dado em código ASCII
WRITED     move.b #$A0,PBCR ; RS = 1
           move.b #$A8,PACR ; E = 0
           move.b d0,PADR ; Dado na via
           move.b #$A0,PACR ; E = 1
           move.b #$A8,PACR ; E = 0
           bsr ESPERA ; Espera exigida pelo sinal
           rts

; Sub-rotina para esperar um certo tempo para a geração dos sinais
; no Módulo LCD
; Registradores que utiliza: d1.w e flags
ESPERA     move.w #20480,d1
ESP1       subq.w #1,d1
           bne ESP1
           rts


; Sub-rotina para esperar um tempo grande
; no Módulo LCD
; Registradores que utiliza: d1.w d2.l e flags
; chama n vezes ESPERA, d2.l = n
ESPERA2    move.l #10,d2
ESP2       bsr ESPERA
           subq.l #1,d2
           bne ESP2
           rts


; Sub-rotina imprime uma string no Módulo LCD
; Registradores que utiliza: d0.b, a0.l e flags
; Entrada: a0.l = endereço inicial da string
PRINT      move.b (a0)+,d0 ; ao = endereço do 1o. caractere
           beq PRL1 ; imprime ate encontrar 00
           bsr WRITED
           bra PRINT
PRL1       rts

; PROGRAMA PRINCIPAL



; Sub-rotina de programaçao do Timer
PTIMER     lea PIT,a0 ; carrega endereço base da PI/T
           move.b #timevec,TIVR(a0) ; carrega a posição no vetor de exceções
           move.l #CONTAGEM,d0 ; carrega contagem 24 bits p/ div. clock
           movep.l d0,CPR(a0) ; nos bytes CPR (H, M, e L)
           move.b #%10100001,TCR(a0) ; Programa TCR: modo 0, CLK/32, liga timer
           rts

; Sub-rotina de tratamento da interrupçao de nivel 5 do Timer
TRATINT    movem.l d0-d7/a0-a6,-(a7) ; salva registadores na pilha
           not.b   BIP      ; alterna bits da Porta B,
           move.b  BIP,PBDR ; gerando o som de bip
           BS               ; envia 2 backspaces ao terminal
           BS
           BS               ; envia 2 backspaces ao terminal
           BS
           BS               ; envia 2 backspaces ao terminal
           BS
           BS               ; envia 2 backspaces ao terminal
           BS
           addq.b  #1,CONINT         ; incrementa contador (8 bits)

           move.b  CONINT,d0         ; converte contador para 2 dig. ASCII
           lea     CONINTA,a6
           move.b  #PNT2HX,d7
           trap    #14

           move.b  MIN,d0         ; converte contador para 2 dig. ASCII
           lea     MINA,a6
           move.b  #PNT2HX,d7
           trap    #14

           move.b  HORA,d0         ; converte contador para 2 dig. ASCII
           lea     HORAA,a6
           move.b  #PNT2HX,d7
           trap    #14

           lea     HORAA,a5        ; envia contador (8 bits) ASCII
           lea     FIM,a6            ; ao terminal (em hexa)
           move.b  #OUTPUT,d7
           trap    #14

           move.b #C1L1P,d0    ; seleciona 1a. linha
           bsr    WRITEC

           ;lea    HORAA,a0 ; (a0)<= end. inicial da mensagem
           ;bsr    PRINT
           ;lea    (MINA,pc),a0 ; (a0)<= end. inicial da mensagem
           ;bsr    PRINT
           lea    (HORAA,pc),a0 ; (a0)<= end. inicial da mensagem
           bsr    PRINT


           lea     PIT,a0            ; limpa pedido de interrupção
           move.b  #1,TSR(a0)        ; para isso, escreve 1 em TSR
           movem.l (a7)+,d0-d7/a0-a6 ; restaura registadores usados da pilha
           rte                       ; retorno de excecao (nao e ´ RTS !)
INICPIB    move.b #$30,PGCR          ; programa modo do MC 68230
           move.b #$A0,PACR          ; programa submodo Porta A ;;;;ALT
           move.b #$A0,PBCR          ; programa submodo da Porta B
           move.b #$FF,PADDR         ; programa direção da Porta A (saída) ;;;;ALT
           move.b #$FF,PBDDR         ; programa direção da Porta B (saída)
           rts

SOMAMIN    bsr    SOMAMIN2
           bra    v1
SOMAMIN2   nop
           addi.b #$1,MIN
           nop
           move.b #$0,CONINT
           nop
           nop
           rts

SOMAHORA   bsr    SOMAHORA2
           bra    v2
SOMAHORA2  addi.b #$1,HORA
           move.b #$0,MIN
           move.b #$0,CONINT
           rts

; Area de armazenamento de mensagens
mensg0 dc.b 'Horas!!',CR,LF
mensg1 dc.b '1. Definir hora',CR,LF
mensg2 dc.b '2. Definir minuto',CR,LF
mensg3 dc.b '3. Definir segundo',CR,LF
msgend

; Area de variaveis
           org $2000
BIP     ds.b 1 ; variável do bip (toogle)
CONINT  ds.b 1 ; variavel incrementada a cada int. (hexa)
HORA    ds.b 1 ; horas
MIN     ds.b 1 ; minutos
HORAA   ds.b 2 ; Horas em ASCII
esp1    dc.b ' ';
MINA    ds.b 2 ; Minutos em ASCII
esp2    dc.b ' ';
CONINTA ds.b 2 ; variavel incrementada a cada int. (ASCII)
FIM     ds.b 1