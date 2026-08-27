// listing4-4c.S - Demonstrates string handling in assembly language
//
// ```
// $ ./build listing4-4c
// $ ./listing4-4c
// Calling Listing 4-4c:
// Input a string: Hello world
// Hex value of char read: 48
// Hex value of char read: 65
// Hex value of char read: 6c
// Hex value of char read: 6c
// Hex value of char read: 6f
// Hex value of char read: 20
// Hex value of char read: 77
// Hex value of char read: 6f
// Hex value of char read: 72
// Hex value of char read: 6c
// Hex value of char read: 64
// Listing 4-4c terminated.
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
str    x2, [sp, #0x08]
.endm

.macro vparm4 mem
adrl   x3, \mem
ldr    x3, [x3]
str    x3, [sp, #0x10]
.endm

.macro vparm5 mem
adrl   x4, \mem
ldr    x4, [x4]
str    x4, [sp, #0x18]
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
	// function prologue (preserve also non-volatile registers x19 and x20)
	str lr, [sp, #-0x10]!
	stp x19, x20, [sp, #-0x10]!
	sub sp, sp, #0x40

	// buf = malloc(maxlen);
	mov  x0, #maxlen
	bl   _malloc
	adrl x1, buf
	str  x0, [x1]

	// printf("Input a string: ");
	adrl x0, prompt
	bl   _printf

	// nbytes = readline(buf, maxlen);
	adrl x0, buf
	ldr  x0, [x0]
	mov  x1, #maxlen
	bl   _readline

	cmp x0, xzr
	blo done

	// display the data back to the user
	adrl x19, buf
	ldr  x19, [x19]

loop:
	// fetch next char and increment buf pointer
	ldrb w20, [x19], #1

	cmp w20, wzr
	beq done

	adrl x0, fmt
	str  x20, [sp]
	bl   _printf

	b loop

done:
	// free(buf);
	adrl x0, buf
	ldr  x0, [x0]
	bl   _free

	// function epilogue
	add sp, sp, #0x40
	ldp x19, x20, [sp], #0x10
	ldr lr, [sp], #0x10

	ret

.data

buf:
	.8byte .-.

prompt:
	.asciz "Input a string: "

fmt:
	.asciz "Hex value of char read: %x\n"

title:
	.asciz "Listing 4-4c"
