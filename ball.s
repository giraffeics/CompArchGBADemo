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
	
	bl ball_throw	@ throw the ball, initializing x, y, hspeed, vspeed
	
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
	
	@ adjust vspeed to account for gravity
	ldr r0, =ball_base
	ldr r1, [r0, #ball_vspeed]
	add r1, r1, #0x15
	str r1, [r0, #ball_vspeed]
	
	@ rethrow ball if it has fallen off of the screen
	ldr r1, [r0, #ball_y]
	mov r2, #0xA000
	cmp r1, r2
	blge ball_throw
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	
.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2
	@ Returns x, y in r1, r2
ball_throw:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	ldr r0, =ball_base
	mov r1, #0x0210
	str r1, [r0, #ball_hspeed]	@ initialize hspeed to 2+1/16
	ldr r1, =-0x0500
	str r1, [r0, #ball_vspeed]	@ initialize vspeed to -5
	mov r1, #0x0000				
	str r1, [r0, #ball_x]		@ initialize x position to 0
	mov r2, #0xA000				
	str r2, [r0, #ball_y]		@ initialize y position to 160
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	
.ltorg
	