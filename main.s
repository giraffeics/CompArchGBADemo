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
	
	bl ball_init	@ initialize the ball
	bl hoop_init	@ initialize the hoop
	
	bl configure_interrupts	@ set up interrupts
	
	@ loop infinitely
infin:
	swi 0x050000	@ wait for VBlank; overwrites r0 and r1
	
	bl rng_update	@ update pseudorandom number generator
	bl hoop_update	@ update hoop
	bl ball_update	@ update ball
	
	b infin
	
.ltorg

.include "graphics.s"
.include "ball.s"
.include "hoop.s"
.include "interrupts.s"
.include "rng.s"

.align 4
SPR_TILE_DATA:
.incbin "sprites.bin"

.align 4
SPR_PALETTE_DATA:
.incbin "sprites.pal"
