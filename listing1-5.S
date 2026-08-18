// listing1-5.S - The venerable "Hello, world!" program
//
// ```
// $ ./build listing1-5
// $ ./listing1-5
// Calling Listing 1-5:
// Hello, world!
// Listing 1-5 terminated.
// ```

.macro adrl reg, mem
adrp   \reg, \mem@PAGE          // \reg = page address of \mem
add    \reg, \reg, \mem@PAGEOFF // \reg += offset within page
.endm

.text
.balign 4

.global _asmMain
.global _getTitle

_getTitle:
	adrl x0, title
	ret

_asmMain:
	// save LR
	adrl x0, saveLR
	str  lr, [x0]

	// print "Hello, world!"
	adrl x0, hwStr
	bl   _printf

	// restore LR
	adrl x0, saveLR
	ldr  lr, [x0]

	ret

.data

title:
	.asciz "Listing 1-5"

hwStr:
	.asciz "Hello, world!\n"

saveLR:
	.8byte 0
