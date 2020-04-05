.arm
.text

configure_interrupts:
	@ set interrupt handler
	ldr r0, =0x03007FFC
	ldr r1, =interrupt_handler
	str r1, [r0]
	
	@ enable vblank interrupt (REG_DSPSTAT)
	ldr r0, =0x04000004
	ldrh r1, [r0]
	orr r1, r1, #8
	strh r1, [r0]
	
	@ enable vblank interrupt (REG_IE)
	ldr r0, =0x04000200
	ldrh r1, [r0]
	orr r1, #1
	strh r1, [r0]
	
	@ enable interrupts (REG_IME)
	ldr r0, =0x04000208
	mov r1, #1
	strh r1, [r0]
	
	bx r14	@ return to caller

.ltorg

interrupt_handler:
	ldr 	r0, =0x04000200
	ldrh 	r1, [r0]		@ load IE
	ldrh	r2, [r0, #2]	@ load IF
	and 	r1, r1, r2		@ r1 <- IE & IF
	strh	r1, [r0, #2]	@ acknowledge IRQ in IF
	
	ldr 	r0, =0x03007FF8
	ldrh	r2, [r0]
	orr		r1, r1, r2
	strh	r1, [r0]		@ acknowledge IRQ in BIOS
	
	bx r14		@ return
	
.ltorg
