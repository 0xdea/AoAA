// listing7-2.S - Demonstrates indirect jumps via the br instruction to control the flow in a program
//
// ```
// $ ./build listing7-2
// $ ./listing7-2
// Calling Listing 7-2:
// Enter an integer value between 1 and 10 (0 to quit): a123
// The input string is not a proper number
// Enter an integer value between 1 and 10 (0 to quit): 123a
// The input string is not a proper number
// Enter an integer value between 1 and 10 (0 to quit): 9999999999999999999999999999
// The input value is outside the range 1-10
// Enter an integer value between 1 and 10 (0 to quit): -999999999999999999999999999
// The input value is outside the range 1-10
// Enter an integer value between 1 and 10 (0 to quit): -1
// The input value is outside the range 1-10
// Enter an integer value between 1 and 10 (0 to quit): 11
// The input value is outside the range 1-10
// Enter an integer value between 1 and 10 (0 to quit): 5
// The input value is 5
// Enter an integer value between 1 and 10 (0 to quit): 0
// Listing 7-2 terminated.
// ```

#include "include.S"

// maximum length of the input buffer
maxlen = 256

// error code constant
erange = 34

.code

.global _getTitle
.global _asmMain

.pool

title:
	.asciz "Listing 7-2"

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
	.asciz "The input value is %d\n"

debug_fmt:
	.asciz "%016lx\n"

.align 4

_getTitle:
	adrl x0, title
	ret

// int strtoint(char *string);
//
// Converts a string to an integer using strtol(), checking for errors.
//
// Parameters:
// - string: The address of the string to convert.
//
// Returns:
// - X0: The converted integer value.
// - X1: One of the following conversion state values:
//   - 0: Conversion successful.
//   - 1: Conversion failed (illegal characters at the beginning of the string or empty string).
//   - 2: Conversion failed (illegal characters at the end of the string).
//   - 3: Conversion failed (value too large to store in a 32-bit signed integer).

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
	// errno variable is set to ERANGE, there's a range error (overflow or underflow, respectively)
	str x0, [fp, #value]
	get_errno
	mov w2, w0
	ldr x0, [fp, #value]

	// if (errno != ERANGE) return 0;
	mov x1, #0
	cmp w2, #erange
	bne return

	// if (errno == ERANGE) && (ret == LONG_MAX || ret == LONG_MIN) return 3;
	mov x1, #3

	// x2 = LONG_MIN
	movz x2, #0x8000, lsl #48
	cmp  x0, x2
	beq  return

	// x2 = LONG_MAX
	mvn x2, x2
	cmp x0, x2
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

	// if (ret < 0) dispatch to err_readline;
	ands x0, x0, x0
	bmi  dispatch

	// value = strtoint(buffer);
	adrl x0, buffer
	bl   strtoint

	// if (strtoint failed with x1 == 1 or 2) dispatch to err_input
	adrl x19, err_input
	cmp  x1, #1
	beq  dispatch
	cmp  x1, #2
	beq  dispatch

	// if (strtoint failed with x1 == 3) dispatch to err_range
	adrl x19, err_range
	cmp  x1, #3
	beq  dispatch

	// if (strtoint failed with x1 != 0) dispatch to err_unknown
	adrl x19, err_unknown
	cmp  x1, #0
	bne  dispatch

	// at this point, we have a valid value in x0
	// if (value == 0) quit the program
	ands x0, x0, x0
	beq  finish

	// if (value < 1 or value > 10) dispatch to err_range
	adrl x19, err_range
	cmp  x0, #1
	blt  dispatch
	cmp  x0, #10
	bgt  dispatch

	// dispatch to ok
	adrl x19, ok

dispatch:
	br x19

err_readline:
	// printf("There was an error in readline (Ctrl-D pressed?)\n", ret);
	// and quit the program
	adrl x0, err_readline_fmt
	bl   _printf
	b    finish

err_input:
	// printf("The input string is not a proper number\n");
	// and go back to the prompt
	adrl x0, err_input_fmt
	bl   _printf
	b    prompt

err_range:
	// printf("The input value is outside the range 1-10\n");
	// and go back to the prompt
	adrl x0, err_range_fmt
	bl   _printf
	b    prompt

err_unknown:
	// printf("There was a problem with strtoint (unknown error)\n");
	// and go back to the prompt
	adrl x0, err_unknown_fmt
	bl   _printf
	b    prompt

ok:
	// printf("The input value is %d\n", value);
	// and go back to the prompt
	mov  x1, x0
	str  x1, [sp]
	adrl x0, ok_fmt
	bl   _printf
	b    prompt

finish:
	// quit the program
	leave
	ldp x19, x20, [sp], #0x10
	ret

.data
.balign 8

buffer:
	.space maxlen
