// listing5-14.S - Demonstrates a software stack (rewrite of listing5-4)
//
// ```
// $ ./build listing5-14
// $ ./listing5-14
// Calling Listing 5-14:
//                                         *, 20
//                                         *, 19
//                                         *, 18
//                                         *, 17
//                                         *, 16
//                                         *, 15
//                                         *, 14
//                                         *, 13
//                                         *, 12
//                                         *, 11
//                                         *, 10
//                                         *, 9
//                                         *, 8
//                                         *, 7
//                                         *, 6
//                                         *, 5
//                                         *, 4
//                                         *, 3
//                                         *, 2
//                                         *, 1
// Listing 5-14 terminated.
// ```

#include "include.S"

// software stack pointer
#define usp x28

// size to allocate for the software stack
stack_size = 128

.code

.global _getTitle
.global _asmMain

// char *_getTitle(void);
//
// Returns the title string.
_getTitle:
	adrl x0, title
	ret

// void print40spaces(void);
//
// Prints 40 spaces to the console.
print40spaces:
	// preserve registers on the software stack
	stp x19, lr, [usp, #-0x10]!

	mov w19, #40

0:
	adrl x0, space
	bl   _printf
	subs w19, w19, #1
	bne  0b

	// restore registers from the software stack
	ldp x19, lr, [usp], #0x10

	ret

// void _asmMain(void);
_asmMain:
	// make room on the hardware stack
	sub sp, sp, #0x40

	// preserve registers on the hardware stack
	stp usp, lr, [sp, #-0x10]!

	// initialize the software stack pointer
	adrl usp, end_stack

	// save x19 onto the software stack (no need to 16-byte align)
	str x19, [usp, #-0x08]

	mov w19, #20

0:
	bl     print40spaces
	adrl   x0, index
	str    w19, [x0]
	adrl   x0, asterisk
	vparm2 index
	bl     _printf
	subs   w19, w19, #1
	bne    0b

	// restore x19 from the software stack
	ldr x19, [usp], #0x08

	// restore registers from the hardware stack
	ldp usp, lr, [sp], #0x10

	// restore the hardware stack pointer
	add sp, sp, #0x40

	ret

.data
.balign 8

stack:
	.space stack_size, 0

end_stack:

index:
	.word .-.

space:
	.asciz " "

asterisk:
	.asciz "*, %d\n"

title:
	.asciz "Listing 5-14"
