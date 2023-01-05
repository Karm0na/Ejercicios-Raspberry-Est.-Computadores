        .include  "inter.inc"
	
.text
	mrs r0, cpsr
	mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
	msr spsr_cxsf, r0
	add r0, pc, #4
	msr ELR_hyp, r0
	eret
	
	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
	
        ldr     r0, =GPBASE
/* guia bits          xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000000000000001000000000000
        str	r1, [r0, #GPFSEL0]  @ Configura GPIO 4
	
/* guia bits         10987654321098765432109876543210*/
	ldr   r1, =0b00000000000000000000000000010000
	ldr   r4, =STBASE 
	ldr   r5,=956	

bucle:	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100
	beq	bucle1
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	bucle2
	b 	bucle

bucle1:
	ldr	r5, =500
	bl sonido
/* guia bits          10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000010000			@ tambien funciona sin la instruccion ldr al aver solo un gpio
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 4
	bl sonido
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000010000			@ tambien funciona sin la instruccion ldr al aver solo un gpio
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 4
	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000001000
	beq	bucle2
	b bucle1
	
bucle2: 
	ldr	r5, =6000
	bl sonido
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000010000			@ tambien funciona sin la instruccion ldr al aver solo un gpio
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 4
	bl sonido
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000010000			@ tambien funciona sin la instruccion ldr al aver solo un gpio
        str     r1, [r0, #GPCLR0]   @ Apaga GPIO 4
	
	ldr	r1, [r0, #GPLEV0]
	ands	r2, r1, #0b00000000000000000000000000000100
	beq	bucle1
	b bucle2
	

sonido:
	push {r0,r1}
	ldr r0,[r4,#STCLO]
	add r0,r5
ret1:ldr r1,[r4,#STCLO]
	cmp r1,r0
	blo ret1
	pop { r0,r1}
	bx lr

