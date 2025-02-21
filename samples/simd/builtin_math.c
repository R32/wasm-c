/*
 * Builtin maths, The commented out functions indicates that it does not exist in wasm
 */
#define __builtin_maths
#ifdef __builtin_maths
///! Trigonometric functions
//double __builtin_cos(double);
//double __builtin_sin(double);
//double __builtin_tan(double);
//double __builtin_acos(double);
//double __builtin_asin(double);
//double __builtin_atan(double);
//double __builtin_atan2(double, double);
//float __builtin_cosf(float);
//float __builtin_sinf(float);
//float __builtin_tanf(float);
//float __builtin_acosf(float);
//float __builtin_asinf(float);
//float __builtin_atanf(float);
//float __builtin_atan2f(float, float);

///! Hyperbolic functions
//double __builtin_sinh(double);
//double __builtin_cosh(double);
//double __builtin_tanh(double);
//double __builtin_acosh(double);
//double __builtin_asinh(double);
//double __builtin_atanh(double);
//float __builtin_coshf(float);
//float __builtin_sinhf(float);
//float __builtin_tanhf(float);
//float __builtin_acoshf(float);
//float __builtin_asinhf(float);
//float __builtin_atanhf(float);

///! Exponential and logarithmic functions
//double __builtin_exp(double x);
//double __builtin_frexp(double x, int* i);
//double __builtin_ldexp(double x, int i);
//double __builtin_log(double x);
//double __builtin_log10(double x);
//double __builtin_modf(double x, double y);
//double __builtin_exp2(double x);
//double __builtin_expm1(double x);
//double __builtin_ilogb(double x);
//double __builtin_log1p(double x);
//double __builtin_log2(double x);
//double __builtin_logb(double x);
//double __builtin_scalbn(double x, int i);
//double __builtin_scalbln(double x, int l);
//float __builtin_expf(float x);
//float __builtin_frexpf(float x, int* i);
//float __builtin_ldexpf(float x, int i);
//float __builtin_logf(float x);
//float __builtin_log10f(float x);
//float __builtin_modff(float x, float y); 
//float __builtin_exp2f(float x);
//float __builtin_expm1f(float x);
//float __builtin_ilogbf(float x);
//float __builtin_log1pf(float x);
//float __builtin_log2f(float x);
//float __builtin_logbf(float x);
//float __builtin_scalbnf(float x, int i);
//float __builtin_scalblnf(float x, int l);

///! Power functions
double __builtin_sqrt(double);
//double __builtin_pow(double x, double y);
//double __builtin_cbrt(double x);
//double __builtin_hypot(double x, double y);
float __builtin_sqrtf(float);
//float __builtin_powf(float x, float y);
//float __builtin_cbrtf(float x);
//float __builtin_hypotf(float x, float y);

///! Error and gamma functions
//double __builtin_erf(double x);
//double __builtin_erfc(double x);
//double __builtin_tgamma(double x);
//double __builtin_lgamma(double x);
//float __builtin_erff(float x);
//float __builtin_erfcf(float x);
//float __builtin_tgammaf(float x);
//float __builtin_lgammaf(float x);

///! Rounding and remainder functions
double __builtin_ceil(double);
double __builtin_floor(double);
double __builtin_trunc(double);
double __builtin_rint(double);
double __builtin_nearbyint(double);
//double __builtin_fmod(double x, double y);
//double __builtin_round(double x);
//double __builtin_lround(double x);
//double __builtin_llround(double x);
//double __builtin_lrint(double x);
//double __builtin_llrint(double x);
//double __builtin_remainder(double x, double y);
//double __builtin_remquo(double x, double y, int* quot);
float __builtin_ceilf(float);
float __builtin_floorf(float);
float __builtin_truncf(float);
float __builtin_rintf(float);
float __builtin_nearbyintf(float);
//float __builtin_fmodf(float x, float y);
//float __builtin_roundf(float x);
//float __builtin_lroundf(float x);
//float __builtin_llroundf(float x);
//float __builtin_lrintf(float x);
//float __builtin_llrintf(float x);
//float __builtin_remainderf(float x, float y);
//float __builtin_remquof(float x, float y, int* quot);

///! Floating-point manipulation functions
double __builtin_copysign(double, double);
//double __builtin_nan(const char* tag);
//double __builtin_nextafter(double x, double y);
//double __builtin_nexttoward(double x, long double y);
float __builtin_copysignf(float, float);
//float __builtin_nanf(const char* tag);
//float __builtin_nextafterf(float x, float y);
//float __builtin_nexttowardf(float x, long double y);

///! Others
//double __builtin_fma(double x, double y, double z);
//float __builtin_fmaf(float x, float y, float z);

#endif
#undef __builtin_maths

