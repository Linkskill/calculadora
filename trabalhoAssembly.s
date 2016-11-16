

;r0, r1 e r2 s�o usados como entradas e sa�das do plugin Embest Board
;r3 � o valor digitado
;r4 � usado para auxiliar na multiplica��o para os valor que est� sendo
;		digitado. Se digitarmos 1 e depois 2, teremos 1*10 + 2 = 12
;		S� � usado porque n�o existe uma instru��o "mul r0, r1, #ctc"
mov r4, #10
;r5 tamb�m � usado para auxiliar no valor sendo digitado
;	N�o � poss�vel fazer "mul r0, r0, r1" (x = x*y)
;	Ent�o temos que usar outro registrador com uma c�pia do valor
;r6 ser� o ponteiro que percorre a pilha
;r7 ser� o fundo da pilha
;r8 ser� o n�mero de elementos da pilha
ldr r7, =pilha
mov r6, r7 ; ponteiro aponta para o fundo da pilha
mov r8, #0 ;come�a com 0 elementos


inicio:
	cmp r0, #0 ;se n�o pressionou nenhum bot�o, o r0 vai ter 000000000000
	bne continua
	swi 0x206 ;limpa a tela LCD
continua:
	mov r0, #0
	mov r1, #0
	mov r2, r3 ;imprime o valor que est� sendo digitado no topo
	swi 0x205
	
	cmp r8, #0 ;compara o topo atual com o fundo da pilha
	beq loopBotoes ;se n�o tem elementos, n�o precisa imprimir nada
	;mov r4, r6
	loopPilha:
		add r1, r1, #1 ;vai pra pr�xima linha do display LCD
		ldr r2, [r6] ;pega o valor do topo da pilha
		swi 0x205 ;imprime o valor
		sub r6, r6, #4 ;desce o ponteiro para a pr�xima posi��o
		cmp r6, r7 ;compara o topo com o fundo da pilha
		beq loopBotoes ;se s�o iguais, ent�o n�o precisa mais imprimir, sai do loop
		b loopPilha ;sen�o, imprime o pr�ximo
	
	loopBotoes:
		mov r6, r4
		mov r4, #10
		swi 0x203 ;descobre que bot�o foi pressionado
		;lembrando que os bot�es azuis tem o seguinte layout
		;	[1]	[2]	[3]		[+]
		;	[4]	[5]	[6]		[-]
		;	[7]	[8]	[9]		[*]
		;	[]	[0]	[ENTER]	[/]
		;
		;Explicando melhor o que acontece, temos 16 bot�es azuis
		;Em swi 0x203, r0 recebe um n�mero com somente um bit ligado.
		;Se for o bot�o da posi��o 0, ent�o o 1�bit estar� ligado
		;	-> ...01 = ...01 em hexa
		;Se for o botao da 5� posi��o, ent�o o 6� bit estar� ligado,
		;	-> 100000 = 20 em hexa
			
		mov r5, r3 ;cria uma c�pia do valor pra usar no "valor = valor*10"
		
		cmp r0, #0x01 ;se foi o bot�o 1
		beq um
	
		cmp r0, #0x02 ;se foi o bot�o 2
		beq dois
		
		cmp r0, #0x04 ;se foi o bot�o 3
		beq tres
		
		cmp r0, #0x10 ;se foi o bot�o 4
		beq quatro
	
		cmp r0, #0x20 ;se foi o bot�o 5
		beq cinco
		
		cmp r0, #0x40 ;se foi o bot�o 6
		beq seis
		
		cmp r0, #0x100 ;se foi o bot�o 7
		beq sete
		
		cmp r0, #0x200 ;se foi o bot�o 8
		beq oito
		
		cmp r0, #0x400 ;se foi o bot�o 9
		beq nove
		
		;cmp r0, #0x1000 -> n�o faz nada
	
		cmp r0, #0x2000 ;se foi o bot�o 0
		beq zero
		
		cmp r0, #0x4000 ;se foi o bot�o Enter
		beq enter

		;cmp r0, #0x08 ;se foi o bot�o soma
		;beq soma
		
		;cmp r0, #0x80 ;se foi o bot�o sub
		;beq subtracao
		
		;cmp r0, #0x800 ;se foi o bot�o mult
		;beq multiplicacao
		
		;cmp r0, #0x8000 ;se foi o bot�o div
		;beq divisao
		b inicio
		
		
		
		;Valores da calculadora
	um:
		mul r3, r5, r4
		add r3, r3, #1
		b inicio
	dois:
		mul r3, r5, r4
		add r3, r3, #2
		b inicio
	tres:
		mul r3, r5, r4
		add r3, r3, #3
		b inicio
	quatro:
		mul r3, r5, r4
		add r3, r3, #4
		b inicio
	cinco:
		mul r3, r5, r4
		add r3, r3, #5
		b inicio
	seis:
		mul r3, r5, r4
		add r3, r3, #6
		b inicio
	sete:
		mul r3, r5, r4
		add r3, r3, #7
		b inicio
	oito:
		mul r3, r5, r4
		add r3, r3, #8
		b inicio
	nove:
		mul r3, r5, r4
		add r3, r3, #9
		b inicio
	zero:
		mul r3, r5, r4
		add r3, r3, #0
		b inicio
	enter:
		cmp r8, #15
		beq naoCabeMais
		str r3, [r6], #4
		add r8, r8, #1
		b inicio
		
naoCabeMais:
	mov r0, #5
	mov r1, #0
	ldr r2, =frasept1
	swi 0x204
	mov r1, #1
	ldr r2, =frasept2
	swi 0x204
	mov r1, #2
	ldr r2, =frasept3
	swi 0x204
	b inicio
	
fim:
	b fim
	
frasept1: .ascii "Pilha cheia, realize uma opera��o"
frasept2: .ascii "ou clique no bot�o preto esquerdo"
frasept3: .ascii "para resetar a pilha"
pilha: .space 60 ;aloca 15 espa�os de 4 bytes (32 bits)
