; Experiencia 08 - Exemplo: Simulaçao de um teclado 4x4
; Para executar no simulador IDE68k
; Author: Carlos E. Cugnasca
;
; Programa que efetua a varredura de um teclado 4x4 utilizando,
; simulando o uso da Porta A do MC 68230
; X: linhas de saida = bits 0-3 da Porta A
; Y: colunas de entrada = bits 4-7 da Porta A
; A interrupçao I7 simula o pressionamento de alguma tecla, e
; envia mensagem ao terminal, solicitando coordenadas X e Y
; da tecla pressionada, e exibindo o seu codigo no terminal algumas vezes,
; simulando o tempo de pressionamento, que deveria ser tirado (bounce).
; Varredura do Teclado:
; Linhas: '0' e ´ colocado alternadamente nas linhas.
; Colunas: lidas ciclicamente. Quando o '0' colocado na linha Xi chega em alguma
; coluna Yj, a tecla e ´ identificada (XiYj), e convertida para o seu codigo ASCII.
; Possivel Configuracao do Teclado (alterar para o encontrado no laboratorio):
; PA0 ---> 9 8 7 A => X0Y0 X0Y1 X0Y2 X0Y3
; PA1 ---> 6 5 4 B => X1Y0 X1Y1 X1Y2 X1Y3
; PA2 ---> 3 2 1 C => X2Y0 X2Y1 X2Y2 X2Y3
; PA3 ---> * 0 # D => X3Y0 X3Y1 X3Y2 X3Y3
; | | | |
; V V V V
; PA4 PA5 PA6 PA7
; PA0 PA1 PA2 PA3 Teclas Escaneadas
; 0 1 1 1 9, 8, 7, A
; 1 0 1 1 6, 5, 4, B
; 1 1 0 1 3, 2, 1, C
; 1 1 1 0 *, 0, #, D

           include sscall.inc          ;Declaracoes das Systems Calls (TRAP #15)

INIPILHA   equ $007FFF+1               ; inicio da pilha: ultima posicao da RAM + 1
INT7       equ $007C                   ; level 7 autovector

           org $001000

VARRETECL  move.l #INIPILHA,a7         ; carrega base da pilha
           move.l #TRATINT7,INT7       ; carrega end.Vetor de Excecoes
           lea MENSINIC,a0             ; endereço do texto em A0 - mensagem inicial
           trap #15                    ; imprime string ate 00
           dc.w PRTSTR
           clr.b TECLPR                ; indica nao ocorreu I7 (tecla foi pressionada)
           move.b #%11111111,YCOLUNA   ; valor inicial - nenhuma coluna
INIC       move.b #%01111111,d0        ; valor inicial X
           move.b #-1,d1               ; Preset contador de X = -1
XLOOP      rol.b #1,d0                 ; coloca 0 em apenas 1 linha de X
           add.b #1,d1                 ;incrementa contador de X
           andi.b #%00000011,D1        ; contador de X: e ´ modulo 4 (values 0-3 apenas)
           bne XLOOP1                  ; pula se contador de X nao for 0
           move #%11111110,d0          ; coloca 0 em apenas 1 linha de X
XLOOP1     move.b d0,XLINHA            ; salva X e envia para Porta A(0-3)
           bsr LEY                     ; le colunas Y da Porta A(4-7)
           cmpi.b #%11111111,YCOLUNA   ;
           beq XLOOP                   ; volta a varrer se nenhuma tecla pressionada
           clr.b d3                    ; houve tecla pressionada: preset contador de Y = 0
           move.b YCOLUNA,d2           ; salva colunas da tecla pressionada
YLOOP      move.b d2,d4                ; faz copia da coluna Y (D2 e D4)
           ori.b #%11110000,d4         ; faz bits sem interesse = 1
           cmpi.b #%11111110,d4        ; compara com a primeira linha de X
           beq CONCATENA               ; se for igual, descobriu linha X e concatena X e Y
           ror.b #1,D2                 ; se for igual, rotacionar D2 one place right
           add.b #1,D3                 ; atualizar contador de Y
           bra YLOOP                   ; testa proximo bit
CONCATENA                              ; Y=D3, X=D1 - pega codigo da tecla pressionada da tabela
           move.l #NOMETECLA,a3        ;
           clr.l d4
           move.b d1,d4
           asl.b #$2,d4                ; X <= X*4
           add.b d3,d4                 ; X <= X+Y
           add.l d4,a3
           move.b (a3),d0              ; pega cod. ASCII da tecla pressionada
           trap #15                    ; envia ao terminal D0.B em ASCII.
           dc.w PUTCH                  ;
           lea MENTECLA,a0             ; end. mens. valor da tecla pressionada
           trap #15                    ; imprime string ate 00
           dc.w PRTSTR                 ;
           bra INIC                    ; retorna: nova varredura

; Sub-rotina que verifica se houve tecla pressionada e se ela corresponde `a linha de varredura
LEY        movem.l d0-d7/a0-a6,-(a7)   ; salva registradores na pilha
           cmpi.b #$01,TECLPR
           beq LEY1                    ; caso tecla foi pressionada trata
           move.b #%11111111,YCOLUNA   ; nenhuma tecla pressionada nessa linha de varedura
           bra LEYFIM
LEY1
           subq.w #1,TEMP              ; decrementa temporizador tempo de pressionamento
           beq LEY2                    ; fim de temporizaçao termina
           cmp.b LINHA,d1              ; contador de linha da verredura = linha da tecla digitada?
           beq LEY3                    ; sim: trata
           move.b #%11111111,YCOLUNA   ; sinaliza nenhuma tecla pressionada e retorna
           bra LEYFIM
LEY3                                   ; registra LINHA e COLUNA da tecla digitada
                                       ; end TABPRESS: (a0)<= TPRES +4*x+y ; pega da tabela: XY <= (a0)
           clr.l d0
           move.l #TPRES,a3
           move.b LINHA,d0
           asl.b #$2,d0 ; X <= X*4
           add.b COLUNA,d0
           add.l d0,a3 ; X <= X+Y
           move.b (a3),YCOLUNA
           ori.b #%11110000,YCOLUNA    ; deixa so n. da coluna: 1111 y
           bra LEYFIM
LEY2       move.b #%11111111,YCOLUNA   ; acabou de temporizar - nenhuma tecla pressionada
           clr.b TECLPR
LEYFIM     movem.l (a7)+,d0-d7/a0-a6   ; restaura registradores da pilha
           rts


; Sub-rotina de tratamento da interrupcao 7 (simula tecla pressionada)
TRATINT7   movem.l d0-a7/a0-a6,-(a7)    ; salva registradores na pilha
           lea MENSX,a0                ; end. mens. digite n. linha (Xi)
           trap #15                    ; imprime string ate 00
           dc.w PRTSTR                 ;
           trap #15                    ; pega caractere (D0)e ecoa no terminal
           dc.w GETCHE                 ;
           andi.b #$0F,d0              ; converte n. ASCII para BCD
           cmpi.b #$03,d0              ; erro se nao for n.
           bgt TRERRO                  ; digitou caractere invalido
           move.b d0,LINHA             ; guarda Xi em LINHA
           lea MENSY,a0                ; end. mens. digite n. coluna (Yi)
           trap #15                    ; imprime string ate 00
           dc.w PRTSTR                 ;
           trap #15                    ; pega caractere (D0)e ecoa no terminal
           dc.w GETCHE                 ;
           andi.b #$0F,d0              ; converte n. ASCII para BCD
           cmpi.b #$03,d0              ; erro se nao for n.
           bgt TRERRO                  ; digitou caractere invalido
           move.b d0,COLUNA            ; guarda Yi em COLUNA
           move.b #$01,TECLPR          ; indica que ocorreu I7 e uma tecla foi pressionada
           move.w #$10,TEMP            ; dispara temporizaçao (simula tempo de pressionadmento)
           CRLF                        ; envia CR e LF ao terminal
           bra TRINT7FIM
TRERRO                                 ; se erro aborta
           lea MENERRO,a0              ; endereço do texto em A0
           trap #15                    ; imprime string ate 00
           dc.w PRTSTR                 ;
TRINT7FIM  movem.l (a7)+,d0-a7/a0-a6   ; restaura registradores da pilha
           rte                         ; retorno de interrupcao: RTE e nao RTS!

; Area de constantes
MENSX dc.b CR,LF,'Digite o numero da linha (0 a 3): ',0
MENSY dc.b CR,LF,'Digite o numero da coluna (0 a 3): ',0
MENERRO dc.b CR,LF,'Valor Incorreto! Gere nova Interrupcao',0
MENTECLA dc.b ' foi a tecla pressionada: ',CR,LF,0
MENSVAR dc.b CR,LF,'Fim de uma varredura: digite qq tecla para continuar',CR,LF,0
MENSINIC dc.b 'Pressione I7 para selecionar tecla',CR,LF,0
; Teclado
; 9 8 7 A => X0Y0 X0Y1 X0Y2 X0Y3
; 6 5 4 B => X1Y0 X1Y1 X1Y2 X1Y3
; 3 2 1 C => X2Y0 X2Y1 X2Y2 X2Y3
; * 0 # D => X3Y0 X3Y1 X3Y2 X3Y3

NOMETECLA
           dc.b '9' ; X0Y0
           dc.b '8' ; X0Y1
           dc.b '7' ; X0Y2
           dc.b 'A' ; X0Y3
           dc.b '6' ; X1Y0
           dc.b '5' ; X1Y1
           dc.b '4' ; X1Y2
           dc.b 'B' ; X1Y3
           dc.b '3' ; X2Y0
           dc.b '2' ; X2Y1
           dc.b '1' ; X2Y2
           dc.b 'C' ; X2Y3
           dc.b '*' ; X3Y0
           dc.b '0' ; X3Y1
           dc.b '#' ; X3Y2
           dc.b 'D' ; X3Y3

; tabela que simula a Porta A(4-7) - entrada
TPRES      dc.b %11101110 ; X0Y0 - y0
           dc.b %11101101 ; X0Y1
           dc.b %11101011 ; X0Y2
           dc.b %11100111 ; X0Y3
           dc.b %11011110 ; X1Y0 - y1
           dc.b %11011101 ; X1Y1
           dc.b %11011011 ; X1Y2
           dc.b %11010111 ; X1Y3
           dc.b %10111110 ; X2Y0 - y2
           dc.b %10111101 ; X2Y1
           dc.b %10111011 ; X2Y2
           dc.b %10110111 ; X2Y3
           dc.b %01111110 ; X3Y0 - y3
           dc.b %01111101 ; X3Y1
           dc.b %01111011 ; X3Y2
           dc.b %01110111 ; X3Y3
NOTPRES    dc.b %11111111 ; nenhuma tecla pressionada

           org $FE1000 ; Area de variáveis
TECLPR     ds.b 1 ; uma tecla esta pressionada
XLINHA     ds.b 1 ; Porta A(0-3): saidas = linhas
YCOLUNA    ds.b 1 ; Porta A(4-7): entradas = colunas
LINHA      ds.b 1 ; Xi - linha selecionada
COLUNA     ds.b 1 ; Yi - coluna selecionada
TEMP       ds.w 1 ; contante para temporizar pressionamento
; fim do programa
