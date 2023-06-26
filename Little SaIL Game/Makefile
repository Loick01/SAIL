run :
	./main

clean :
	rm main *.o *.mir ./bindings/*.o ./bindings/*.mir ./games/*.o ./games/*.mir ./automata/*.o ./automata/*.mir
	
build :
	gcc -c ffi_sdl2.c ffi_c_utils.c
	dune exec sailor -- ./main.sl 

