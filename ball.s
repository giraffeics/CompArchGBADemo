.arm
.text

	@ Variables for the ball
.comm ball_base, 20

.set ball_x, 0
.set ball_y, 4
.set ball_hspeed, 8
.set ball_vspeed, 12
.set ball_scored, 16

.align 2

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
ball_init:
	@ push return address onto stack
	stmdb sp!,{r14}

	@ configure sprite
	mov r0, #00		@ sprite #0
	mov r1, #02		@ tile #2
	mov r2, #00		@ palette #0
	mov r3, #01		@ priority #1
	bl configure_sprite
	
	@ position sprite
	mov r0, #0
	mov r1, #00
	mov r2, #12
	mov r3, #SIZE_16X16
	bl position_sprite
	
	bl ball_throw	@ throw the ball, initializing x, y, hspeed, vspeed
	
	ldr	r0, =ball_base
	mov	r1, #0
	str	r1, [r0, #ball_scored]	@ initialize ball_scored to 0
	
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
	
	@ check if the ball has fallen off of the screen
	ldr r1, [r0, #ball_y]
	mov r2, #0xA000
	cmp r1, r2
	bge ball_update_fell
	
	@ if ball has not fallen off screen, we must check for a goal
	ldr r1, [r0, #ball_scored]
	cmp r1, #0
	bne ball_update_end @ skip this check if the ball has already fallen off the screen
	
	@ load ball and hoop position into r1-r4
	ldr r1, [r0, #ball_x]
	ldr r2, [r0, #ball_y]
	mov r1, r1, LSR #8
	mov r2, r2, LSR #8
	ldr r0, =hoop_base
	ldr r3, [r0, #hoop_x]
	ldr r4, [r0, #hoop_y]
	
	@ check collision
	@ ball is 13x13, hoop is 20 wide
	@ hoop is offset by (5, 18)
	@ check that ball center is in the hoop
	@ (ball_x + 13/2) - hoop_x - 6 >= 0; 		ball_x - hoop_x + 0 >= 0
	@ (ball_x + 13/2) - hoop_x - 6 - 20 <= 0; 	ball_x - hoop_x - 19 <= 0
	@ ball_y - hoop_y - 18 <= 0
	@ ball_y - hoop_y - 18 + 13 >= 0
	@ also, ball vspeed must be positive
	subs	r1, r1, r3
	blt		ball_update_end	@ jump to end if (ball_x - hoop_x + 1 >= 0) fails
	subs	r1, r1, #19
	bgt		ball_update_end	@ jump to end if (ball_x - hoop_x - 20 <= 0) fails
	sub		r1, r2, r4
	subs	r1, r1, #18
	bgt		ball_update_end @ jump to end if (ball_y - hoop_y - 18 <= 0) fails
	adds	r1, r1, #13
	blt		ball_update_end	@ jump to end if (ball_y - hoop_y - 18 + 13 >= 0) fails
	
	@ ball is in the right place, check that it is moving down
	ldr		r0, =ball_base
	ldr		r1, [r0, #ball_vspeed]
	cmp		r1, #0
	blt		ball_update_end
	
	@ ball is moving down and is in the net; we've scored a goal
	mov		r1, #1
	str		r1, [r0, #ball_scored]	@ remember this in RAM
	ldr		r14, =ball_update_end	@ set return address to the end of this function
	b		message_score
	
ball_update_fell:
	@ if a goal wasn't scored, show the "oof" message
	ldr r1, [r0, #ball_scored]
	cmp r1, #0
	bleq	message_oof
	
	@ reset ball_scored
	ldr r0, =ball_base
	mov r1, #0
	str r1, [r0, #ball_scored]
	bl	ball_throw	@ rethrow the ball
	
ball_update_end:
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	
.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2
	@ Returns x, y in r1, r2
ball_throw:
	@ push return address onto stack
	stmdb 	sp!,{r14}
	
	@ get rng values into r2 and r3
	bl 		rng_generate
	and		r2, r0, #0x3F			@ use right byte of the RNG halfword for hspeed
	and		r3, r0, #0x3F00			@ use left byte of the RNG halfword for vspeed
	mov		r3, r3, LSR #8
	
	@ load base address of ball variables
	ldr 	r0, =ball_base
	
	@ set hspeed = (rand(0...63) + 64) * 5; final range = 320...635
	mov		r1, #5
	add		r2, r2, #64
	mul		r1, r2, r1
	str 	r1, [r0, #ball_hspeed]
	
	@ set vspeed = (rand(0...63) + 128) * -7; final range = -896...-1337
	ldr		r1, =-7	
	add		r3, r3, #0x80
	mul		r1, r3, r1
	str 	r1, [r0, #ball_vspeed]
	
	@ initialize x, y position to the bottom-left of the screen
	mov 	r1, #0x0000				
	str 	r1, [r0, #ball_x]		@ initialize x position to 0
	mov 	r2, #0xA000				
	str 	r2, [r0, #ball_y]		@ initialize y position to 160
	
	@ restore stack and return to caller
	ldmia 	sp!,{r14}
	bx 		r14	@ return to caller
	
.ltorg
	