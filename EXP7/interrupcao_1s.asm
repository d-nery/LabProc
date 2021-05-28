; Programa que aguarda interrupçao periodica do Timer,
; enviando uma mensagem ao terminal a cada interrupção,
; exibindo o n. de interrupções ocorrido (8 bits em hexa)
; Funcoes TRAP #14: n. de cada uma deve ser colocado em d7
OUTCH equ 248 ; envia 1 caractere p/ a tela
OUTPUT equ 243 ; envia 1 string p/ a tela
PNT2HX equ 233 ; converte 2 digitos hexa(D0) p/ ASCII(A6)=pont.
BACKSPACE equ 08 ; codigo ASCII do Backspace
; Registradores da Porta B do MC 68230
PGCR equ $FE8001 ; registrador de controle geral
PBCR equ $FE800F ; Porta B - registrador de controle
PBDDR equ $FE8007 ; Porta B - registrador de direção de dados
PBDR equ $FE8013 ; Porta B - registrador de dados
; Registradores do Timer do MC 68230
timevec equ $1D ; Placa SDC68k: interrup. timer = nível 5
; posição 29D ($1D) na tabela
PIT equ $FE8000 ; endereço base da PI/T na SBC68K
TCR equ $21 ; offset p/ o reg. contr. timer
TIVR equ $23 ; offset p/ o reg. do vetor interr. timer
CPR equ $25 ; offset p/ o reg. de precarga do contador
TSR equ $35 ; offset p/ o reg. status timer
TIME equ $4*timevec ; posiçao da sub-rotina trat. inter. no vetor interr.

; tempo entre interrupçoes TINT=(CLK/32)/CONTAGEM = 0,25 MHz, CLK = 8MHz
; PARA TINT = 1Hz, CONTAGEM = 0,25M/1 = 250000 = $0003D090
CONTAGEM equ 250000 ; valor da divisao para 1Hz
INIPILHA equ $007FFF+1 ; inicio da pilha: ultima posicao da RAM + 1

BS macro ; envia 1 backspace ao terminal
           move.b #BACKSPACE,D0
           move.b #OUTCH,D7
           trap #14
   endm
; PROGRAMA PRINCIPAL
           org $1000
PROGR      move.l #INIPILHA,a7 ; carrega base da pilha
           lea.l TRATINT,a0 ; carrega end. rotina trat. interrupcao
           move.l #TIME,a1 ; carrega a posicao do vetor de exceçoes
           move.l a0,(a1) ; carrega no vetor o end. da rotina trat. int.
           move.b #$0,CONINT ; inicializa contador (8 bits) de int.
           bsr PTIMER ; programa timer e dispara contagem
           move.w #$2400,sr ; habilita nivel interrupcao > 4 e limpa flags
           lea.l mensg1,a5 ; a5 aponta para o inicio da mensagem
           lea.l mensg,a6 ; a6 aponta para o fim da mensagem +1
           move.b #OUTPUT,d7 ; envia mensagem inicial para tela
           trap #14
           bsr INICPIB ; inicia a Porta B (bip)
VOLTA      bra VOLTA ; loop infinito, aguardando interrupçao

; Sub-rotina de programaçao do Timer
PTIMER     lea PIT,a0 ; carrega endereço base da PI/T
           move.b #timevec,TIVR(a0) ; carrega a posição no vetor de exceções
           move.l #CONTAGEM,d0 ; carrega contagem 24 bits p/ div. clock
           movep.l d0,CPR(a0) ; nos bytes CPR (H, M, e L)
           move.b #%10100001,TCR(a0) ; Programa TCR: modo 0, CLK/32, liga timer
           rts

; Sub-rotina de tratamento da interrupçao de nivel 5 do Timer
TRATINT    movem.l d0-d7/a0-a6,-(a7) ; salva registadores na pilha
           not.b BIP ; alterna bits da Porta B,
           move.b BIP,PBDR ; gerando o som de bip
           BS ; envia 2 backspaces ao terminal
           BS
           addq.b #1,CONINT ; incrementa contador (8 bits)
           move.b CONINT,d0 ; converte contador para 2 dig. ASCII
           lea CONINTA,a6
           move.b #PNT2HX,d7
           trap #14
           lea CONINTA,a5 ; envia contador (8 bits) ASCII
           lea FIM,a6 ; ao terminal (em hexa)
           move.b #OUTPUT,d7
           trap #14
           lea PIT,a0 ; limpa pedido de interrupção
           move.b #1,TSR(a0) ; para isso, escreve 1 em TSR
           movem.l (a7)+,d0-d7/a0-a6 ; restaura registadores usados da pilha
           rte ; retorno de excecao (nao e ´ RTS !)
INICPIB    move.b #$30,PGCR ; programa modo do MC 68230
           move.b #$A0,PBCR ; programa submodo da Porta B
           move.b #$FF,PBDDR ; programa direção da Porta B (saída)
           rts
; Area de armazenamento de mensagens
mensg1 dc.b 'Interrupcoes ocorridas: $ '
mensg
; Area de variaveis
           org $2000
BIP ds.b 1 ; variável do bip (toogle)
CONINT ds.b 1 ; variavel incrementada a cada int. (hexa)
CONINTA ds.b 2 ; variavel incrementada a cada int. (ASCII)
FIM ds.b 1