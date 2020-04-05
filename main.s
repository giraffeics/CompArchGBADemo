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
	
	@ set interrupt handler
	ldr r0, =0x03007FFC
	ldr r1, =interrupt_handler
	str r1, [r0]
	
	@ enable vblank interrupt (REG_DSPSTAT)
	ldr r0, =0x04000004
	ldrh r1, [r0]
	orr r1, r1, #8
	strh r1, [r0]
	
	@ enable vblank interrupt (REG_IE)
	ldr r0, =0x04000200
	ldrh r1, [r0]
	orr r1, #1
	strh r1, [r0]
	
	@ enable interrupts (REG_IME)
	ldr r0, =0x04000208
	mov r1, #1
	strh r1, [r0]
	
	@ loop infinitely
infin:
	swi 0x050000	@ wait for VBlank; overwrites r0 and r1
	
	bl hoop_update	@ update hoop
	bl ball_update	@ update ball
	
	b infin
	
interrupt_handler:
	ldr 	r0, =0x04000200
	ldrh 	r1, [r0]		@ load IE
	ldrh	r2, [r0, #2]	@ load IF
	and 	r1, r1, r2		@ r1 <- IE & IF
	strh	r1, [r0, #2]	@ acknowledge IRQ in IF
	
	ldr 	r0, =0x03007FF8
	ldrh	r2, [r0]
	orr		r1, r1, r2
	strh	r1, [r0]		@ acknowledge IRQ in BIOS
	
	bx r14		@ return
	
.ltorg

.include "graphics.s"
.include "ball.s"
.include "hoop.s"

.align 4
SPR_TILE_DATA:
.incbin "sprites.bin"

.align 4
SPR_PALETTE_DATA:
.incbin "sprites.pal"
