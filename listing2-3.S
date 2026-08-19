// listing2-3.S - Demonstrates two's complement operation and input of numeric values
//
// ```
// $ ./build listing2-3
// $ ./listing2-3
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

.equ maxLen, 256

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

	// read an unsigned integer from the user
	adrl x0, promptStr
	bl   _printf

	adrl x0, input
	mov  x1, #maxLen
	bl   _readline

	// i = strtol( str, NULL, 10 );
	adrl x0, input
	mov  x1, xzr
	mov  x2, #10
	bl   _strtol
	adrl x1, intValue
	str  x0, [x1]

	adrl   x0, fmtStr1
	vparm2 intValue
	bl     _printf

	// invert all bits of the input number
	adrl x1, intValue
	ldr  x0, [x1]
	mvn  x0, x0
	str  x0, [x1]

	adrl   x0, fmtStr2
	vparm2 intValue
	bl     _printf

	// add 1 to the previously inverted input number
	adrl x1, intValue
	ldr  x0, [x1]
	add  x0, x0, #1
	str  x0, [x1]

	adrl   x0, fmtStr3
	vparm2 intValue
	bl     _printf

	adrl   x0, fmtStr4
	vparm2 intValue
	bl     _printf

	// negate the current value and print as a signed integer (this will print the original value)
	adrl x1, intValue
	ldr  x0, [x1]
	mvn  x0, x0
	add  x0, x0, #1
	str  x0, [x1]

	adrl   x0, fmtStr5
	vparm2 intValue
	bl     _printf

	// directly perform the two's complement operation on the input number
	adrl x1, intValue
	ldr  x0, [x1]
	neg  x0, x0
	str  x0, [x1]

	adrl   x0, fmtStr6
	vparm2 intValue
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
	.asciz "Listing 2-3"

promptStr:
	.asciz "Enter an integer between 0 and 127: "

fmtStr1:
	.asciz "Value in hexadecimal: %x\n"

fmtStr2:
	.asciz "Invert all the bits (hexadecimal): %x\n"

fmtStr3:
	.asciz "Add 1 (hexadecimal): %x\n"

fmtStr4:
	.asciz "Output as signed integer: %d\n"

fmtStr5:
	.ascii "Negate again and output as signed integer:"
	.asciz " %d\n"

fmtStr6:
	.asciz "Using neg instruction: %d\n"

intValue:
	.8byte 0

saveLR:
	.8byte 0

input:
	.space maxLen
