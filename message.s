.arm
.text

	@ variables for message
.comm msg_base, 16

.set msg_x, 0
.set msg_y, 4
.set msg_timer, 8
.set msg_sprite, 12

.align 2

	@ ARGUMENTS: none
	@ Uses r0, r1
message_init:
	ldr r0, =msg_base
	mov r1, #0xFF00		@ initialize timer variable to a very high number
	str r1, [r0, #msg_timer]
	
	bx r14				@ return to caller
	
.ltorg

.align 2

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
message_oof:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	mov		r0, #2	@ sprite #2
	mov		r1, #16	@ tile #16
	mov		r2, #1	@ palette #1
	mov		r3, #0	@ priority #0
	bl		configure_sprite	@ configure sprite 2
	
	bl		rng_generate		@ get a random number
	
	mov		r1, r0, LSR #4		@ shift RNG value right 4 bits into r1
	and		r1, r1, #0x7F		@ select lowest 7 bits
	add		r1, r1, r1, LSR #2	@ multiply r1 by 1.25
	
	and		r2, r0, #0x3F		@ select lowest six bits for r2
	add		r2, r2, r2, LSR #1	@ multiply r2 by 1.5
	
	ldr		r0, =msg_base
	str		r1, [r0, #msg_x]
	str		r2, [r0, #msg_y]
	mov		r1, #0
	str		r1, [r0, #msg_timer]
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14				@ return to caller

.ltorg	

.align 2

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
message_score:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	mov		r0, #2	@ sprite #2
	mov		r1, #8	@ tile #8
	mov		r2, #1	@ palette #1
	mov		r3, #0	@ priority #0
	bl		configure_sprite	@ configure sprite 2
	
	bl		rng_generate		@ get a random number
	
	mov		r1, r0, LSR #4		@ shift RNG value right 4 bits into r1
	and		r1, r1, #0x7F		@ select lowest 7 bits
	add		r1, r1, r1, LSR #2	@ multiply r1 by 1.25
	
	and		r2, r0, #0x3F		@ select lowest six bits for r2
	add		r2, r2, r2, LSR #1	@ multiply r2 by 1.5
	
	ldr		r0, =msg_base
	str		r1, [r0, #msg_x]
	str		r2, [r0, #msg_y]
	mov		r1, #0
	str		r1, [r0, #msg_timer]
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14				@ return to caller

.ltorg	

.align 2

	@ ARGUMENTS: none
message_update:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	ldr		r0, =msg_base
	ldr		r4, [r0, #msg_timer]	@ load message timer into r4
	cmp		r4, #40
	bge		message_update_hide		@ if timer >= 40, hide message
	
	add		r1, r4, #1
	str		r1, [r0, #msg_timer]	@ increment timer and store in memory
	
	tst		r4, #0x01
	beq		message_update_hide		@ if timer is at an odd number, hide message
	
	@ otherwise, show message
	ldr		r1, [r0, #msg_x]
	ldr		r2, [r0, #msg_y]
	mov		r3, #SIZE_64X64
	mov		r0, #2
	ldr		r14, =message_update_end	@ set return address to the end of the function
	b		position_sprite
	
message_update_hide:
	mov		r0, #2
	bl		hide_sprite				@ hide the sprite
	
message_update_end:
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14				@ return to caller

.ltorg
