import print_utils
import ffi_sdl2
import ffi_c_utils

import jeu1
import jeu2
import langton

process Main(){
	setAleatoire();
	
	if (initSDL2() != 0){
		print_string("Erreur initialisation SDL2\n");
	}
	var w : window = createWindow("My SaIL window",800,600);
	if (vWindow(w) == 1){
		print_string("Erreur création fenêtre\n");
	}
	
	var r : renderer = createRenderer(w);
	if (vRenderer(r) == 1){
		print_string("Erreur création renderer\n");
	}
	
	initTTF();
	
	/*
	setColor(r, 25, 144, 38, 255);
	setBackgroundColor(r);
	
	setColor(r,13, 6, 69,255);
	var mut tabButton : array<sdlrect;3>; // 3 car 3 jeu
	for i in (0,3){ // i prend 0, 1, et 2 (3 exclus)
		var rct : sdlrect = createRect(20,20+(i*100),600,80);
		drawRect(r, rct);
	}
	refresh(r);
	delay(5000);
	*/
	
	jeu1(r);
	jeu2(r);
	langton(r);
	
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	quitTTF();
	quitSDL2();
}
