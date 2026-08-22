// listing4-2.S - Demonstrates calls to C stdlib malloc and free functions
//
// ```
// $ ./build listing4-2
// $ ./listing4-2
// Calling Listing 4-2:
// Addresses returned by malloc: 0x10026dad0, 0x10026f0a0
// Listing 4-2 terminated.
// $ uv tool install frida-tools
// $ frida-trace -i malloc -i free -i printf -f $(pwd)/listing4-2
// ...
// Calling Listing 4-2:
// Addresses returned by malloc: 0x104b85ad0, 0x104b870a0
// Listing 4-2 terminated.
// ...
//            /* TID 0x103 */
//     85 ms  printf(format="Calling %s:\n", ...)
//     85 ms     | free(ptr=0x0)
//     85 ms  malloc(size=0x100)
//     85 ms  malloc(size=0x400)
//     85 ms  printf(format="Addresses returned by malloc: %p, %p\n", ...)
//     85 ms     | free(ptr=0x0)
//     85 ms  free(ptr=0x104b85ad0)
//     85 ms  free(ptr=0x104b870a0)
//     85 ms  printf(format="%s terminated.
// ", ...)
//     85 ms     | free(ptr=0x0)
// Process terminated
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

	// ptrVar = malloc(256);
	mov  x0, #256
	bl   _malloc
	adrl x1, ptrVar
	str  x0, [x1]

	// ptrVar2 = malloc(1024);
	mov  x0, #1024
	bl   _malloc
	adrl x1, ptrVar2
	str  x0, [x1]

	// printf("Addresses returned by malloc: %p, %p\n", ptrVar, ptrVar2);
	adrl   x0, fmtStr
	vparm2 ptrVar
	vparm3 ptrVar2
	bl     _printf

	// free(ptrVar);
	adrl x0, ptrVar
	ldr  x0, [x0]
	bl   _free

	// free(ptrVar2);
	adrl x0, ptrVar2
	ldr  x0, [x0]
	bl   _free

	// restore stack pointer
	add sp, sp, #256

	// restore LR
	ldr lr, [sp], #16

	ret

.data

ptrVar:
	.8byte .-.

ptrVar2:
	.8byte .-.

fmtStr:
	.asciz "Addresses returned by malloc: %p, %p\n"

titleStr:
	.asciz "Listing 4-2"
