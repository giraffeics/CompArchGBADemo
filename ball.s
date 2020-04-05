

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
ball_init:
	@ push return address onto stack
	str	r14, [sp, #-4]!

	@ configure sprite
	mov r0, #00
	mov r1, #02
	mov r2, #00
	mov r3, #00
	bl configure_sprite
	
	@ position sprite
	mov r0, #0
	mov r1, #00
	mov r2, #12
	mov r3, #SIZE_16X16
	bl position_sprite
	
	@ pop return address from stack
	ldr	r14, [sp], #4
	
	bx r14	@ return to caller
