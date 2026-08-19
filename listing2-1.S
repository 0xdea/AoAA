// listing2-1.S - Displays some numeric values
//
// ```
// $ ./build listing2-1
// $ ./listing2-1
// Calling Listing 2-1:
// i=1, converted to hex=1
// j=123, converted to hex=7b
// k=456789, converted to hex=6f855
// Listing 2-1 terminated.
// ```

// loads a memory address into a register
.macro adrl reg, mem
adrp   \reg, \mem@PAGE          // \reg = page address of \mem
add    \reg, \reg, \mem@PAGEOFF // \reg += offset within page
.endm

// loads parameter 2 of a variadic function onto the stack
.macro vparm2 mem
adrl   x1, \mem
ldr    x1, [x1]
str    x1, [sp]
.endm

// loads parameter 3 of a variadic function onto the stack
.macro vparm3 mem
adrl   x2, \mem
ldr    x2, [x2]
str    x2, [sp, #8]
.endm

.text
.balign 4

.global _getTitle

_getTitle:
	adrl x0, titleStr
	ret

.global _asmMain

_asmMain:
	// make room on the stack
	sub sp, sp, #64

	// save LR
	adrl x0, saveLR
	str  lr, [x0]

	// printf("i=%d, converted to hex=%x\n", i, i);
	adrl   x0, fmtStrI
	vparm2 i
	vparm3 i
	bl     _printf

	// printf("j=%d, converted to hex=%x\n", j, j);
	adrl   x0, fmtStrJ
	vparm2 j
	vparm3 j
	bl     _printf

	// printf("k=%d, converted to hex=%x\n", k, k);
	adrl   x0, fmtStrK
	vparm2 k
	vparm3 k
	bl     _printf

	// restore LR
	adrl x0, saveLR
	ldr  lr, [x0]

	// restore stack pointer
	add sp, sp, #64

	ret

.data
.balign 4

titleStr:
	.asciz "Listing 2-1"

fmtStrI:
	.asciz "i=%d, converted to hex=%x\n"

fmtStrJ:
	.asciz "j=%d, converted to hex=%x\n"

fmtStrK:
	.asciz "k=%d, converted to hex=%x\n"

i:
	.8byte 1

j:
	.8byte 123

k:
	.8byte 456789

saveLR:
	.8byte 0
