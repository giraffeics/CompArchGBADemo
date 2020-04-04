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

.align 4

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

.align 4

	@ ARGUMENTS:
	@ r0: sprite number
	@ r1: x position
	@ r2: y position
	@ r3: sprite size
position_sprite:
	mov r0, r0, LSL #3		@ shift sprite number left three bits
	add r0, r0, #0x07000000	@ add base address of object attribute memory
	
	mov r3, r3, LSL #14		@ shift size left 14 bits
	orr r1, r1, r3			@ combine rightmost two bits of size with x position
	strh r1, [r0, #2]		@ store halfword in object attribute memory
	
	mov r3, r3, LSR #2		@ shift size right 2 bits
	and r3, r3, #0xC000		@ chop off rightmost two bits of size
	orr r2, r2, r3			@ combine leftmost two bits of size with y position
	strh r2, [r0]			@ store halfword in object attribute memory
	
	bx r14					@ return to caller
	
.ltorg 
	