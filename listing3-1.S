// listing3-1.S - Demonstrates address expressions
//
// ```
// $ ./build listing3-1
// $ ./listing3-1
// Calling Listing 3-1:
// i[0] = 0
// i[1] = 1
// i[2] = 2
// i[3] = 3
// Listing 3-1 terminated.
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

.macro vparm5 mem
adrl   x4, \mem
ldr    x4, [x4]
str    x4, [sp, #24]
.endm

.text
.balign 4

.global _getTitle
.global _asmMain

i:
	.4byte 0, 1, 2, 3

_getTitle:
	adrl x0, titleStr
	ret

_asmMain:
	// make room on the stack
	sub sp, sp, #256

	// save LR
	adrl x0, saveLR
	str  lr, [x0]

	// demonstrate the use of address expressions
	adrl   x0, fmtStr1
	ldr    w1, i + 0
	adrl   x2, outputVal
	str    w1, [x2]
	vparm2 outputVal
	bl     _printf

	adrl   x0, fmtStr2
	ldr    w1, i + 4
	adrl   x2, outputVal
	str    w1, [x2]
	vparm2 outputVal
	bl     _printf

	adrl   x0, fmtStr3
	ldr    w1, i + 8
	adrl   x2, outputVal
	str    w1, [x2]
	vparm2 outputVal
	bl     _printf

	adrl   x0, fmtStr4
	ldr    w1, i + 12
	adrl   x2, outputVal
	str    w1, [x2]
	vparm2 outputVal
	bl     _printf

	// restore LR
	adrl x0, saveLR
	ldr  lr, [x0]

	// restore stack pointer
	add sp, sp, #256

	ret

.data

titleStr:
	.asciz "Listing 3-1"

fmtStr1:
	.asciz "i[0] = %d\n"

fmtStr2:
	.asciz "i[1] = %d\n"

fmtStr3:
	.asciz "i[2] = %d\n"

fmtStr4:
	.asciz "i[3] = %d\n"

outputVal:
	.4byte 0

saveLR:
	.8byte 0
