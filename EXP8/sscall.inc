; Include para o Simulador IDE68k
; Systems Calls - TRAP #15: n. x de cada uma deve ser colocado em dc.w x apos TRAP #15

EXIT	equ 	0 		; termina o programa e retornao ao simulador
PUTCH 	equ 	1 		; envia ao terminal D0.B em ASCII. D0 nao e ´ afetado
GETCHE 	equ 	2 		; pega caractere digitado em D0.L e o ecoa no terminal
GETCH 	equ 	3 		; pega caractere digitado em D0.L sem eco
KEYHIT 	equ 	4 		; checa buffer do teclado p/ qq caractere.Z=0 se tem 1 ou +
PRIMNUM equ 	5 		; imprime o conteudo de D0 como decimal c/ sinal
GETNUM 	equ 	6 		; le n. decimal do teclado em D0.L
PRTSTR 	equ 	7 		; imprime string apontada por A0, e terminada por 00
GETSTR 	equ 	8 		; recebe string a partir do end. de A0. Fim: digitar Enter (nao colocado)
; Do.L: n. de caracteres digitados
GETTIME equ 	9 		; retorna a hora em D0(em s desde UTC)
LF 	equ 	$0A 	; codigo ASCII para Linefeed
CR 	equ 	$0D 	; codigo ASCII para Carriage Return
BS 	equ 	$08 	; codigo ASCII para Backspace
SP 	equ 	$20 	; codigo ASCII para Espaco
CRLF 	macro 		; envia CR e LF ao terminal
	move.b 	#CR,d0 	;
	trap 	#15
	dc.w 	PUTCH
	move.b 	#LF,d0 	;
	trap 	#15
	dc.w 	PUTCH
	endm
PUTCHAR macro 	ch 	; envia ch (ASCII) ao terminal
	move.b 	#ch,d0
	trap 	#15
	dc.w 	PUTCH
	endm