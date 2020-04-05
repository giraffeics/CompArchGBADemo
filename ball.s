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
	
	ldr r0, =ball_base
	mov r1, #0x0000				@ initialize x position to 0
	str r1, [r0, #ball_x]
	mov r1, #0x0C00				@ initialize y position to 12
	str r1, [r0, #ball_y]
	mov r1, #0x0100
	str r1, [r0, #ball_hspeed]	@ initialize hspeed to 1
	mov r1, #0x0080
	str r1, [r0, #ball_vspeed]	@ initialize vspeed to 0.5
	
	@ pop return address from stack
	ldmia sp!,{r14}
	
	bx r14	@ return to caller

.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
ball_update:
	@ push return address onto stack
	stmdb sp!,{r14}

	@ load and update x position
	ldr r0, =ball_base
	ldr r1, [r0, #ball_x]
	ldr r3, [r0, #ball_hspeed]
	add r1, r1, r3
	str r1, [r0, #ball_x]
	
	@ load and update y position
	ldr r2, [r0, #ball_y]
	ldr r3, [r0, #ball_vspeed]
	add r2, r2, r3
	str r2, [r0, #ball_y]
	
	@ shift out subpixel positions and call position_sprite
	mov r1, r1, LSR #8
	mov r2, r2, LSR #8
	mov r0, #0
	mov r3, #SIZE_16X16
	bl position_sprite
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	
.ltorg
	