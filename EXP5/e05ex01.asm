; Experiencia 05 - Exemplo: entrada de n.USP e senha
; Para executar no simulador
; Author: Carlos E. Cugnasca

LF      equ     $0A     ; definicoes ASCII para Linefeed e
CR      equ     $0D     ; Carriage Return
pwd123  equ     $1      ; 3 1os. digitos senha
pwd4    equ     $0      ; 4o. digito senha

GETNUM  MACRO           ; Pega e exibe os 6 digitos do n. USP
        trap    #15     ; GETCHE
        dc.w    2       ; call system function 3 (get character in D0 with echo)
        ENDM

GETPWD  MACRO   pwd     ; Pega e exibe os 3 1os. digitos do n. USP
        trap    #15     ; GETCHE
        dc.w    3       ; call system function 3 (get character in D0 without echo)
        move.b  D0,D6   ; salva D0.B em D6.B

        IFNE    pwd     ; so monta a instrucao seguinte para os 3 1os. digitos
        asl.l   #8,D6   ; desloca D6.L 8 bits para esquerda
        ENDIF

        MOVE.B  #'*',D0 ; envia "*" no lugar do dígito da senha
        trap    #15     ; PUTCH
        dc.w    1       ; call system function 1 (envia ao terminal D0.B em ASCII)
        ENDM

CRLF    MACRO           ; envia CR LF ao terminal
        MOVE.B  #CR,D0  ; envia CR
        trap    #15     ; PUTCH
        dc.w    1       ; call system function 1 (envia ao terminal D0.B em ASCII)
        MOVE.B  #LF,D0  ; envia CR
        trap    #15     ; PUTCH
        dc.w    1       ; call system function 1 (envia ao terminal D0.B em ASCII)
        ENDM

        org     $400    ; inicio do programa(>= $400)

        lea     textnUSP,A0     ; endereço do texto em A0
        trap    #15             ; PRTSTR
        dc.w    7               ; call system function 7 (print string)

        GETNUM                  ; pega os 6 digitos do numero USP,
        GETNUM                  ; ecoando-os
        GETNUM                  ;
        GETNUM                  ;
        GETNUM                  ;
        GETNUM                  ;

        CRLF

        lea     textPWD,A0      ; endereço do texto em A0
        trap    #15             ; PRTSTR
        dc.w    7               ; call system function 7 (print string)

        GETPWD  pwd123          ; pega os 3 1os. digitos da senha
        GETPWD  pwd123          ;
        GETPWD  pwd123          ;
        GETPWD  pwd4            ; pega o 4o.digito da senha

        CRLF

        lea     senha,A0        ; endereço da senha correta em A0
        sub.l   (A0),D6         ; compara-a com a senha digitada
        beq     correta

        lea     senhaNOK,A0         ; endereco do texto em A0 (senha NOK)
envmens trap    #15
        dc.w    7                   ; call system function 7 (print string)
        trap    #15                 ; EXIT
        dc.w    0                   ; call system function 0 (exit program)
                                    ; fim do programa: retorno ao simulador

correta lea     senhaOK,A0          ; endereco do texto em A0 (senha OK)
        BRA     envmens

; strings
textnUSP    dc.b    'Digite o seu n. USP com 6 caracteres:',CR,LF,0
textPWD     dc.b    'Digite a sua senha com 4 caracteres:',CR,LF,0
senhaOK     dc.b    'Senha correta',CR,LF,0
senhaNOK    dc.b    'Senha Incorreta',CR,LF,0
senha       dc.l    '1234'
