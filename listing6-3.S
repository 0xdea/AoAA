// listing6-3.S - Demonstrates calling various C stdlib math functions
//
// ```
// $ ./build listing6-3
// $ ./listing6-3
// Calling Listing 6-3:
// sin(pi) = 8.14137986335080e-13
// sin(pi/2) = 1.00000000000000e+00
// sin(pi/4) = 7.07106781594585e-01
// sin(pi/8) = 3.82683432365086e-01
//
// cos(pi) = -1.00000000000000e+00
// cos(pi/2) = -3.49148133884313e-15
// cos(pi/4) = 7.07106780778510e-01
// cos(pi/8) = 9.23879532511288e-01
//
// tan(pi) = -8.14137986335080e-13
// tan(pi/2) = -2.86411383293069e+14
// tan(pi/4) = 1.00000000115410e+00
// tan(pi/8) = 4.14213562373090e-01
//
// Listing 6-3 terminated.
// ```

#include "include.S"

.code

.global _getTitle
.global _asmMain

// trampolines to the C stdlib math functions (necessary because adrl can't take the address
// of a function that could be very far away, as the dynamic libraries probably are)

sin_trampoline:
	b _sin

cos_trampoline:
	b _cos

tan_trampoline:
	b _tan

_getTitle:
	adrl x0, title
	ret

// do_pi(void *func_addr, char *func_name)
//
// Calls the specified function passing pi divided by 1, 2, 4, and 8 as the argument, printing
// the result of each call.
//
// Parameters:
// - func_addr: pointer to the function to call
// - func_name: name of the function to call

func_addr = 0x10
func_name = 0x18

do_pi:
	stp   x19, x20, [sp, #-0x10]!
	enter 0x40

	// preserve both func_addr and func_name arguments on the stack
	stp x0, x1, [fp, #func_addr]

	// save func_addr in non-volatile register x19
	mov x19, x0

	// *func_addr(pi)
	ldr  d0, pi
	blr  x19
	str  d0, [sp, #8]
	ldr  x1, [fp, #func_name]
	str  x1, [sp]
	adrl x0, pi1_fmt
	bl   _printf

	// *func_addr(pi/2)
	ldr  d0, pi2
	blr  x19
	str  d0, [sp, #8]
	ldr  x1, [fp, #func_name]
	str  x1, [sp]
	adrl x0, pi2_fmt
	bl   _printf

	// *func_addr(pi/4)
	ldr  d0, pi4
	blr  x19
	str  d0, [sp, #8]
	ldr  x1, [fp, #func_name]
	str  x1, [sp]
	adrl x0, pi4_fmt
	bl   _printf

	// *func_addr(pi/8)
	ldr  d0, pi8
	blr  x19
	str  d0, [sp, #8]
	ldr  x1, [fp, #func_name]
	str  x1, [sp]
	adrl x0, pi8_fmt
	bl   _printf

	leave
	ldp x19, x20, [sp], #0x10
	ret

// void _asmMain(void);
_asmMain:
	enter 0x40

	// do_pi(&sin_trampoline, "sin")
	adrl x0, sin_trampoline
	adrl x1, sin_str
	bl   do_pi

	// do_pi(&cos_trampoline, "cos")
	adrl x0, cos_trampoline
	adrl x1, cos_str
	bl   do_pi

	// do_pi(&tan_trampoline, "tan")
	adrl x0, tan_trampoline
	adrl x1, tan_str
	bl   do_pi

	leave
	ret

.pool
.balign 8

pi:
	.double 3.141592653588979

pi2:
	.double 1.5707963267949

pi4:
	.double 0.7853981639745

pi8:
	.double 0.39269908169872

pi1_fmt:
	.asciz "%s(pi) = %20.14e\n"

pi2_fmt:
	.asciz "%s(pi/2) = %20.14e\n"

pi4_fmt:
	.asciz "%s(pi/4) = %20.14e\n"

pi8_fmt:
	.asciz "%s(pi/8) = %20.14e\n\n"

sin_str:
	.asciz "sin"

cos_str:
	.asciz "cos"

tan_str:
	.asciz "tan"

title:
	.asciz "Listing 6-3"
