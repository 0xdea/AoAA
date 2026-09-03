// listing7-2.S - Demonstrates indirect jumps to control flow in a program
//
// ```
// $ ./build listing7-2
// $ ./listing7-2
// ```

#include "include.S"

// maximum length of the input buffer
maxlen = 256

// error code constants
einval = 22
erange = 34

.code

.global _getTitle
.global _asmMain

.pool

title:
	.asciz "Listing 7-2"

val_fmt:
	.asciz "value=%d, error=%d\n"

prompt_fmt:
	.ascii "Enter an integer value between "
	.asciz "1 and 10 (0 to quit): "

err_readline_fmt:
	.ascii "There was an error in readline "
	.asciz "(Ctrl-D pressed?)\n"

err_input_fmt:
	.asciz "The input string is not a proper number\n"

err_range_fmt:
	.ascii "The input value is outside the "
	.asciz "range 1-10\n"

err_unknown_fmt:
	.ascii "There was a problem with strtoint "
	.asciz "(unknown error)\n"

ok_fmt:
	.ascii "The input value is %d\n"

res_fmt:
	.asciz "result:%d, errno:%d\n"

	.align 4

_getTitle:
	adrl x0, title
	ret

// int strtoint(char *string);
//
// Converts a string to an integer using strtol(), checking for errors.
//
// Parameters:
// - string: The string to convert.
//
// Returns:
// - X0: The converted integer value.
// - X1: One of the following conversion state values:
//   - 0: Conversion successful.
//   - 1: Conversion failed (illegal characters at the beginning of the string or empty string).
//   - 2: Conversion failed (illegal characters at the end of the string).
//   - 3: Conversion failed (value too large to store in a 32-bit signed integer).
//

endptr = 0x10
value  = 0x18

#define string x19

strtoint:
	stp   x19, x20, [sp, #-0x10]!
	enter 0x40

	mov string, x0

	// ret = strtol(str, endptr, 10);
	add x1, fp, #endptr
	mov x2, #10
	bl  _strtol

	// if endptr == string, there were no legal digits at the beginning of the string
	// if (endptr == string) return 1;
	mov x1, #1
	ldr x2, [fp, #endptr]
	cmp string, x2
	beq return

	// if endptr is not pointing at a NUL byte, there were illegal characters at the end of the string
	// if (*endptr != 0) return 2;
	mov  x1, #2
	ldrb w3, [x2]
	cmp  w3, #0
	bne  return

	// if ret is LONG_MAX (0x7fff_ffff_ffff_ffff) or LONG_MIN (0x8000_0000_0000_0000) and the global
	// errno is set to ERANGE, there's a range error (overflow or underflow, respectively)
	str w0, [fp, #value]
	get_errno
	mov x2, x0
	ldr w0, [fp, #value]

	// if (errno != ERANGE) return 0;
	mov x1, #0
	cmp w2, #erange
	bne return

	// if (errno == ERANGE) return 3;
	mov  x1, #3
	mov  x2, 0xffff
	movk x2, #0x7fff, lsl #16

	cmp w0, w2
	beq return

	mvn w2, w2
	cmp w0, w2
	beq return

	// if we get here, the input is a good number
	mov x1, #0

return:
	leave
	ldp x19, x20, [sp], #0x10
	ret

// void _asmMain(void);
//
// Demonstrates how to call strtoint.
_asmMain:
	stp   x19, x20, [sp, #-0x10]!
	enter 0x40

prompt:
	// printf("Enter an integer value between 1 and 10 (0 to quit): ");
	adrl x0, prompt_fmt
	bl   _printf

	// ret = readline(buffer, maxlen);
	adrl x0, buffer
	mov  x1, #maxlen
	bl   _readline

	// initialize state machine
	adrl x19, err_readline

	// if (ret < 0) goto dispatch;
	ands w0, w0, w0
	bmi  dispatch

	// value = strtoint(buffer);
	adrl x0, buffer
	bl   strtoint

	// if (strtoint failed with w1 == 1 or 2) dispatch to err_input
	adrl x19, err_input
	cmp  w1, #1
	beq  dispatch
	cmp  w1, #2
	beq  dispatch

	// if (strtoint failed with w1 == 3) dispatch to err_range
	adrl x19, err_range
	cmp  w1, #3
	beq  dispatch

	// if (strtoint failed with w1 != 0) dispatch to err_unknown
	adrl x19, err_unknown
	cmp  w1, #0
	bne  dispatch

	// at this point, we have valid input in w0
	// if (value == 0) quit the program
	ands w0, w0, w0
	beq  finish

	// verify that the value is in the range 1-10
	adrl x19, err_range
	cmp  w0, #1
	blt  dispatch
	cmp  w0, #10
	bgt  dispatch

	// dispatch to ok
	adrl x19, ok

dispatch:
	br x19

err_readline:
	adrl x0, err_readline_fmt
	bl   _printf
	b    prompt

err_input:
	adrl x0, err_input_fmt
	bl   _printf
	b    prompt

err_range:
	adrl x0, err_range_fmt
	bl   _printf
	b    prompt

err_unknown:
	adrl x0, err_unknown_fmt
	bl   _printf
	b    prompt

ok:

finish:

	leave
	ldp x19, x20, [sp], #0x10
	ret

.data
.balign 8

buffer:
	.space maxlen
