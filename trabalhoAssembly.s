
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;	Notamos que o enunciado na lista geral de exercícios e no pdf contendo
;	somente os enunciados dos trabalhos estão ligeiramente diferentes. Nossa
;	implementação está de acordo com a versão da lista (15 elementos na pilha,
;	sem botão para operação de módulo).

;	Mesmo assim, fizemos um branch contendo as instruções necessárias para calcular
;	A % B, ele apenas não é chamado em nenhum lugar, pois todos os botões já
;	estão ocupados. O layout dos botões pode ser encontrado mais abaixo.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

	;r0, r1 e r2 -> usados como entradas e saídas do plugin Embest Board
	;		Além disso, servem como operandos nas operações
	;r3 -> o valor sendo digitado no momento
	;r4 -> usado para auxiliar no valor que está sendo digitado. Se digitarmos
	;		1 e depois 2, teremos 1*10 + 2 = 12. Mas como não é possível fazer
	;		"mul r0, r1, #ctc", precisamos que o 10 esteja em um registrador
mov r4, #10
	;r5 -> cópia de outros registradores. Salva o endereço da pilha na hora
	;		de imprimir os valores no display LCD e também auxilia no valor
	;		sendo digitado. Como não é possível fazer "mul rX, rX, rY"
	;		(equivalente a x = x*y), precisamos	de um terceiro registrador,
	;		com uma cópia de rX
	;r6 -> ponteiro que percorre a pilha quando vai imprimir os valores e
	;		salva a posição onde será inserido o próximo valor digitado
	;r7 -> fundo da pilha (endereço do primeiro byte do vetor)
	;r8 -> número de elementos da pilha
ldr r7, =pilha
ldr r6, =pilha ;ponteiro aponta para o fundo da pilha
mov r8, #0 ;começa com 0 elementos

inicio:
	cmp r0, #0		;se nenhum botão foi pressionado, o r0 vai ter 0
	beq loopBotoes 	;se isso acontecer, não precisa mudar nada na tela
	
	mov r0, #0x00 
	swi 0x201 ;apaga os LEDs
	swi 0x206 ;limpa a tela LCD
	mov r0, #0
	mov r1, #0
	mov r2, r3 ;imprime o valor que está sendo digitado
	swi 0x205
	
	cmp r8, #0
	beq loopBotoes ;se não tem elementos na pilha, não precisa imprimir nada
	
	mov r5, r6 	;cria uma cópia do r6 porque esse valor será perdido
				;quando for imprimir a pilha
	mov r0, #30
	loopPilha:
		sub r6, r6, #4 ;desce o ponteiro para a próxima posição
		ldr r2, [r6] ;pega o valor do topo da pilha
		swi 0x205 ;imprime o valor
		add r1, r1, #1 ;vai pra próxima linha do display LCD
		cmp r6, r7 ;compara a posição atual com o fundo da pilha
		beq continua ;se são iguais, então não precisa mais imprimir, sai do loop
		b loopPilha ;senão, imprime o próximo
	continua:
		mov r6, r5 ;volta o endereço do topo guardado
		
