.arm
.text

	@ Variables for the hoop
.comm hoop_base, 16

.set hoop_x, 0
.set hoop_y, 4

.align 4

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
hoop_init:
	@ push return address onto stack
	stmdb sp!,{r14}

	@ configure sprite
	mov r0, #01		@ sprite #1
	mov r1, #04		@ tile #2
	mov r2, #00		@ palette #0
	mov r3, #02		@ priority #2
	bl configure_sprite
	
	@ position sprite
	mov r0, #01
	mov r1, #100
	mov r2, #80
	mov r3, #SIZE_32X32
	bl position_sprite
	
	ldr r0, =hoop_base
	mov r1, #100		@ initialize x position to 100
	str r1, [r0, #hoop_x]
	mov r1, #80			@ initialize y position to 80
	str r1, [r0, #hoop_y]
	
	@ pop return address from stack
	ldmia sp!,{r14}
	
	bx r14	@ return to caller

.ltorg

hoop_update:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	@ load inputs into r1
	ldr 	r0, =0x04000130
	ldrh 	r3, [r0]
	
	@ load hoop x position into r1
	ldr		r0, =hoop_base
	ldrh	r1, [r0, #hoop_x]
	
	@ test left & right inputs
	tst		r3, #0b00010000	@ bit test right button
	addeq	r1, r1, #2		@ conditional add
	tst		r3, #0b00100000 @ bit test left button
	subeq	r1, r1, #2		@ conditional subtract
	
	@ store updated hoop x position
	strh	r1, [r0, #hoop_x]
	
	@ load hoop y position into r2
	ldrh 	r2, [r0, #hoop_y]
	
	@ test up & down inputs
	tst		r3, #0b10000000	@ bit test down button
	addeq	r2, r2, #2		@ conditional add
	tst		r3, #0b01000000 @ bit test up button
	subeq	r2, r2, #2		@ conditional subtract
	
	@ store updated hoop y position
	strh	r2, [r0, #hoop_y]
	
	@ call position_sprite
	mov r0, #1
	mov r3, #SIZE_32X32
	bl position_sprite
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14	@ return to caller
	
.ltorg
