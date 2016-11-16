

;r0, r1 e r2 são usados como entradas e saídas do plugin Embest Board
;r3 é o valor sendo digitado
;r4 é usado para auxiliar na multiplicação para os valor que está sendo
;		digitado. Se digitarmos 1 e depois 2, teremos 1*10 + 2 = 12
;		Só é usado porque não existe uma instrução "mul r0, r1, #ctc"
mov r4, #10
;r5 também é usado para auxiliar no valor sendo digitado
;	Não é possível fazer "mul r0, r0, r1" (x = x*y)
;	Então temos que usar outro registrador com uma cópia do valor
;r6 será o ponteiro que percorre a pilha
;r7 será o fundo da pilha
;r8 será o número de elementos da pilha
ldr r7, =pilha
ldr r6, =pilha
;mov r6, r7 ; ponteiro aponta para o fundo da pilha
mov r8, #0 ;começa com 0 elementos


inicio:
	cmp r0, #0 ;se nenhum botão foi pressionado, o r0 vai ter 0
	beq continua ;se não pressionou nenhum botão, não precisa mudar nada na tela
	swi 0x206 ;limpa a tela LCD
	mov r0, #0
	mov r1, #0
	mov r2, r3 ;imprime o valor que está sendo digitado no topo
	swi 0x205
	
	cmp r8, #0
	beq loopBotoes ;se não tem elementos, não precisa imprimir nada
	
	mov r5, r6 	;cria uma cópia do r6 pois esse valor será perdido
			;quando for imprimir a pilha
	loopPilha:
		add r1, r1, #1 ;vai pra próxima linha do display LCD
		sub r6, r6, #4 ;desce o ponteiro para a próxima posição
		ldr r2, [r6] ;pega o valor do topo da pilha
		swi 0x205 ;imprime o valor
		cmp r6, r7 ;compara o topo atual com o fundo da pilha
		beq loopBotoes ;se são iguais, então não precisa mais imprimir, sai do loop
		b loopPilha ;senão, imprime o próximo
	mov r6, r5 ;volta o endereço do topo guardado
continua:
	loopBotoes:
		swi 0x203 ;descobre que botão foi pressionado
		;lembrando que os botões azuis tem o seguinte layout
		;	[1]	[2]	[3]		[+]
		;	[4]	[5]	[6]		[-]
		;	[7]	[8]	[9]		[*]
		;	[]	[0]	[ENTER]		[/]
		;
		;Explicando melhor o que acontece, temos 16 botões azuis
		;Em swi 0x203, r0 recebe um número com somente um bit ligado.
		;Se for o botão da posição 0, então o 1ºbit estará ligado
		;	-> ...01 = ...01 em hexa
		;Se for o botao da 5ª posição, então o 6º bit estará ligado,
		;	-> 100000 = 20 em hexa
			
		mov r5, r3 	;cria uma cópia do valor pois não dá pra fazer "mul r3, r3, r4"
				;Os registradores precisam ser diferentes
		
		cmp r0, #0x01 ;se foi o botão 1
		beq um
	
		cmp r0, #0x02 ;se foi o botão 2
		beq dois
		
		cmp r0, #0x04 ;se foi o botão 3
		beq tres
		
		cmp r0, #0x10 ;se foi o botão 4
		beq quatro
	
		cmp r0, #0x20 ;se foi o botão 5
		beq cinco
		
		cmp r0, #0x40 ;se foi o botão 6
		beq seis
		
		cmp r0, #0x100 ;se foi o botão 7
		beq sete
		
		cmp r0, #0x200 ;se foi o botão 8
		beq oito
		
		cmp r0, #0x400 ;se foi o botão 9
		beq nove
		
		;cmp r0, #0x1000 -> não faz nada
	
		cmp r0, #0x2000 ;se foi o botão 0
		beq zero
		
		cmp r0, #0x4000 ;se foi o botão Enter
		beq enter

		;cmp r0, #0x08 ;se foi o botão soma
		;beq soma
		
		;cmp r0, #0x80 ;se foi o botão sub
		;beq subtracao
		
		;cmp r0, #0x800 ;se foi o botão mult
		;beq multiplicacao
		
		;cmp r0, #0x8000 ;se foi o botão div
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

pilha: .space 60 ;aloca 15 espaços de 4 bytes (32 bits)
frasept1: .ascii "Pilha cheia, realize uma operação"
frasept2: .ascii "ou clique no botão preto esquerdo"
frasept3: .ascii "para resetar a pilha"
