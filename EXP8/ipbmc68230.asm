           include mc68230.a68 ; Declaracoes dos registradores do MC 68230 (PI/T)
           xdef INICPIB ; subrotina publica

; Sub-rotina de programaçao da Porta B do MC 68230 (bip)
INICPIB
           move.b #$A0,PBCR ; programa submodo da Porta B
           move.b #$FF,PBDDR ; programa direção da Porta B (saída)
           rts