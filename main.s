.arm
.text
.global main

main:
	@ set up REG_DISPCNT (the LCD controller)
	mov r0, #0x4000000
	ldr r1, =0x1000
	str r1, [r0]

@	@ load values needed to fill VRAM with colored pixels
@	mov r0, #0x6000000	@ address of VRAM
@	mov r1, #0xFF00		@ a blue color
@	mov r2, #0x9600		@ number of halfwords that make up the entire screen in VRAM
@	
@	@ store blue color into every pixel in VRAM
@loop1:
@	strh r1, [r0], #2
@	subs r2, r2, #1
@	bne loop1

	@ copy sprite color palettes from ROM to VRAM
	mov r0, #0x05000000
	add r0, r0, #0x0200
	add r4, r0, #0x0200
	ldr r1, =SPR_PALETTE_DATA
palette_copy_loop:
	ldrh r2, [r1], #2
	strh r2, [r0], #2
	cmp r0, r4
	bne palette_copy_loop
	
	@ copy sprite tile data from ROM to VRAM
	mov r0, #0x06000000
	add r0, r0, #0x00010000
	add r4, r0, #0x00008000
	ldr r1, =SPR_TILE_DATA
tile_copy_loop:
	ldrh r2, [r1], #2
	strh r2, [r0], #2
	cmp r0, r4
	bne tile_copy_loop
	
	@ display sprite 1 on screen
	mov r0, #0x07000000
	ldr r1, =0x0010		@ Attribute 0
	strh r1, [r0], #2
	ldr r1, =0x4010		@ Attribute 1
	strh r1, [r0], #2
	ldr r1, =0x0002		@ Attribute 2
	strh r1, [r0], #2
	ldr r1, =0x0000		@ Attribute 3
	strh r1, [r0], #2
	
	@ display sprite 2 on screen
	ldr r1, =0x001F		@ Attribute 0
	strh r1, [r0], #2
	ldr r1, =0x8010		@ Attribute 1
	strh r1, [r0], #2
	ldr r1, =0x0004		@ Attribute 2
	strh r1, [r0], #2
	ldr r1, =0x0000		@ Attribute 3
	strh r1, [r0], #2
	
	
	@ loop infinitely
infin:
	swi 0x05	@ wait for VBlank; overwrites r0 and r1
	b infin
	
.ltorg

.align 4
SPR_TILE_DATA:
.incbin "sprites.bin"

.align 4
SPR_PALETTE_DATA:
.incbin "sprites.pal"