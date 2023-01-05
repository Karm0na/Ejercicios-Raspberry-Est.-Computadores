# Ejercicios-Raspberry-Est.-Computadores

Si tienes una Raspberry pi 3, asegurate de que las siguientes lineas de codigo están al principio del programa:
.text
  mrs r0, cpsr
  mov r0, #0b11010011 @Modo SVC, FIQ&IRQ desact
  msr spsr_cxsf, r0
  add r0, pc, #4
  msr ELR_hyp, r0
  eret
 En el caso de que tengas otra versión, quita esas lineas si están escritas.
 
 Estos programas NO son las soluciones de las prácticas, sino ejercicios que he hecho por mi cuenta teniendo en cuenta lo que suelen poner en los examenes.
