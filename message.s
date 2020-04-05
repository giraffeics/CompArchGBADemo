.arm
.text

	@ variables for message
.comm msg_base, 16

.set msg_x, 0
.set msg_y, 4
.set msg_timer, 8
.set msg_sprite, 12

.align 4

	@ ARGUMENTS: none
	@ Uses r0, r1
message_init:
	ldr r0, =msg_base
	mov r1, #0xFF00		@ initialize timer variable to a very high number
	str r1, [r0, #msg_timer]
	
	bx r14				@ return to caller
	
.ltorg

.align 4

	@ ARGUMENTS: none
message_update:
	@ push return address onto stack
	stmdb sp!,{r14}
	
	@ do things
	
	@ pop return address from stack
	ldmia sp!,{r14}
	bx r14				@ return to caller
