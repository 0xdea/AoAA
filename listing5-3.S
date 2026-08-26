// listing5-3.S - Demonstrates preserving registers across procedure calls (bugged version)
//
// ```
// $ ./build listing5-3
// $ ./listing5-3
// Calling Listing 5-3:
//                                         *, 0
//                                         *, 0
//                                         *, 0
//                                         *, 0
//                                         *, 0
//                                         *, 0
// ...
// [infinite loop]
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

// void print40spaces(void);
//
// Prints 40 spaces to the console.
print40spaces:
	enter 64

	mov w19, #40

0:
	adrl x0, space
	bl   _printf
	subs w19, w19, #1
	bne  0b

	leave
	ret

// void _asmMain(void);
_asmMain:
	// preserve non-volatile registers
	stp x19, x20, [sp, #-16]!

	enter 64

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

	leave

	// restore non-volatile registers
	ldp x19, x20, [sp], #16

	ret

.data

index:
	.word .-.

space:
	.asciz " "

asterisk:
	.asciz "*, %d\n"

title:
	.asciz "Listing 5-3"
