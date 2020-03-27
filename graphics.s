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
	mov pc, r14

.ltorg 
