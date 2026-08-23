// listing4-4.S - Demonstrates lack of type checking in pointer access
//
// ```
// $ ./build listing4-4
// $ ./listing4-4
// Calling Listing 4-4:
// Input a string: Hello world
// 0: hex value of char read: 6c6c6548
// 1: hex value of char read: 6f6c6c65
// 2: hex value of char read: 206f6c6c
// 3: hex value of char read: 77206f6c
// 4: hex value of char read: 6f77206f
// 5: hex value of char read: 726f7720
// 6: hex value of char read: 6c726f77
// 7: hex value of char read: 646c726f
// 8: hex value of char read: 646c72
// 9: hex value of char read: 646c
// 10: hex value of char read: 64
// Listing 4-4 terminated.
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

maxLen = 256

.text
.balign 4

.global _getTitle
.global _asmMain

_getTitle:
	adrl x0, titleStr
	ret

_asmMain:
	// function prologue
	str lr, [sp, #-16]!
	sub sp, sp, #256

	// bufPtr = malloc(maxLen);
	mov  x0, maxLen
	bl   _malloc
	adrl x1, bufPtr
	str  x0, [x1]

	// printf("Input a string: ");
	adrl x0, prompt
	bl   _printf

	// bytesRead = readline(bufPtr, maxLen);
	adrl x0, bufPtr
	ldr  x0, [x0]
	mov  x1, maxLen
	bl   _readline

	cmp x0, #-1
	beq allDone

	adrl x1, bytesRead
	str  x0, [x1]

	// display the data back to the user
	mov  x1, xzr
	adrl x0, bufIndex
	str  x1, [x0]

dispLp:
	adrl x0, bufIndex
	ldr  x1, [x0]
	adrl x2, bufPtr
	ldr  x2, [x2]
	ldr  w0, [x2, x1] // bug: load 32-bit word instead of byte!

	adrl   x1, valToPrint
	str    w0, [x1]
	adrl   x0, fmtStr
	vparm2 bufIndex
	vparm3 valToPrint
	bl     _printf

	adrl x0, bufIndex
	ldr  x1, [x0]
	add  x1, x1, #1
	str  x1, [x0]

	adrl x0, bytesRead
	ldr  x0, [x0]
	cmp  x1, x0
	blo  dispLp

allDone:
	// free(bufPtr);
	adrl x0, bufPtr
	ldr  x0, [x0]
	bl   _free

	// function epilogue
	add sp, sp, #256
	ldr lr, [sp], #16

	ret

.data

valToPrint:
	.4byte .-.

bufIndex:
	.8byte .-.

bufPtr:
	.8byte .-.

bytesRead:
	.8byte .-.

prompt:
	.asciz "Input a string: "

fmtStr:
	.asciz "%d: hex value of char read: %x\n"

titleStr:
	.asciz "Listing 4-4"
