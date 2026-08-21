// listing4-1.S - Demonstrates pointer constants
//
// ```
// $ ./build listing4-1
// $ ./listing4-1
// Calling Listing 4-1:
// pb's value is 0x102640002
// *pb's value is 2
// Listing 4-1 terminated.
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

_getTitle:
	adrl x0, titleStr
	ret

_asmMain:
	// save LR
	str lr, [sp, #-16]!

	// make room on the stack
	sub sp, sp, #256

	// fetch data at *pbVar
	adrl x0, pbVar
	ldr  x0, [x0]
	ldrb w0, [x0]

	// store the value at pbValue
	adrl x1, pbValue
	str  w0, [x1]

	// print pointer and value
	adrl   x0, fmtStr
	vparm2 pbVar
	vparm3 pbValue
	bl     _printf

	// restore stack pointer
	add sp, sp, #256

	// restore LR
	ldr lr, [sp], #16

	ret

.data
.balign 8

// address of "2" in bb
pb = bb + 2

bb:
	.byte 0
	.byte 1, 2, 3, 4, 5, 6, 7

pbVar:
	// pointer to "2" in bb
	.8byte pb

pbValue:
	.4byte 0

fmtStr:
	.ascii "pb's value is %p\n"
	.asciz "*pb's value is %d\n"

titleStr:
	.asciz "Listing 4-1"