loopBotoes:
	swi 0x202		;verifica se algum dos botões pretos foi pressionado
	cmp r0, #0x02	;se foi o botão esquerdo, reinicia a pilha
	beq reiniciaPilha

	swi 0x203 ;descobre que botão azul foi pressionado
	;Os botões azuis possuem o seguinte layout
	;	[1]	[2]	[3]		[+]
	;	[4]	[5]	[6]		[-]
	;	[7]	[8]	[9]		[*]
	;	[<-][0]	[ENTER]	[/]
	;
	;Explicando melhor o que acontece, temos 16 botões azuis
	;Em swi 0x203, r0 recebe um número com somente um bit ligado.
	;Se for o botão da posição 0, então o 1ºbit estará ligado
	;	-> 000001 = 01 em hexa
	;Se for o botao da 5ª posição, então o 6º bit estará ligado,
	;	-> 100000 = 20 em hexa
	
	cmp r0, #0x01 ;se foi o botão 1
	beq um

	cmp r0, #0x02 ;se foi o botão 2
	beq dois
	
	cmp r0, #0x04 ;se foi o botão 3
	beq tres
	
	cmp r0, #0x08 ;se foi o botão soma
	beq soma
	
	cmp r0, #0x10 ;se foi o botão 4
	beq quatro

	cmp r0, #0x20 ;se foi o botão 5
	beq cinco
	
	cmp r0, #0x40 ;se foi o botão 6
	beq seis
	
	cmp r0, #0x80 ;se foi o botão sub
	beq subtracao
	
	cmp r0, #0x100 ;se foi o botão 7
	beq sete
	
	cmp r0, #0x200 ;se foi o botão 8
	beq oito
	
	cmp r0, #0x400 ;se foi o botão 9
	beq nove
	
	cmp r0, #0x800 ;se foi o botão mult
	beq multiplicacao
	
	cmp r0, #0x1000 ;se foi o botão "<-"
	beq backspace
	
	cmp r0, #0x2000 ;se foi o botão 0
	beq zero
	
	cmp r0, #0x4000 ;se foi o botão Enter
	beq enter
	
	cmp r0, #0x8000 ;se foi o botão div
	beq divisao
	
	;se não foi nenhum, continua no loop
	b loopBotoes
	
		
	;~~~~~~~~~~~~~~~~~~~~~~~~
	;Valores da calculadora~
	;~~~~~~~~~~~~~~~~~~~~~~~~
	um:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #1
		b inicio
	dois:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #2
		b inicio
	tres:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #3
		b inicio
	quatro:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #4
		b inicio
	cinco:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #5
		b inicio
	seis:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #6
		b inicio
	sete:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #7
		b inicio
	oito:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #8
		b inicio
	nove:
		mov r5, r3
		mul r3, r5, r4
		add r3, r3, #9
		b inicio
	zero:
		mov r5, r3
		mul r3, r5, r4
		b inicio
		
	;~~~~~~~~~~~~~~~~~~~~~~~~
	;Outros botões
	;~~~~~~~~~~~~~~~~~~~~~~~~
	enter:
		cmp r8, #15
		beq naoCabeMais ;se já tem 15 elementos, não aceita o valor
		str r3, [r6], #4 ;guarda o valor na pilha
		mov r3, #0	;zera para o próximo valor começar em 0
		add r8, r8, #1
		b inicio
		
	backspace:
		;para apagar o último dígito, basta dividir por 10
		mov r5, #0	;r5 começa com 0 e no fim terá o resultado da divisão	
		dividePorDez:
			add r5, r5, #1 ;r5++  (número de divisões feitas até agora +1)
			sub r3, r3, #10
			cmp r3, #0
			beq terminouDivDez ;se for igual a zero, é divisão exata
			bgt dividePorDez ;se for maior, continua no loop
			sub r5, r5, #1 ;se for menor, temos que lembrar de descontar 1
		terminouDivDez:
		mov r3, r5
		b inicio
		
	reiniciaPilha:
		ldr r6, =pilha ;ponteiro aponta para o fundo da pilha
		mov r8, #0 ;volta pra 0 elementos
		b inicio
		
		
	;~~~~~~~~~~~~~~~~~~~~~~~~
	;Operações
	;~~~~~~~~~~~~~~~~~~~~~~~~
	soma:
		cmp r8, #0			;se tem menos de 2 elementos
		beq naoTemElementos ;não é possível realizar a operação
		cmp r8, #1
		beq naoTemElementos
		sub r6, r6, #4	;volta o ponteiro para o último valor preenchido
		ldr r1, [r6]	;lê o valor do topo da pilha
		sub r6, r6, #4 	;atualiza o ponteiro
		ldr r2, [r6] 	;lê o segundo valor
		add r1, r1, r2 	;r1 = r1 + r2
		str r1, [r6], #4;guarda na pilha
		sub r8, r8, #1 	;numElementos--
		b inicio
		
	subtracao:
		cmp r8, #0
		beq naoTemElementos
		cmp r8, #1
		beq naoTemElementos
		sub r6, r6, #4	;volta o ponteiro para o último valor preenchido
		ldr r1, [r6]	;lê o valor do topo da pilha
		sub r6, r6, #4	;atualiza o ponteiro
		ldr r2, [r6]	;lê o segundo valor
		sub r1, r1, r2	;r1 = r1 - r2
		str r1, [r6], #4;guarda na pilha
		sub r8, r8, #1 	;agora tem um elemento a menos
		b inicio
		
	multiplicacao:
		cmp r8, #0
		beq naoTemElementos
		cmp r8, #1
		beq naoTemElementos
		sub r6, r6, #4	;volta o ponteiro para o último valor preenchido
		ldr r1, [r6]	;lê o valor do topo da pilha
		sub r6, r6, #4	;atualiza o ponteiro
		ldr r2, [r6]	;lê o segundo valor
		mul r0, r1, r2	;r1 = r1 * r2
		str r0, [r6], #4;guarda na pilha
		sub r8, r8, #1 	;agora tem um elemento a menos
		b inicio
		
	divisao:
		cmp r8, #0
		beq naoTemElementos
		cmp r8, #1
		beq naoTemElementos
		sub r6, r6, #4	;volta o ponteiro para o último valor preenchido
		ldr r1, [r6]	;lê o valor do topo da pilha
		sub r6, r6, #4	;atualiza o ponteiro
		ldr r2, [r6]	;lê o segundo valor
		
		cmp r2, #0
		beq divisaoPorZero ;testa se é divisão por zero
		
		;não tem DIV, então tem que ir subtraindo r1 de r3 até que dê <= 0
		mov r0, #0		;r0 começa com 0 e no fim terá o resultado da divisão	
		loopDiv:
			add r0, r0, #1 ;r0++  (número de divisões feitas até agora +1)
			sub r1, r1, r2 ;r1 -= r2
			cmp r1, #0
			;sub r2, r2, r1 -> para inverter os operandos da divisao r2 -= r1
			;cmp r2, #0
			beq terminouDiv ;se for igual a zero, é divisão exata
			bgt loopDiv ;se for maior, continua no loop
			sub r0, r0, #1 ;se for menor, temos que lembrar de descontar 1
		terminouDiv:
		str r0, [r6], #4;guarda na pilha
		sub r8, r8, #1	;agora tem um elemento a menos
		b inicio
	
	modulo:
		cmp r8, #0
		beq naoTemElementos
		cmp r8, #1
		beq naoTemElementos
		sub r6, r6, #4	;volta o ponteiro para o último valor preenchido
		ldr r1, [r6]	;lê o valor do topo da pilha
		sub r6, r6, #4	;atualiza o ponteiro
		ldr r2, [r6]	;lê o segundo valor
		
		cmp r2, #0
		beq divisaoPorZero ;testa se é divisão por zero
		
		;não tem DIV, então tem que ir subtraindo r1 de r3 até que dê <= 0
		loopMod:
			sub r1, r1, r2 ;r1 -= r2
			cmp r1, #0
			;sub r2, r2, r1 -> para inverter os operandos da divisao r2 -= r1
			;cmp r2, #0
			beq terminouMod ;se for igual a zero, é divisão exata
			bgt loopMod ;se for maior, continua no loop
			add r1, r1, r2 ;se for menor, temos que lembrar de somar novamente
		terminouMod:
		str r1, [r6], #4;guarda na pilha
		sub r8, r8, #1	;agora tem um elemento a menos
		b inicio
		
	;~~~~~~~~~~~~~~~~~~~~~~~~
	;Possíveis erros
	;~~~~~~~~~~~~~~~~~~~~~~~~
	naoCabeMais:
		mov r0, #0x01
		swi 0x201 ;se é problema com a pilha, acende o LED direito
		mov r0, #2
		mov r1, #2
		ldr r2, =cheiapt1
		swi 0x204
		add r1, r1, #1
		add r1, r1, #1
		ldr r2, =cheiapt2
		swi 0x204
		add r1, r1, #1
		ldr r2, =cheiapt3
		swi 0x204
		add r1, r1, #1
		ldr r2, =cheiapt4
		swi 0x204
		b loopBotoes
	
	naoTemElementos:
		mov r0, #0x01
		swi 0x201 ;se é problema com a pilha, acende o LED direito
		mov r0, #2
		mov r1, #2
		ldr r2, =vaziapt1
		swi 0x204
		add r1, r1, #1
		ldr r2, =vaziapt2
		swi 0x204
		add r1, r1, #1
		ldr r2, =vaziapt3
		swi 0x204
		add r1, r1, #1
		ldr r2, =vaziapt4
		swi 0x204
		b loopBotoes
	
	divisaoPorZero:
		mov r0, #0x02
		swi 0x201 ;se é divisão por 0, acende o LED esquerdo
		mov r0, #2
		mov r1, #2
		ldr r2, =fraseZero
		swi 0x204
		add r6, r6, #8 	;volta o ponteiro para o topo da pilha, já que
						;cancelou a operação
		b loopBotoes
		
fim:
	b fim

pilha: .space 60 ;aloca 15 espaços de 4 bytes (32 bits)

cheiapt1: .ascii "Pilha cheia!\0"
cheiapt2: .ascii "Realize uma operação ou\0"
cheiapt3: .ascii "clique no botao esquerdo\0"
cheiapt4: .ascii "para resetar a pilha.\0"

vaziapt1: .ascii "Elementos insuficientes!\0"
vaziapt2: .ascii "Adicione mais elementos na\0"
vaziapt3: .ascii "pilha antes de realizar uma\0"
vaziapt4: .ascii "operacao.\0"

fraseZero: .ascii "ERRO: Divisao por zero.\0"
