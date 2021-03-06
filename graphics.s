.arm
.text

@ Define sprite sizes
.set SIZE_8X8,		0x00
.set SIZE_16X16,	0x01
.set SIZE_32X32,	0x02
.set SIZE_64X64,	0x03
.set SIZE_16X8,		0x04
.set SIZE_32X8,		0x05
.set SIZE_32X16,	0x06
.set SIZE_64X32,	0x07
.set SIZE_8X16,		0x08
.set SIZE_8X32,		0x09
.set SIZE_16X32,	0x0A
.set SIZE_32X64,	0x0B

.align 2

	@ ARGUMENTS:
	@ r0: base address in VRAM
	@ r1: base address in ROM
	@ r2: length in bytes (must be a multiple of 2)
	@ r3: not an argument, used as a temporary register
vram_copy:
	@ copy data from ROM to VRAM
	add r2, r0, r2
vram_copy_loop:
	ldrh r3, [r1], #2
	strh r3, [r0], #2
	cmp r0, r2
	bne vram_copy_loop
	bx r14

.ltorg 

.align 2

	@ ARGUMENTS:
	@ r0: sprite number
	@ r1: x position
	@ r2: y position
	@ r3: sprite size
position_sprite:
	@ calculate base address of this sprite
	mov r0, r0, LSL #3		
	add r0, r0, #0x07000000
	
	@ sanitize inputs by chopping off high parts
	ldr r4, =0x01FF	
	and r1, r1, r4
	ldr r4, =0x00FF
	and r2, r2, r4
	
	@ combine size with x position, store in OAM
	mov r3, r3, LSL #14
	orr r1, r1, r3
	strh r1, [r0, #2]
	
	@ combine size with y position, store in OAM
	mov r3, r3, LSR #2	
	and r3, r3, #0xC000	
	orr r2, r2, r3	
	strh r2, [r0]
	
	@ return to caller
	bx r14
	
.ltorg 

.align 2

	@ ARGUMENTS:
	@ r0: sprite number
hide_sprite:
	@ calculate base address of this sprite
	mov 	r0, r0, LSL #3
	add 	r0, r0, #0x07000000
	
	@ set invisible flag in attribute 0
	mov		r1, #0x0200
	strh	r1, [r0]
	
	@ return to caller
	bx r14

.ltorg
	
.align 2

	@ ARGUMENTS:
	@ r0: sprite number
	@ r1: tile number
	@ r2: palette number
	@ r3: priority
configure_sprite:
	@ calculate base address of this sprite
	mov 	r0, r0, LSL #3
	add 	r0, r0, #0x07000000
	
	@ combine tile, palette, priority; store in OAM
	orr 	r1, r1, r2, LSL #12
	orr		r1, r1, r3, LSL #10	
	strh	r1, [r0, #4]
	
	@ return to caller
	bx r14	
