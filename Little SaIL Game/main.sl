import print_utils
import ffi_sdl2
import ffi_c_utils

import jeu1
import jeu2
import langton
import jeu_de_la_vie

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
	var font : sdlfont = openFont("roboto-bold.ttf", 30);
	var widthText : ptr_int = createIntValue(0);
	var heightText : ptr_int = createIntValue(0);
	var mut titles : array<string;4> = ["Jeu 1", "Jeu 2", " Fourmi de Langton", "Jeu de la vie"];
	var white_color : sdlcolor = createColor(255,255,255,255);
	
	var mut tabButton : array<sdlrect;4>;
	for i in (0,4){ // (4 exclus)
		var rct : sdlrect = createRect(20,20+(i*100),600,80);
		tabButton[i] = rct;
	}
			
	loop{
		setColor(r, 25, 144, 38, 255);
		setBackgroundColor(r);
		
		setColor(r,13, 6, 69,255);
		for h in (0,4){ // (4 exclus)
			drawRect(r,tabButton[h]);
			
			getSizeText(font,"Test pour",widthText,heightText);
			var textRect : sdlrect = createRect(20, 20+(h*100), getIntValue(widthText), getIntValue(heightText));
		
			var surface : sdlsurface = renderTextSolid(font, "Test pour", white_color);
			var texture : sdltexture = createTextureFromSurface(r,surface);
			
			renderCopy(r, texture, textRect);
			
			deleteRect(textRect);
			destroyTexture(texture);
			freeSurface(surface);
		}
		
		// Vérifier la collision entre le clic de la souris et les bouttons du menu
		
		refresh(r);
		delay(20);
	}
	
	for k in (0,4){ // (4 exclus)
		deleteRect(tabButton[k]);
	}
	
	closeFont(font);
	deleteIntPtr(widthText);
	deleteIntPtr(heightText);
	*/
	
	//jeu1(r);
	//jeu2(r);
	//langton(r);
	jeu_de_la_vie(r);
	
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	quitTTF();
	quitSDL2();
}