double __builtin_math(double pi) {
	double d_dummy = 0.5;
	float f_dummy = 0.5f;
	int dummy = 5;
	double result =
	//__builtin_cos(pi) +
	//__builtin_sin(pi) +
	//__builtin_tan(pi) +
	//__builtin_acos(pi) +
	//__builtin_asin(pi) +
	//__builtin_atan(pi) +
	//__builtin_atan2(pi, f_dummy) +
	//__builtin_cosf(pi) +
	//__builtin_sinf(pi) +
	//__builtin_tanf(pi) +
	//__builtin_acosf(pi) +
	//__builtin_asinf(pi) +
	//__builtin_atanf(pi) +
	//__builtin_atan2f(pi, f_dummy) +

	//__builtin_sinh(pi) +
	//__builtin_cosh(pi) +
	//__builtin_tanh(pi) +
	//__builtin_acosh(pi) +
	//__builtin_asinh(pi) +
	//__builtin_atanh(pi) +
	//__builtin_coshf(pi) +
	//__builtin_sinhf(pi) +
	//__builtin_tanhf(pi) +
	//__builtin_acoshf(pi) +
	//__builtin_asinhf(pi) +
	//__builtin_atanhf(pi) +

	//__builtin_exp(pi) +
	//__builtin_frexp(pi, &dummy) +
	//__builtin_ldexp(pi, 2) +
	//__builtin_log(pi) +
	//__builtin_log10(pi) +
	////__builtin_modf(pi, d_dummy) +
	//__builtin_exp2(pi) +
	//__builtin_expm1(pi) +
	//__builtin_ilogb(pi) +
	//__builtin_log1p(pi) +
	//__builtin_log2(pi) +
	//__builtin_logb(pi) +
	//__builtin_scalbn(pi, 2) +
	//__builtin_scalbln(pi, 3) +
	//__builtin_expf(pi) +
	//__builtin_frexpf(pi, &dummy) +
	//__builtin_ldexpf(pi, 2) +
	//__builtin_logf(pi) +
	//__builtin_log10f(pi) +
	////__builtin_modff(pi, f_dummy) +
	//__builtin_exp2f(pi) +
	//__builtin_expm1f(pi) +
	//__builtin_ilogbf(pi) +
	//__builtin_log1pf(pi) +
	//__builtin_log2f(pi) +
	//__builtin_logbf(pi) +
	//__builtin_scalbnf(pi, 2) +
	//__builtin_scalblnf(pi, 3) +

	__builtin_sqrt(pi) +
	//__builtin_pow(pi, pi) +
	//__builtin_cbrt(pi) +
	//__builtin_hypot(pi, f_dummy) +
	__builtin_sqrtf(pi) +
	//__builtin_powf(pi, pi) +
	//__builtin_cbrtf(pi) +
	//__builtin_hypotf(pi, f_dummy) +
	// Error and gamma functions
	//__builtin_erf(pi) +
	//__builtin_erfc(pi) +
	//__builtin_tgamma(pi) +
	//__builtin_lgamma(pi) +
	//__builtin_erff(pi) +
	//__builtin_erfcf(pi) +
	//__builtin_tgammaf(pi) +
	//__builtin_lgammaf(pi) +
	// Rounding and remainder functions
	__builtin_ceil(pi) +
	__builtin_floor(pi) +
	__builtin_trunc(pi) +
	__builtin_rint(pi) +
	__builtin_nearbyint(pi) +
	//__builtin_fmod(pi, f_dummy) +
	//__builtin_round(pi) +
	//__builtin_lround(pi) +
	//__builtin_llround(pi) +
	//__builtin_lrint(pi) +
	//__builtin_llrint(pi) +
	//__builtin_remainder(pi, f_dummy) +
	//__builtin_remquo(pi, f_dummy, &dummy) +
	__builtin_ceilf(pi) +
	__builtin_floorf(pi) +
	__builtin_truncf(pi) +
	__builtin_rintf(pi) +
	__builtin_nearbyintf(pi) +
	//__builtin_fmodf(pi, f_dummy) +
	//__builtin_roundf(pi) +
	//__builtin_lroundf(pi) +
	//__builtin_llroundf(pi) +
	//__builtin_lrintf(pi) +
	//__builtin_llrintf(pi) +
	//__builtin_remainderf(pi, f_dummy) +
	//__builtin_remquof(pi, f_dummy, &dummy) +
	// Floating-point manipulation functions
	__builtin_copysign(pi, d_dummy) +
	(__builtin_nan("") == __builtin_nan("")) +
	//__builtin_nextafter(pi, f_dummy) +
	//__builtin_nexttoward(pi, f_dummy) +
	__builtin_copysignf(pi, f_dummy) +
	(__builtin_nanf("") == __builtin_nanf("")) +
	//__builtin_nextafterf(pi, f_dummy) +
	//__builtin_nexttowardf(pi, f_dummy) +
	// Others
	//__builtin_fma(pi, f_dummy, d_dummy) +
	//__builtin_fmaf(pi, f_dummy, f_dummy) +
	0.;
	return result;
}