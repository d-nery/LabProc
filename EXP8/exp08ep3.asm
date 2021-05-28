; Experiencia 08 - Exemplo: Teste de um teclado 4x4
; Para executar na Placa Experimental SDC68k
; Author: Carlos E. Cugnasca
;
; Programa que efetua a varredura de um teclado 4x4.
; A cada tecla pressionada do terminal, exibe um byte (hexa) com duas partes de 4 bits:
; valor lido, valor da varredura
; Quando uma tecla for mantida pressionada, a cada tecla digitada um valor enviado e lido e ´ exibido
; e 1 bip ocorre, possibilitando identificar o ciclo da varredura no qual ocorreu a deteccao.
; Varredura do Teclado
; X: linhas de saida = bits 0-3 da Porta A
; Y: colunas de entrada = bits 4-7 da Porta A
; Linhas: um '0' e ´ colocado alternadamente nas linhas.
; Colunas: lidas ciclicamente. Quando o '0' colocada na linha Xi e chega em alguma coluna
; Yj, a tecla e ´ identificada: XiYj, e convertida para o respectivo codigo
; Teclado Exemplo (pode nao ser o encontrado):
; PA0 ---> 9 8 7 A => X0Y0 X0Y1 X0Y2 X0Y3
; PA1 ---> 6 5 4 B => X1Y0 X1Y1 X1Y2 X1Y3
; PA2 ---> 3 2 1 C => X2Y0 X2Y1 X2Y2 X2Y3
; PA3 ---> * 0 # D => X3Y0 X3Y1 X3Y2 X3Y3
; | | | |
; V V V V
; PA4 PA5 PA6 PA7
; PA0 PA1 PA2 PA3 Teclas Escaneadas (exemplo-atualizar para o teclado real)
; 0 1 1 1 9, 8, 7, A
; 1 0 1 1 6, 5, 4, B
; 1 1 0 1 3, 2, 1, C
; 1 1 1 0 *, 0, #, D
; o bip e ´ gerado por interrupção
           include mc68230.a68         ; Declaracoes dos registradores do MC 68230 (PI/T)
                                       ; tempo entre interrupçoes TINT=(CLK/32)/CONTAGEM = 0,25 MHz, CLK = 8MHz
                                       ; PARA TINT = 1Hz, CONTAGEM = 0,25M/1 = 250000 = $0003D090
CONTAGEM   equ 62500                   ; valor da divisao para 0,25Hz
LINHA0     equ %11111110               ; ativa apenas linha 0
LINHA1     equ %11111101               ; ativa apenas linha 1
LINHA2     equ %11111011               ; ativa apenas linha 2
LINHA3     equ %11110111               ; ativa apenas linha 3
INIPILHA   equ $007FFF+1               ; inicio da pilha: ultima posicao da RAM + 1
           include pscall.a68          ; Declaracoes das Systems Calls (TRAP #14)
           xref _inicpia               ; Inicia Porta A: sub-rotina externa definida como
                                       ; publica em outro arquivo .c
           xref INICPIB                ; Inicia Porta B: sub-rotina externa definida como
                                       ; publica em outro arquivo .asm
VARRELINHA macro nlinha                ; parametro: linha a ser varrida
           MOVE.B #nlinha,PADR         ; ativa apenas linha 0 de X (=0, demais =1)
           move.b #INCHE,D7            ; digite qq tecla para continuar
           trap #14
           move.b PADR,D0              ; le Porta A (4-7)
           lea.l TECLACONV,A6
           move.b #PNT2HX,D7           ; converte valor lido para 2 dig. ASCII
           trap #14
           lea.l TECLACONV,A6
           move.b (A6)+,D0             ; envia 1o. caractere para tela
           move.b #OUTCH,D7
           trap #14
           move.b (A6),D0              ; envia 2o. caractere para tela
           move.b #OUTCH,D7
           trap #14
           CRLF                        ; envia CR e LF para a tela
           move.b #$FF,BIP ; bipar
           endm

           org $001000

; Programa Principal
VARRETECL  move.l #INIPILHA,a7         ; carrega base da pilha
           lea.l MENSG1,a5             ; a5 aponta para o inicio da mensagem
           lea.l MENSG,a6              ; a6 aponta para o fim da mensagem +1
           move.b #OUTPUT,d7           ; envia mensagem inicial para tela
           trap #14
           CRLF                        ; envia CR e LF para a tela
           bsr _inicpia                ; inicia a Porta A (programa em c)
           bsr INICPIB                 ; inicia a Porta B (programa em asm)
           clr.b FIMBIP                ; inicia variavel de controle do bip
           lea.l TRATINT,a0            ; carrega end. rotina trat. interrupcao
           move.l #TIME,a1             ; carrega a posicao do vetor de exceçoes
           move.l a0,(a1)              ; carrega no vetor o end. da rotina trat. int.
           bsr PTIMER                  ; programa timer e dispara contagem
           move.w #$2400,sr            ; habilita nivel interrupcao > 4 e limpa flags

VAR                                    ; loop de varredura do teclado
           VARRELINHA LINHA0           ; ativa apenas linha 0 de X (=0, demais =1)
           VARRELINHA LINHA1           ; ativa apenas linha 1 de X (=0, demais =1)
           VARRELINHA LINHA2           ; ativa apenas linha 2 de X (=0, demais =1)
           VARRELINHA LINHA3           ; ativa apenas linha 3 de X (=0, demais =1)
           bra VAR ;                   ; Fim do Programa Principal

; Sub-rotina de programaçao do Timer
PTIMER     lea.l PIT,a0                ; carrega endereço base da PI/T
           move.b #timevec,TIVR(a0)    ; carrega a posição no vetor de exceções
           move.l #CONTAGEM,d0         ; carrega contagem 24 bits p/ div. clock
           movep.l d0,CPR(a0)          ; nos bytes CPR (H, M, e L)
           move.b #%10100001,TCR(a0)   ; Programa TCR: modo 0, CLK/32, liga timer
           rts

; Sub-rotina de tratamento da interrupçao de nivel 5 do Timer
TRATINT    movem.l d0-d7/a0-a6,-(a7)   ; salva registadores na pilha
           cmpi.b #$FF,BIP             ; e ´ para bipar?
           bne FIMINT                  ; nao - retorna
           cmpi.b #$1,FIMBIP           ; sim - ja esta bipando?
           bne BIPAR                   ; nao: comeca a bipar
           clr.b FIMBIP                ; sim: limpa pedido
           clr.b BIP                   ; sim: limpa estado buzzer
           move.b BIP,PBDR
           bra FIMINT
BIPAR                                  ; bipa por 1 interrupcao
           move.b #1,FIMBIP            ; na proxima interrupcao desliga bip
           move.b BIP,PBDR             ; envia estado do bipa para a Porta B
FIMINT
           lea.l PIT,a0                ; limpa pedido de interrupção
           move.b #1,TSR(a0)           ; para isso, escreve 1 em TSR
           movem.l (a7)+,d0-d7/a0-a6   ; restaura registadores usados da pilha
           rte                         ; retorno de excecao (nao e ´ RTS !)

; Area de armazenamento de constantes
MENSG1 dc.b 'Inicia varredura do Teclado'
MENSG dc.b 00
; Area de armazenamento de variáveis
           org $002000
TECLACONV ds.l 2
BIP ds.b 1 ; variável do bip (toogle)
FIMBIP ds.b 1
; fim de programa