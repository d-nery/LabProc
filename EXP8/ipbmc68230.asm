           include mc68230.a68 ; Declaracoes dos registradores do MC 68230 (PI/T)
           xdef INICPIB ; subrotina publica

; Sub-rotina de programa�ao da Porta B do MC 68230 (bip)
INICPIB
           move.b #$A0,PBCR ; programa submodo da Porta B
           move.b #$FF,PBDDR ; programa dire��o da Porta B (sa�da)
           rts