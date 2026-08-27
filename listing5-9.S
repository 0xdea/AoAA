// listing5-9.S - Demonstrates passing parameters in the code stream
//
// ```
// $ ./build listing5-9
// $ ./listing5-9
// Calling Listing 5-9:
// Hello, world
// Listing 5-9 terminated.
// ```

#include "include.S"

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// print
//
// This procedure expects a zero-terminated string to follow the call.

// offset to return address from the frame pointer
retaddr = 8

print:
	// preserve 16 (volatile) registers (x0-x15)
	stp x0, x1, [sp, #-16]!
	stp x2, x3, [sp, #-16]!
	stp x4, x5, [sp, #-16]!
	stp x6, x7, [sp, #-16]!
	stp x8, x9, [sp, #-16]!
	stp x10, x11, [sp, #-16]!
	stp x12, x13, [sp, #-16]!
	stp x14, x15, [sp, #-16]!

	enter 0

	// load the address of the string immediately following the call
	mov x1, lr

	// compute the length of the string
	// at the end of the loop, x1 points just beyond the NUL byte
0:
	ldrb w2, [x1], #1
	cmp  w2, #0
	bne  0b

	// x2 = strlen(lr), excluding the NUL terminator
	sub x2, x1, lr
	sub x2, x2, #1

	// make sure the address in x1 is 4-byte aligned
	// x1 = (x1 + 3) & 0xffff_ffff_ffff_fffc
	add x1, x1, #3
	and x1, x1, #-4

	// save x1 as the new return address
	str x1, [fp, #retaddr]

	// write(1, lr, x2)
	mov x0, #1
	mov x1, lr
	bl  _write

	leave

	// restore 16 (volatile) registers (x0-x15)
	ldp x14, x15, [sp], #16
	ldp x12, x13, [sp], #16
	ldp x10, x11, [sp], #16
	ldp x8, x9, [sp], #16
	ldp x6, x7, [sp], #16
	ldp x4, x5, [sp], #16
	ldp x2, x3, [sp], #16
	ldp x0, x1, [sp], #16

	ret

// void _asmMain(void);
_asmMain:
	enter 0

	bl     print
	.asciz "Hello, world\n"

	// specify again the alignment here, otherwise the assembler won't align the next instructions properly
	.balign 4

	leave
	ret

.pool

title:
	.asciz "Listing 5-9"
