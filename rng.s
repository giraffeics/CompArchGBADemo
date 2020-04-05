.arm
.text

.comm rng, 4	@ allocate 4 bytes for rng

	@ ARGUMENTS: none
	@ Updates pseudorandom number generator
rng_update:
	ldr 	r0, =0x04000130		@ load inputs into r2
	ldrh 	r2, [r0]

	ldr 	r0, =rng			@ load base of rng variables
	
	ldrh 	r1, [r0, #2]		@ load frame number
	add 	r1, r1, #1			@ increment
	add		r1, r1, r2			@ add input values
	add		r1, r1, r2, LSR #4	@ add input valued, right-shifted by 4 bits
	strh	r1, [r0, #2]		@ store back in memory
	
	ldrh	r2, [r0]			@ load last rng value
	eor		r2, r2, r1			@ xor with frame number
	eor		r2, r2, r1, LSL #6	@ xor with frame number, left-shifted 6 bits
	eor		r2, r2, r1, LSL #12	@ xor with frame number, left-shifted 12 bits
	strh	r2, [r0]			@ store back in memory
	
	bx 		r14
	
.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2
	@ Returns a 16-bit RNG value in r0
rng_generate:
	ldr		r1, =rng			@ load base of rng variables
	
	ldrh	r0, [r1]			@ load last rng value
	mov		r2, r0, LSR #7		@ shift right 7 bits into r2
	mul		r2, r0, r2			@ r2 = r0 * r2
	eor		r0, r0, r2			@ r1 = r0 xor r2
	ldr		r2, =0x0000FFFF
	and		r1, r1, r2			@ chop off upper two bytes
	strh	r0, [r1]			@ store result into memory
	
	bx r14		@ return to caller
	
.ltorg
