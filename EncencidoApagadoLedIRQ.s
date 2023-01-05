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
	
/* Programo contador C1 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
        add     r1, #2     @medio segundos
        str     r1, [r0, #STC1]
	
/* Habilito interrupciones, local y globalmente */
        ldr     r0, =INTBASE
        mov     r1, #0b0010
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0

/* Repetir para siempre */
bucle:  b       bucle

irq_handler:

        push    {r0, r1,r2}          @ Salvo registros
	
	ldr r0, =ledst
	ldr r1, [r0]
	eors r1, #1
	str r1, [r0]

	ldr     r0, =GPBASE
	/* guia bits 10987654321098765432109876543210*/
        ldr   	r1, =0b0001000010000100000111000000000
        streq     r1, [r0, #GPSET0]   
	strne     r1, [r0, #GPCLR0] 
	
	ldr     r0, =STBASE
        mov     r1, #0b0010
	str     r1, [r0, #STCS]
	
	ldr     r1, [r0, #STCLO]
        ldr     r2, =500000
	add	r1,r2
        str     r1, [r0, #STC1]
	
        pop     {r0, r1,r2}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
	
	
ledst: .word 0
