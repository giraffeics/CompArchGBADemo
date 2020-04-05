.arm
.text

	@ Variables for the ball
.comm ball_base, 16

.set ball_x, 0
.set ball_y, 4
.set ball_hspeed, 8
.set ball_vspeed, 12

.align 4

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
ball_init:
	@ push return address onto stack
	stmdb sp!,{r14}

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
	ldmia sp!,{r14}
	
	bx r14	@ return to caller

.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
ball_update:
	@ push return address onto stack
	stmdb sp!,{r14}

	ldr r0, =ball_base
	ldr r1, [r0, #ball_x]
	add r1, r1, #1
	and r1, r1, #0xFF
	str r1, [r0, #ball_x]
	
	ldr r2, [r0, #ball_y]
	mov r0, #0
	mov r3, #SIZE_16X16
	bl position_sprite
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	