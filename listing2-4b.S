// listing2-4b.S - Demonstrates packed data types (optimized)
//
// ```
// $ ./build listing2-4b
// $ ./listing2-4b
// Calling Listing 2-4b:
// Enter current day (1-31): 17
// Enter current month: (1-12): 3
// Enter current year (0-65535): 1978
// Packed date is 07ba0311 = 17/03/1978
// The date is 17/03/1978
// Listing 2-4b terminated.
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

.equ maxLen, 256

.text
.balign 4

.global _getTitle

_getTitle:
	adrl x0, titleStr
	ret

// int readNum(char *prompt)
//
// prints the prompt, reads an input string from the user, then
// converts it to an integer and returns the integer value in X0
readNum:
	sub  sp, sp, #64       // not really needed here
	adrl x1, saveLRreadNum
	str  lr, [x1]

	// print the prompt (passed in X0)
	bl _printf

	// read the input string from the user
	adrl x0, input
	mov  x1, #maxLen
	bl   _readline

	// test for a bad input string
	cmp x0, xzr
	beq badInput

	// convert the input string to an integer
	adrl x0, input
	mov  x1, xzr
	mov  x2, #10
	bl   _strtol

badInput:
	adrl x1, saveLRreadNum
	ldr  lr, [x1]
	add  sp, sp, #64       // not really needed here

	ret

.global _asmMain

_asmMain:
	// make room on the stack
	sub sp, sp, #64

	// save LR
	adrl x0, saveLRasmMain
	str  lr, [x0]

	// read the day from the user
	adrl x0, dayPrompt
	bl   readNum

	// check the day value
	cmp x0, #1
	blo badDay
	cmp x0, #31
	bhi badDay

	// save the day value
	adrl x1, day
	strb w0, [x1]

	// read the month from the user
	adrl x0, moPrompt
	bl   readNum

	// check the month value
	cmp x0, #1
	blo badMonth
	cmp x0, #12
	bhi badMonth

	// save the month value
	adrl x1, month
	strb w0, [x1]

	// read the year from the user
	adrl x0, yearPrompt
	bl   readNum

	// check the year value
	cmp x0, #0
	blo badYear
	mov x1, #65535
	cmp x0, x1
	bhi badYear

	// save the year value
	adrl x1, year
	strh w0, [x1]

	// pack the date in 4 bytes as follows:
	// 31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
	//  y  y  y  y  y  y  y  y  y  y  y  y  y  y  y  y  m  m  m  m  m  m  m  m  d  d  d  d  d  d  d  d
	adrl x0, year
	ldrh w1, [x0]
	lsl  w1, w1, #8

	adrl x0, month
	ldrb w2, [x0]
	orr  w1, w1, w2
	lsl  w1, w1, #8

	adrl x0, day
	ldrb w2, [x0]
	orr  w1, w1, w2

	adrl x0, date
	str  w1, [x0]

	// print the packed date
	adrl   x0, packedFmt
	vparm2 date
	vparm3 day
	vparm4 month
	vparm5 year
	bl     _printf

	// unpack the date and print it
	adrl x0, date
	ldr  w1, [x0]

	lsr  w2, w1, #16
	adrl x0, y
	strh w2, [x0]

	lsr  w2, w1, #8
	and  w2, w2, #0xff
	adrl x0, m
	strb w2, [x0]

	and  w1, w1, #0xff
	adrl x0, d
	strb w1, [x0]

	adrl   x0, theDateFmt
	vparm2 d
	vparm3 m
	vparm4 y
	bl     _printf

	b allDone

badMonth:
	adrl x0, badMonthStr
	bl   _printf
	b    allDone

badDay:
	adrl x0, badDayStr
	bl   _printf
	b    allDone

badYear:
	adrl x0, badYearStr
	bl   _printf
	b    allDone

allDone:

	// restore LR
	adrl x0, saveLRasmMain
	ldr  lr, [x0]

	// restore stack pointer
	add sp, sp, #64

	ret

.data
.balign 4

titleStr:
	.asciz "Listing 2-4b"

dayPrompt:
	.ascii "Enter current day "
	.asciz "(1-31): "

moPrompt:
	.ascii "Enter current month: "
	.asciz "(1-12): "

yearPrompt:
	.ascii "Enter current year "
	.asciz "(0-65535): "

packedFmt:
	.ascii "Packed date is %08x = "
	.asciz "%02d/%02d/%02d\n"

theDateFmt:
	.asciz "The date is %02d/%02d/%04d\n"

badDayStr:
	.ascii "Bad day value was entered "
	.asciz "(expected 1-31)\n"

badMonthStr:
	.ascii "Bad month value was entered "
	.asciz "(expected 1-12)\n"

badYearStr:
	.ascii "Bad year value was entered "
	.asciz "(expected 0-65535)\n"

month:
	.8byte 0

day:
	.8byte 0

year:
	.8byte 0

date:
	.8byte 0

m:
	.8byte 0

d:
	.8byte 0

y:
	.8byte 0

saveLRasmMain:
	.8byte 0

saveLRreadNum:
	.8byte 0

input:
	.fill maxLen
