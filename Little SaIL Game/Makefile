run :
	./games

clean :
	rm main *.o *.mir
	
build :
	gcc -c ffi_sdl2.c ffi_c_utils.c
	dune exec sailor -- ./games.sl 

