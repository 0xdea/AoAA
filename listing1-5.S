// listing1-5.S - The venerable "Hello, world!" program
//
// ```
// $ build listing1-5
// ```

.macro lea reg, mem
adrp   \reg, \mem@PAGE
add    \reg, \reg, \mem@PAGEOFF
.endm

.text
.balign 4

.global _asmMain
.global _getTitle

_getTitle:
	lea x0, title
	ret

_asmMain:
	lea x0, saveLR
	str lr, [x0]
	lea x0, hwStr
	bl  _printf
	lea x0, saveLR
	ldr lr, [x0]
	ret

.data

title:
	.asciz "Listing 1-5"

hwStr:
	.asciz "Hello, world!\n"

saveLR:
	.8byte 0
