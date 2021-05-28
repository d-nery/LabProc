; Experiencia 05 - Exemplo: entrada de caracteres
; Para executar na Placa Experimental SDC68k
; Author: Carlos E. Cugnasca

; Programa que recebe caracteres do teclado e os exibe no display (eco),
; ate ́ '.' ser digitado, que provocara ́ a volta ao Programa Tutor.
; Os caracteres sao armazenados na memoria
; Funcoes TRAP #14 sao utilizadas: numero de cada uma deve ser colocado em d7

TUTOR       equ         228         ; funcao que retorna ao Programa Tutor
INCHE       equ         247         ; funcao que pega um caractere do teclado
OUTCH       equ         248         ; funcao que envia um caractere para a tela
OUTPUT      equ         243         ; funcao que envia uma string para a tela
OUT1CR      equ         227         ; funcao que envia CR e LF ao terminal

            org         $1000

ENTRCAR     lea.l       mensg1,a5   ; a5 aponta para o inicio da mensagem
            lea.l       mensg2,a6   ; a6 aponta para o fim da mensagem +1
            move.b      #OUTPUT,d7  ; envia mensagem para tela
            trap        #14
            move.b      #OUT1CR,d7  ; envia CR e LF ao terminal
            trap        #14
            lea.l       mensg2,a5   ; a5 aponta para o inicio da mensagem
            lea.l       mensg3,a6   ; a6 aponta para o fim da mensagem +1
            move.b      #OUTPUT,d7  ; envia mensagem para tela
            trap        #14
            move.b      #OUT1CR,d7  ; envia CR e LF ao terminal
            trap        #14
            lea.l       mensg3,a5   ; a5 aponta para o inicio da mensagem
            lea.l       mensg,a6    ; a6 aponta para o fim da mensagem +1
            move.b      #OUTPUT,d7  ; envia mensagem para tela
            trap        #14
            move.b      #OUT1CR,d7  ; envia CR e LF ao terminal
            trap        #14

            lea.l       guarda,a1   ; a1 aponta para a area de armazenamento
volta       move.b      #INCHE,d7   ; recebe um caractere em d0.b
            trap        #14         ;
            move.b      #OUTCH,d7   ; envia caractere recebido em d0.b para tela
            trap        #14
            move.b      d0,(a1)+    ; armazena caractere na memoria
            cmpi.b      #'.',d0     ; '.' foi digitado?
            bne         volta       ; Não, entao continua a recepção
            move.b      #TUTOR,d7   ; Sim, termina o programa
            trap        #14         ; e retorna ao Programa Tutor

; Area de armazenamento dos dados digitados. Foram reservados 32 posicoes.
mensg1      dc.b        'Digite um texto. '
mensg2      dc.b        'Para terminar digite o caractere ponto (.)'
mensg3      dc.b        'Os caracteres digitados serao armazenados a partir do endereco $2000'

mensg
            org         $2000

guarda      ds.b        32
            end         ENTRCAR
