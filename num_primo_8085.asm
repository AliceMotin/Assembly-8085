.org 0000h ; Iniciar programa no endereço 0000h

standby:
	JMP standby ; Saltar para o modo "standby"

.org 0024h ; Endereço da interrupção TRAP

check_prime:
	IN 00H ; Lê o número na entrada 00h e passa para A
	MVI C, 00H ; Limpa o registrador C
	MOV E, A ; Move o conteúdo de A para E
	MOV B, A ; Move o conteúdo de A para B
    
loop:
	MOV D, E ; Move o conteúdo de E para D

compare:
	CMP D ; Compara D com A, se A > D e A não é 00h, CY=0
	JC label ; Se CY=1 pule para label
	SUB D ; Subtrair D de A, se A-D=0, Z=1
	JNZ compare ; Se Z=0 pule para compare

label:
	CPI 00H ; Compara A com 00h, A=0, Z=1
	JNZ skip ; Se Z=0 pule para skip
	INR C ; Incrementa C em 1

skip:
	MOV A, B ; Move o conteúdo de B para A
	DCR E ; Decrementa E em 1, se E-1=0, Z=1
	JNZ loop ; Se Z=0 pule para loop
	
      ; Verificar se C é igual a 02h
	MVI A, 02h ; Move o valor 02h para A
	CMP C ; Compara C com A, A=C, Z=1
	JNZ not_prime ; Se Z=0 pule para not_prime

prime:
	; O número é primo, escrever 01h na porta de saída
	MVI A, 01h ; Move o valor 01h para A
      OUT 00h ; O valor de A é transferido para porta 00h
      EI 
      RET

not_prime:
	; O número não é primo, escrever 10h na porta de saída
	MVI A, 10h ; Move o valor 10h para A
	OUT 00h ; O valor de A é transferido para porta 00h
	EI 
	RET



