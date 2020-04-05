

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
hoop_init:
	@ push return address onto stack
	str	r14, [sp, #-4]!

	@ configure sprite
	mov r0, #01
	mov r1, #04
	mov r2, #00
	mov r3, #00
	bl configure_sprite
	
	@ position sprite
	mov r0, #01
	mov r1, #100
	mov r2, #80
	mov r3, #SIZE_32X32
	bl position_sprite
	
	@ pop return address from stack
	ldr	r14, [sp], #4
	
	bx r14	@ return to caller
