run :
	./games

clean :
	rm games *.o *.mir ./bindings/*.o ./bindings/*.mir
	
build :
	gcc -c ffi_sdl2.c ffi_c_utils.c
	dune exec sailor -- ./games.sl 

