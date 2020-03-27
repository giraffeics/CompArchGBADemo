.arm
.text
.global main

main:
	@ set up REG_DISPCNT (the LCD controller)
	mov r0, #0x4000000
	ldr r1, =0x1000
	str r1, [r0]
	
	@ copy sprite color palettes from ROM to VRAM
	ldr r0, =0x05000200
	ldr r1, =SPR_PALETTE_DATA
	mov r2, #0x0200
	bl vram_copy
	
	@ copy sprite tile data from ROM to VRAM
	ldr r0, =0x06010000
	ldr r1, =SPR_TILE_DATA
	mov r2, #0x8000
	bl vram_copy
	
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

.include "graphics.s"

.align 4
SPR_TILE_DATA:
.incbin "sprites.bin"

.align 4
SPR_PALETTE_DATA:
.incbin "sprites.pal"
