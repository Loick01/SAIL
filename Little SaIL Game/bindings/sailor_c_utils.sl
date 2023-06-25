type ptr_int
type ptr_void

extern "ffi_c_utils.o m" { // m is for the math library ( -lm option)
	
	method getNULLptr() : ptr_void;
	method generateRandom(min : int, max : int) : int;
	method setAleatoire();
	
	method createIntValue(val : int) : ptr_int;
	method getIntValue(p : ptr_int) : int ;
	method setIntValue(p : ptr_int, val : int);
	
	method stringOfInt(v : int) : string;
	method stringConcat(s1 : string, s2 : string) : string;

	method deletePointer(p : ptr_void) = "free";
	
	method square(v : int) : int;
	method squareroot(v : int) : int;
	method maxInt(v1 : int, v2 : int) : int
}
