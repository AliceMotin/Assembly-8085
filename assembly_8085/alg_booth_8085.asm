.org 0000h ; Define o endere�o inicial do programa
JMP start ; Desvio para a etiqueta "start" no in�cio do programa

overflow:
    MVI A, 00h ; Move o valor 0000H para A (acumulador)
    STA 4002H ; Armazena o valor 0000H no LSB (menos significativo)
    STA 4003H ; Armazena o valor 0000H no MSB (mais significativo)
    HLT ; Instru��o de parada do programa

;Rotina que trata quando Q-1 � igual a 1 (caso de multiplica��o positiva)
mul_positive:
    STC ; Define o indicador de carry (CY) como 1
    CMC ; Complementa o indicador de carry (CY), definindo-o como 0
    RAR ; Rota��o � direita do acumulador A e o bit mais significativo � copiado em CY
    PUSH PSW ; Empilha o estado do processador (registrador de status)
    ANI 7FH ; Aplica uma opera��o AND l�gica com A (acumulador) e 7FH (01111111) para limpar o bit mais significativo
    MOV B, A ; Move o valor de A para B (registrador tempor�rio)
    POP PSW ; Desempilha o estado do processador
    MOV A, C ; Move o valor de C (multiplicando) para A (acumulador)
    RAR ; Rota��o � direita do acumulador A e o bit mais significativo � copiado em CY
    MOV C, A ; Move o valor de A para C (multiplicando)
    JMP continue ; Desvio para a etiqueta "continue"

;Rotina que trata quando Q-1 � igual a 0 (caso de multiplica��o negativa)
mul_negative:
    STC ; Define o indicador de carry (CY) como 1
    CMC ; Complementa o indicador de carry (CY), definindo-o como 0
    RAR ; Rota��o � direita do acumulador A e o bit mais significativo � copiado em CY
    PUSH PSW ; Empilha o estado do processador (registrador de status)
    ORI 80H ; Aplica uma opera��o OR l�gica com A (acumulador) e 80H (10000000) para definir o bit mais significativo como 1
    MOV B, A ; Move o valor de A para B (registrador tempor�rio)
    POP PSW ; Desempilha o estado do processador
    MOV A, C ; Move o valor de C (multiplicando) para A (acumulador)
    RAR ; Rota��o � direita do acumulador A e o bit mais significativo � copiado em CY
    MOV C, A ; Move o valor de A para C (multiplicando)
    JMP continue ; Desvio para a etiqueta "continue"

;Ele realiza o complemento de 2 em start e usa a instru��o ADD ao inv�s de SUB
;A = A+(-B)
sub:
    LXI H, 0003H ; Carrega o endere�o de mem�ria onde o multiplicador (B) est� armazenado em H e L
    MOV A, B ; Move o valor de B para A (acumulador)
    ADD M ; Adiciona o valor do multiplicador (B) do valor armazenado no endere�o de mem�ria apontado por H e L
    MOV B, A ; Move o resultado da subtra��o para B (multiplicador)
    JMP resume ; Desvio para a etiqueta "resume"

;A = A+B
add:
    LXI H, 4001H ; Carrega o endere�o de mem�ria onde o multiplicador (B) est� armazenado em H e L
    MOV A, B ; Move o valor de B para A (acumulador)
    ADD M ; Adiciona o valor do multiplicador (B) ao valor armazenado no endere�o de mem�ria apontado por H e L
    MOV B, A ; Move o resultado da adi��o para B (multiplicador)
    JMP resume ; Desvio para a etiqueta "resume"

check_q1:
    POP psw ; Desempilha o estado do processador (registrador de status)
    JNC sub ; Desvio para a etiqueta "sub" se o indicador de carry (CY) for 0
    JC resume ; Desvio para a etiqueta "resume" se o indicador de carry (CY) for 1

check_q0:
    POP PSW ; Desempilha o estado do processador (registrador de status)
    JC add ; Desvio para a etiqueta "add" se o indicador de carry (CY) for 1
    JNC resume ; Desvio para a etiqueta "resume" se o indicador de carry (CY) for 0

check_q:
    PUSH PSW ; Empilha o estado do processador (registrador de status) para verificar o valor de Q0
    MOV A, C ; Move o valor de C (multiplicando) para A (acumulador)
    ANI 01H ; Aplica uma opera��o AND l�gica com A (acumulador) e 01H (00000001) para obter o valor de Q0
    JNZ check_q1 ; Desvio para a etiqueta "check_q1" se Q0 for diferente de 0
    JZ check_q0 ; Desvio para a etiqueta "check_q0" se Q0 for igual a 0

start:
    MVI B, 0 ; Move o valor 0 para B (acumulador A)
    LDA 4000H ; Carrega o valor do multiplicando em A (acumulador)
    CPI 80H ; Compara o valor de A com 80H
    JZ overflow ; Desvio para a etiqueta "overflow" se o resultado da compara��o for igual
    MOV C, A ; Move o valor de A para C (multiplicando)
    LDA 4001H ; Carrega o valor do multiplicador em A (acumulador)
    CPI 80H ; Compara o valor de A com 80H
    JZ overflow ; Desvio para a etiqueta "overflow" se o resultado da compara��o for igual
    CMA ; Complementa o valor de A (multiplicador) para obter o complemento de 2
    INR A ; Incrementa A (multiplicador) para obter o 2's complemento
    STA 0003H  ; Armazena o 2's complemento do multiplicador no endere�o de mem�ria 0003H
    MVI D, 8 ; Move o valor 8 para D (contador de sequ�ncia)

    STC ; Define o indicador de carry (CY) como 1
    CMC ; Complementa o indicador de carry (CY), definindo-o como 0

loop:
    JMP check_q ; Desvio para a etiqueta "check_q"

resume:
    MOV A, B ; Move o valor de B (multiplicador) para A (acumulador)
    ORI 00H ; Aplica uma opera��o OR l�gica com A (acumulador) e A para limpar o indicador de carry (CY)
    JP mul_positive ; Desvio para a etiqueta "mul_positive" se o indicador de paridade (P) for 1 (n�mero positivo)
    JM mul_negative ; Desvio para a etiqueta "mul_negative" se o indicador de paridade (P) for 0 (n�mero negativo)

continue:
    DCR D ; Decrementa o valor de D (contador de sequ�ncia)
    MOV A, D ; Move o valor de D para A (acumulador)
    JNZ loop ; Desvio para a etiqueta "loop" se o valor de A for diferente de 0

;Registrador C armazena o LSB 
;Registrador B armazena o MSB

    MOV A, C  ; Move o valor de C para o acumulador A
    STA 4002H
    MOV A, B
    STA 4003H
    HLT ; Instru��o de parada do programa