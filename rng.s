.arm
.text

.comm rng, 9, 4		@ allocate 9 bytes for rng

.set rng_last, 		0	@ last generated RNG value
.set rng_counter, 	2	@ frame counter
.set rng_rotsalt,	4	@ 32-bit "rotating salt"
.set rng_framesalt, 8	@ 8-bit "frame salt" generated each frame by rng_update

	@ ARGUMENTS: none
	@ Initializes pseudorandom number generator
rng_init:
	@ load RNG variable base
	ldr		r0, =rng
	
	@ initialize rotating salt to an arbitrary constant
	ldr		r1, =0x79C51A5E
	str		r1, [r0, #rng_rotsalt]
	
	@ initialize counter to zero
	mov		r1, #0
	strb	r1, [r0, #rng_counter]
	
	@ initialize "last generated value" to an arbitrary constant
	ldr		r1, =0x6B61
	strh	r1, [r0, #rng_last]
	
	@ return to caller
	bx		r14
	
.ltorg

	@ ARGUMENTS: none
	@ Updates pseudorandom number generator
rng_update:
	@ load RNG variable base
	ldr		r0, =rng
	
	@ rotate the rotating salt variable by 19 bits
	ldr		r1, [r0, #rng_rotsalt]
	mov		r1, r1, ROR #19
	str		r1, [r0, #rng_rotsalt]
	
	@ load, increment, and store the counter
	ldrh	r1, [r0, #rng_counter]
	add		r1, r1, #1
	strh	r1, [r0, #rng_counter]
	
	@ load time salt into r3; this will change every ~2 seconds
	ldr		r3, =TIME_SALTS
	mov		r2, r1, LSR #7
	and		r2, r2, #0x0F
	ldrb	r3, [r3, r2]
	
	@ load D-Pad inputs into r2
	ldr		r2, =0x04000130
	ldrh	r2, [r2]
	mov		r2, r2, LSR #4
	and		r2, r2, #0x0F
	
	@ generate and store frame salt variable
	mov		r1, r1, LSL #4	@ incorporate frame counter
	orr		r1, r1, r2		@ incorporate D-Pad inputs
	eor		r1, r1, r3		@ incorporate time salt
	strb	r1, [r0, #rng_framesalt]
	
	bx 		r14
	
.ltorg

	@ ARGUMENTS: none
	@ Uses r0, r1, r2, r3
	@ Returns a 16-bit RNG value in r0
rng_generate:
	@ load RNG variable base
	ldr		r3, =rng
	
	@ load frame salt into r2, duplicate it to get a 16-bit number
	ldrb	r2, [r3, #rng_framesalt]
	add		r2, r2, LSL #8
	
	@ rotate the rotating salt variable by 11 bits, xor with frame salt, store
	ldr		r1, [r3, #rng_rotsalt]
	mov		r1, r1, ROR #11
	eor		r1, r1, r2
	str		r1, [r3, #rng_rotsalt]
	
	@ load the previous RNG value, xor with rotating salt, store
	ldrh	r0, [r3, #rng_last]
	eor		r0, r0, r1
	strh	r0, [r3, #rng_last]
	
	@ clip return value down to a 16-bit value
	ldr		r1, =0x0000FFFF
	and		r0, r0, r1
	
	bx r14		@ return to caller
	
.ltorg

TIME_SALTS:
	.byte 47, 177, 158, 64
	.byte 67, 71, 255, 160
	.byte 233, 191, 190, 207
	.byte 60, 40, 203, 133
