; Esta rotina programa a Porta A do MC68230 e gera sinais para o motor de passo.
; O tempo de espera determina o tempo de cada passo do motor.

comeco  MOVE.B  #$30,$FE8001    ;programa modo
        MOVE.B  #$A0,$FE800D    ;programa submodo
        MOVE.B  #$FF,$FE8005    ;programa direcao da Porta A (saida)
estado1
        MOVE.B  #$00,$FE8011    ;envia dado para Porta A

estado2 MOVE.B  #$0C,$FE8011    ;envia dado para Porta A
        BSR     espera

estado3 MOVE.B  #$06,$FE8011    ;envia dado para Porta A
        BSR     espera

estado4 MOVE.B  #$03,$FE8011    ;envia dado para Porta A
        BSR     espera

estado5 MOVE.B  #$09,$FE8011    ;envia dado para Porta A
        BSR     espera
        JMP     estado2         ;volta para estado2

espera  MOVE.L  #$7FFF,D0       ;parametro tempo para funcao de espera
loop    SUBQ.L  #1,D0
        BNE     loop
        RTS

END
