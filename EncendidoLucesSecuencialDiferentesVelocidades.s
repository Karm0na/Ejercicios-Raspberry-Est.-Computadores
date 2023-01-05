.include  "inter.inc"
 
 .text
/* Agrego vector interrupcion */
        ADDEXC  0x18, irq_handler
		  mrs r0, cpsr
  mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
  msr spsr_cxsf, r0
  add r0, pc, #4
  msr ELR_hyp, r0
  eret

/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000
	
        ldr     r0, =GPBASE
/* guia bits              xx999888777666555444333222111000*/
        ldr     r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]
	
	/* guia bits      xx999888777666555444333222111000*/
        ldr    r1, =0b00000000001000000000000000001001
        str     r1, [r0, #GPFSEL1]
	
	/* guia bits      xx999888777666555444333222111000*/
        ldr     r1, =0b00000000001000000000000001000000
        str     r1, [r0, #GPFSEL2]
	
/* Programo contador C3 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
        add     r1, #0x50000    @medio segundos
        str     r1, [r0, #STC3]
	
/* Habilito interrupciones, local y globalmente */
        ldr     r0, =INTBASE
        mov     r1, #0b1000
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0
	
/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupción */
irq_handler:

        push    {r0, r1,r2,r3,r5,r6}          @ Salvo registros

	ldr     r1, =GPBASE
	ldr r2, = cuenta
/* guia bits           10987654321098765432109876543210*/
        ldr     r3, =0b00001000010000100000111000000000
	str    r3, [r1,#GPCLR0] @ Apago LED
	ldr r3, [r2] @ Leo variable cuenta
	subs r3, #1 @ Decremento
	moveq r3, #10 @ Si es 0, volver a 6
	str r3, [r2] @ Escribo cuenta
	ldr r3, [r2, +r3, LSL #2] @ Leo secuencia #2]
	str r3, [r1, # GPSET0 ] @ Escribo secuencia en LEDs
	
	 ldr      r0, =STBASE
	 mov   r1, #0b1000
	 str     r1, [r0, #STCS]
	 
	ldr r6, [r2]
	
	cmp r6, #1
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =500000
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	cmp r6, #2
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =250000
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	cmp r6, #3
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =125000
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	cmp r6, #4
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =62500
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	cmp r6, #5
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =31250
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	cmp r6, #6
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =15625
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
		cmp r6, #7
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =31250
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
		cmp r6, #8
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =62500
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
		cmp r6, #9
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =100000
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
		cmp r6, #10
	ldreq     r1, [r0, #STCLO]
        ldreq     r5, =200000
	addeq	r1,r5
        streq     r1, [r0, #STC3]
	
	
        pop     {r0, r1,r2,r3,r5,r6}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
	
cuenta : .word 1 @ Entre 1 y 6, LED a encender
/* guia bits                     7654321098765432109876543210 */
secuen : 
		.word     0b0000000000000000000010000000000
		.word     0b0000000000000000000100000000000
		.word     0b0000000000000100000000000000000
		.word     0b0000000010000000000000000000000
		.word     0b0001000000000000000000000000000
		.word     0b0000000010000000000000000000000
		.word     0b0000000000000100000000000000000
		.word     0b0000000000000000000100000000000
		.word     0b0000000000000000000010000000000
		.word     0b0000000000000000000001000000000
