run :
	./main

clean :
	rm main *.o *.mir
	
build :
	gcc -c FFI_SDL2.c FFI_C_UTILS.c
	dune exec sailor -- ./main.sl 

