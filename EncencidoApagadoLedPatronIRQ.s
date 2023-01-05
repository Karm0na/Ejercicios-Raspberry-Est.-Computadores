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
	
	mov r3, #0
	
        ldr     r0, =GPBASE
/* guia bits          xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000000001001
        str	r1, [r0, #GPFSEL1] 
	
/* guia bits          xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]

/* guia bits          xx999888777666555444333222111000*/
        ldr   	r1, =0b00001000000000000000000000000000
        str	r1, [r0, #GPFSEL0]
	
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

        push    {r0, r1}          @ Salvo registros
	ldr     r0, =GPBASE	
	
	cmp r3, #0
	beq caso1
	
	cmp r3, #1
	beq caso2
	
	cmp r3, #2
	beq caso3
	
	mov r3, #0


reprogramar:
/*cargo de nuevo el contador*/
	ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
        add     r1, #0x50000     @0.5 segundos
        str     r1, [r0, #STC1]
	
/*habilito la interrupci�n*/	
	mov r1, #0b0010
	str     r1, [r0, #STCS]
	
        pop     {r0, r1}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
	
caso1:
	mov r3, #1
	
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0001000010000000000000000000000
        str     r1, [r0, #GPCLR0] 
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0000000000000000000001000000000
	str     r1, [r0, #GPSET0] 
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0000000000000000000010000000000
        str     r1, [r0, #GPSET0] 

	b reprogramar
caso2:
	mov r3, #2
	
	/* guia bits          10987654321098765432109876543210*/
        mov   	r1, #0b00000000000000000000011000000000
        str     r1, [r0, #GPCLR0]
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0000000000000100000100000000000
        str     r1, [r0, #GPSET0] 
	
	b reprogramar
caso3:
	mov r3, #0
	
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0000000000000100000100000000000
        str     r1, [r0, #GPCLR0] 
	/* guia bits        10987654321098765432109876543210*/
        mov   	r1, #0b0001000010000000000000000000000
        str     r1, [r0, #GPSET0] 
	
	b reprogramar