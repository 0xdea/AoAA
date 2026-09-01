// listing6-1.S - Demonstrates using a static base register (X28) to access global variables
//
// ```
// $ ./build listing6-1
// $ ./listing6-1
// Calling Listing 6-1:
// g1: 55, g2: 44, g3: 255, g4: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA// AAAAAAAAAAAAAAAAAAAAAAAAA, g5: 0
// Listing 6-1 terminated.
// ```

#include "include.S"

#define sb x28

// offsets for global variables
g1 = 0x00
g2 = 0x04 // + 4 bytes (word)
g3 = 0x0c // + 8 bytes (dword)
g4 = 0x0e // + 2 bytes (hword)
g5 = 0x8e // + 128 bytes (128 * 1 byte array)

.code

.global _getTitle
.global _asmMain

.pool

title:
	.asciz "Listing 6-1"

fmt:
	.asciz "g1: %d, g2: %d, g3: %d, g4: %s, g5: %d\n"

.balign 4

_getTitle:
	adrl x0, title
	ret

_asmMain:
	// preserve x28 (and x27) on the stack
	stp x28, x27, [sp, #-0x10]!

	enter 0x40

	// initialize sb to point to the globals section
	adrl sb, globals

	// initialize global variables
	mov  w0, #55
	str  w0, [sb, #g1]
	mov  x0, #44
	str  x0, [sb, #g2]
	mov  w0, #0xff
	strh w0, [sb, #g3]

	// printf("g1: %d, g2: %d, g3: %d, g4: %s, g5: %d\n", g1, g2, g3, g4, g5);
	adrl x0, fmt
	ldr  w1, [sb, #g1]
	str  w1, [sp]
	ldr  x2, [sb, #g2]
	str  x2, [sp, #0x08]
	ldrh w3, [sb, #g3]
	str  w3, [sp, #0x10]
	add  x4, sb, #g4
	str  x4, [sp, #0x18]
	ldrb w5, [sb, #g5]
	str  w5, [sp, #0x20]
	bl   _printf

	leave

	// restore x28 (and x27) from the stack
	ldp x28, x27, [sp], #0x10

	ret

.data

globals:

g1:
	.word 0

g2:
	.dword 0

g3:
	.hword 0

g4:
	.fill 128, 1, 0x41

g5:
	.byte 0
