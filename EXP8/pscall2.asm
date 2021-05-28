; Includes para a Placa Experimental SDC68k
; Funcoes TRAP #14: n. de cada uma deve ser colocado em d7

TUTOR      equ 228                     ; funcao que retorna ao Programa Tutor
INCHE      equ 247                     ; funcao que pega um caractere do teclado para D0

; Envio de caracter ao terminal
; A5: end. inicial da string, A6: end. final da string +1

OUT1CR     equ 227                     ; funcao que envia CR e LF ao terminal
OUTCH      equ 248                     ; envia 1 caractere p/ a tela
OUTPUT     equ 243                     ; envia 1 string p/ a tela
PUTHEX     equ 234                     ; converte 1 digito hexa(D0) p/ ASCII(A6)=pont.
PNT2HX     equ 233                     ; converte 2 digitos hexa(D0) p/ ASCII(A6)=pont.
PNT4HX     equ 232                     ; converte 4 digitos hexa(D0) p/ ASCII(A6)=pont.
PNT6HX     equ 231                     ; converte 6 digitos hexa(D0) p/ ASCII(A6)=pont.
PNT8HX     equ 230                     ; converte 8 digitos hexa(D0) p/ ASCII(A6)=pont.
HEX2DEC    equ 236                     ; converte 8 digitos hexa(D0) p/ DECIMAL(A6)=pont.
LF         equ $0A                     ; codigo ASCII para Linefeed
CR         equ $0D                     ; codigo ASCII para Carriage Return
BACKSPACE  equ $08                     ; codigo ASCII para Backspace
SP         equ $20                     ; codigo ASCII para Espaco
BS         macro                       ; envia 1 backspace ao terminal
           move.b #BACKSPACE,D0
           move.b #OUTCH,D7
           trap #14
           endm
CRLF       macro                       ; envia CR e LF ao terminal
           move.b #CR,D0
           move.b #OUTCH,D7
           trap #14
           move.b #LF,D0
           move.b #OUTCH,D7
           trap #14
           endm