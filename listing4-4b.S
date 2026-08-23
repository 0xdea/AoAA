// listing4-4b.S - Demonstrates lack of type checking in pointer access (fixed/optimized)
//
// ```
// $ ./build listing4-4b
// $ ./listing4-4b
// Calling Listing 4-4b:
// Input a string: Hello world
// 0: hex value of char read: 48
// 1: hex value of char read: 65
// 2: hex value of char read: 6c
// 3: hex value of char read: 6c
// 4: hex value of char read: 6f
// 5: hex value of char read: 20
// 6: hex value of char read: 77
// 7: hex value of char read: 6f
// 8: hex value of char read: 72
// 9: hex value of char read: 6c
// 10: hex value of char read: 64
// Listing 4-4b terminated.
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

maxlen = 256

.text
.balign 4

.global _getTitle
.global _asmMain

_getTitle:
	adrl x0, title
	ret

_asmMain:
	// function prologue
	str lr, [sp, #-16]!
	sub sp, sp, #256

	// buf = malloc(maxlen);
	mov  x0, maxlen
	bl   _malloc
	adrl x1, buf
	str  x0, [x1]

	// printf("Input a string: ");
	adrl x0, prompt
	bl   _printf

	// nbytes = readline(buf, maxlen);
	adrl x0, buf
	ldr  x0, [x0]
	mov  x1, maxlen
	bl   _readline

	cmp x0, #-1
	beq done

	adrl x1, nbytes
	str  x0, [x1]

	// initialize loop variables
	// x19: buffer pointer (callee-saved, survives the printf call)
	// x20: buffer index (callee-saved, survives the printf call)
	adrl x19, buf
	ldr  x19, [x19]
	mov  x20, xzr

	// display the data back to the user
loop:
	ldrb w1, [x19, x20]

	adrl x0, fmt
	str  x20, [sp]
	str  x1, [sp, #8]
	bl   _printf

	add x20, x20, #1

	adrl x0, nbytes
	ldr  x0, [x0]
	cmp  x20, x0
	blo  loop

done:
	// free(buf);
	adrl x0, buf
	ldr  x0, [x0]
	bl   _free

	// function epilogue
	add sp, sp, #256
	ldr lr, [sp], #16

	ret

.data

buf:
	.8byte .-.

nbytes:
	.8byte .-.

prompt:
	.asciz "Input a string: "

fmt:
	.asciz "%d: hex value of char read: %x\n"

title:
	.asciz "Listing 4-4b"
