// listing4-3.S - Demonstrates crash caused by uninitialized pointer dereference
//
// ```
// $ ./build listing4-3
// $ ./listing4-3
// Calling Listing 4-3:
// fish: Job 1, './listing4-3' terminated by signal SIGSEGV (Address boundary error)
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

.text
.balign 4

.global _getTitle
.global _asmMain

_getTitle:
	adrl x0, titleStr
	ret

_asmMain:
	// function prologue
	str lr, [sp, #-0x10]!
	sub sp, sp, #0x100

	// demonstrate crash caused by uninitialized pointer dereference
	adrl x0, ptrVar
	ldr  x1, [x0]
	ldr  x2, [x1]   // pointer dereference (crash!)

	// function epilogue
	add sp, sp, #0x100
	ldr lr, [sp], #0x10

	ret

.data

ptrVar:
	// uninitialized
	.8byte .-.

fmtStr:
	.asciz "Pointer value = %p\n"

titleStr:
	.asciz "Listing 4-3"
