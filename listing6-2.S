// listing6-2.S - Demonstrates comparing two floating-point values for equality
//
// ```
// $ ./build listing6-2
// $ ./listing6-2
// ```

#include "include.S"

// position of the first exponent bit in a double-precision floating-point number
exp_pos = 52

// mask to keep only the exponent bits in a double-precision floating-point number
exp_mask = 0x7FF0000000000000

// number of bits to mask out at the bottom of the mantissa (must be greater than 0)
bits = 4
bit_mask = (1 << bits) - 1

.code

.global _getTitle
.global _asmMain

_getTitle:
	adrl x0, title
	ret

// compute_err
//
// Given a double-precision floating-point value in D0, computes an error range value
// for use in comparisons. If the difference between two values (one of which is in D0)
// is less than this error range, the values can be considered equal.
//
// The result is built directly out of bits rather than computed arithmetically: it is a
// new double whose magnitude equals 2^bits ULPs (units in the last place) of the input
// value, i.e. the weight of the bit `bits` positions above the bottom of the 52-bit
// mantissa. Scaling the tolerance to the input's own exponent (rather than using a fixed
// epsilon) means it stays meaningful across widely different magnitudes.
compute_err:
	// x0/x1 are used as scratch below, so save/restore them around the computation
	stp   x0, x1, [sp, #-0x10]!
	enter 0x40

	// extract the exponent
	fmov x0, d0
	and  x0, x0, #exp_mask
	lsr  x1, x0, #exp_pos  // x1 = biased exponent field (0..2047)

	// if the exponent is too small for (exponent - bits) to stay >= 0, the error value
	// can't be represented as a normalized double, so build a denormalized one instead
	cmp x1, #(exp_pos - bits - 1)
	blo denormal

	// normal case: build a new normalized double with exponent = (exponent - (52 - bits))
	// and a zero mantissa (implicit leading 1.0); its value is 2^(exponent-1023-(52-bits)),
	// i.e. 2^bits times the input's ULP
	sub x1, x1, #(exp_pos - bits)
	lsl x0, x1, #exp_pos
	b   done

denormal:
	// denormal case: the input is too small (or itself denormal) for the normal-case
	// exponent subtraction to stay non-negative, so build the result directly as a
	// denormal by placing the bits-wide mask at bit position x1 (the input's own
	// exponent) of the mantissa field; leaving the exponent field at 0 is how IEEE 754
	// encodes denormals
	mov x0, #bit_mask
	lsl x0, x0, x1

done:
	// reinterpret the constructed bit pattern as a double and return it in D0
	fmov d0, x0

	leave
	ldp x0, x1, [sp], #0x10
	ret

_asmMain:
	enter 0x40

	leave
	ret

.pool
.balign 8

value1:
	.double 1.0e-323 // try also: 1.2345678901234567

value2:
	// When value2 is somewhere between 8e-323 and 9e-323, the comparison becomes not equal
	.double 9e-323 // try also: 1.234567890123456

title:
	.asciz "Listing 6-2"

err_fmt:
	.asciz "Error for (%24.16e) = %e\n"

dif_fmt:
	.asciz "Difference: %e\n"

val_fmt:
	.asciz "Value1=%23.16e, Value2=%23.16e\n"

eq_fmt:
	.asciz "Value1 == Value2\n"

ne_fmt:
	.asciz "Value1 != Value2\n"
