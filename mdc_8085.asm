.org 1000h ; Iniciar programa no endereço 1000h
	  LXI H, 2050H ; Aponta para o primeiro número
	  MOV A, M     ; Carrega o primeiro no acumulador
	  INX H        ; Aponta para o próximo local, 2051h
	  MOV B, M     ; Carrega o segundo número

loop:	  
	  CMP B        ; Compara B com A
	  JZ store     ; A = B, pula para store, Z=0
	  JC change    ; Se B > A, troque B por A, CY=1
	  SUB B        ; Se B < A, subtraia B de A, CY=0
	  JMP loop     ; Pula para loop

change:   
 	  MOV C, B     ; Carrega C com B
	  MOV B, A     ; Move A para B
        MOV A, C     ; Move C para A
	  JMP loop     ; Pula para loop

store:  
	  STA 2052H    ; Armazena o valor na memória
	  HLT          ; Fim do programa