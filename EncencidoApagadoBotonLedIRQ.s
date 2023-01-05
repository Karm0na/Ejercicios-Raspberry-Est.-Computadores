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
/* guia bits           xx999888777666555444333222111000*/
        ldr     r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]
	
	/* guia bits  xx999888777666555444333222111000*/
        ldr    r1, =0b00000000001000000000000000001001
        str     r1, [r0, #GPFSEL1]
	
	/* guia bits   xx999888777666555444333222111000*/
        ldr     r1, =0b00000000001000000000000001000000
        str     r1, [r0, #GPFSEL2]
	
/* Habilito pines GPIO 2 (boton) para interrupciones*/
        mov     r1, #0b00000000000000000000000000001100
        str     r1, [r0, #GPFEN0]
        ldr     r0, =INTBASE
	
/* Habilito interrupciones, local y globalmente */
        mov     r1, #0b00000000000100000000000000000000
/* guia bits           10987654321098765432109876543210*/
        str     r1, [r0, #INTENIRQ2]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0

/* Repetir para siempre */
bucle:  b       bucle

irq_handler:

        push    {r0, r1,r2}          @ Salvo registros

	ldr     r0, =GPBASE
	
	/* Consulto si se ha pulsado el boton GPIO2 */
        ldr     r2, [r0, #GPEDS0]
	mov	r3, r2 
        ands    r2, #0b00000000000000000000000000000100
	
/* Si: Activo GPIO 22*/
/* guia bits            10987654321098765432109876543210*/
        ldrne   r1, =0b00000000010000000000101000000000
	strne   r1, [r0, #GPSET0]
	ldrne   r1, =0b00001000000000100000010000000000
	strne   r1, [r0, #GPCLR0]
	
	movne r1, #0b00000000000000000000000000000100
	strne r1, [r0, #GPEDS0]
	
/* Consulto si se ha pulsado el boton GPIO3 */
        ldr     r2, [r0, #GPEDS0]
	mov	r3, r2 
        ands    r2, #0b00000000000000000000000000001000
	
/* Si: Activo GPIO 27*/
/* guia bits               10987654321098765432109876543210*/
	ldrne   r1, =0b00001000000000100000010000000000
	strne   r1, [r0, #GPSET0]
        ldrne   r1, =0b00000000010000000000101000000000
	strne   r1, [r0, #GPCLR0]
	
	movne r1, #0b00000000000000000000000000001000
	strne r1, [r0, #GPEDS0]
	
	
	
        pop     {r0, r1,r2}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
