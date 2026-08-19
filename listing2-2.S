// listing2-2.S - Demonstrates AND, OR, XOR, and NOT operations
//
// ```
// $ ./build listing2-2
// $ ./listing2-2
// Calling Listing 2-2:
// f0f0f0f AND f0f0f0f0 = 0
// f0f0f0f OR f0f0f0f0 = ffffffff
// f0f0f0f XOR f0f0f0f0 = ffffffff
// NOT f0f0f0f = f0f0f0f0
// NOT f0f0f0f0 = f0f0f0f
// NOT 12345678 = edcba987
// Listing 2-2 terminated.
// ```

.macro adrl reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

.macro vparm2 mem
adrl   x1, \mem
ldr    x1, [x1]
str    x1, [sp]
.endm

.macro vparm3 mem
adrl   x2, \mem
ldr    x2, [x2]
str    x2, [sp, #8]
.endm

.macro vparm4 mem
adrl   x3, \mem
ldr    x3, [x3]
str    x3, [sp, #16]
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

	// demonstrate the AND operation
	adrl x0, leftOp
	ldr  x1, [x0]
	adrl x0, rightOp1
	ldr  x2, [x0]
	and  x3, x1, x2
	adrl x0, result
	str  x3, [x0]

	adrl   x0, fmtStr1
	vparm2 leftOp
	vparm3 rightOp1
	vparm4 result
	bl     _printf

	// demonstrate the OR operation
	adrl x0, leftOp
	ldr  x1, [x0]
	adrl x0, rightOp1
	ldr  x2, [x0]
	orr  x3, x1, x2
	adrl x0, result
	str  x3, [x0]

	adrl   x0, fmtStr2
	vparm2 leftOp
	vparm3 rightOp1
	vparm4 result
	bl     _printf

	// demonstrate the XOR operation
	adrl x0, leftOp
	ldr  x1, [x0]
	adrl x0, rightOp1
	ldr  x2, [x0]
	eor  x3, x1, x2
	adrl x0, result
	str  x3, [x0]

	adrl   x0, fmtStr3
	vparm2 leftOp
	vparm3 rightOp1
	vparm4 result
	bl     _printf

	// demonstrate the NOT operation
	adrl x0, leftOp
	ldr  x1, [x0]
	mvn  w1, w1
	adrl x0, result
	str  x1, [x0]

	adrl   x0, fmtStr4
	vparm2 leftOp
	vparm3 result
	bl     _printf

	adrl x0, rightOp1
	ldr  x1, [x0]
	mvn  w1, w1
	adrl x0, result
	str  x1, [x0]

	adrl   x0, fmtStr4
	vparm2 rightOp1
	vparm3 result
	bl     _printf

	adrl x0, rightOp2
	ldr  x1, [x0]
	mvn  w1, w1
	adrl x0, result
	str  x1, [x0]

	adrl   x0, fmtStr4
	vparm2 rightOp2
	vparm3 result
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
	.asciz "Listing 2-2"

fmtStr1:
	.asciz "%lx AND %lx = %lx\n"

fmtStr2:
	.asciz "%lx OR %lx = %lx\n"

fmtStr3:
	.asciz "%lx XOR %lx = %lx\n"

fmtStr4:
	.asciz "NOT %lx = %lx\n"

leftOp:
	.8byte 0xf0f0f0f

rightOp1:
	.8byte 0xf0f0f0f0

rightOp2:
	.8byte 0x12345678

result:
	.8byte 0

saveLR:
	.8byte 0
