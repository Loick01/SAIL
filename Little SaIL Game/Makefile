run1 :
	./main

run2 :
	./main2
	
clean :
	rm main main2 *.o *.mir
	
build1 :
	gcc -c FFI_SDL2.c FFI_C_UTILS.c
	dune exec sailor -- ./main.sl 
	
build2 :
	gcc -c FFI_SDL2.c FFI_C_UTILS.c
	dune exec sailor -- ./main2.sl 

