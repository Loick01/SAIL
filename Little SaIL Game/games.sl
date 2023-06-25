import print_utils
import sailor_sdl2
import sailor_c_utils

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
	
	var ev : sdlevent = createEvent();
	var sdlquit : sdleventcode = getSDLQUIT();	
	var sdlmousebuttondown : sdleventcode = getMOUSEBUTTONDOWN();
	var sdlbuttonleft : sdleventcode = getMOUSEBUTTONLEFTCODE();
	var font : sdlfont = openFont("roboto-bold.ttf", 30);
	var widthText : ptr_int = createIntValue(0);
	var heightText : ptr_int = createIntValue(0);
	var white_color : sdlcolor = createColor(255,255,255,255);
	var mx : ptr_int = createIntValue(0);
	var my : ptr_int = createIntValue(0);
	var point : sdlpoint = createPoint(0,0);
	
	var mut tabButton : array<sdlrect;4>;
	for i in (0,4){ // (4 exclus)
		var rct : sdlrect = createRect(20,20+(i*100),600,80);
		tabButton[i] = rct;
	}
	
	
	
	// On crée les surface à la main vu que pour l'instant on ne peut pas faire de tableau de string
	var button1_name : string  = "Jeu 1";
	var button2_name : string  = "Jeu 2";
	var button3_name : string  = "Fourmi de Langton";
	var button4_name : string  = "Jeu de la vie";
	var button_num : int = 0;
	var mut tabSurfaces : array<sdlsurface;4>;
	var mut tabRectText : array<sdlrect;4>;
	var textRect : sdlrect;
	var surface : sdlsurface;
	
	getSizeText(font,button1_name,widthText,heightText);
	textRect = createRect(30, 20+(button_num*100), getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button1_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button2_name,widthText,heightText);
	textRect = createRect(30, 20+(button_num*100), getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button2_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button3_name,widthText,heightText);
	textRect = createRect(30, 20+(button_num*100), getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button3_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button4_name,widthText,heightText);
	textRect = createRect(30, 20+(button_num*100), getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button4_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	
	
		
	loop{
		setColor(r, 25, 144, 38, 255);
		setBackgroundColor(r);
		
		setColor(r,13, 6, 69,255);
		for h in (0,4){ // (4 exclus)
			drawRect(r,tabButton[h]);			
			var texture : sdltexture = createTextureFromSurface(r,tabSurfaces[h]);
			renderCopy(r, texture, tabRectText[h]);
			destroyTexture(texture);
		}
		
		refresh(r);
		delay(20);
		
		// Vérifier la collision entre le clic de la souris et les bouttons du menu
		
		if (waitEvent(ev) == 1){
			if(getTypeEvent(ev) == sdlquit){
				break;
			}
			if (getTypeEvent(ev) == sdlmousebuttondown){
				if (getMouseButton(ev) == sdlbuttonleft){
					getMousePosition(mx,my);
					setPointValues(point,getIntValue(mx),getIntValue(my));
					for c in (0,4){ // (4 exclus)
						if (pointInRect(point,tabButton[c]) == 1){
							if (c == 0){
								jeu1(r);
							}
							if (c == 1){
								jeu2(r);
							}
							if (c == 2){
								langton(r);
							}		
							if (c == 3){
								jeu_de_la_vie(r);
							}						
						}
					}
				}
			}
		}
	}
	
	for deleteCount in (0,4){ // (4 exclus)
		deleteRect(tabRectText[deleteCount]);
		freeSurface(tabSurfaces[deleteCount]);
	}
	
	print_string("Sortie de la boucle\n");
	
	for k in (0,4){ // (4 exclus)
		deleteRect(tabButton[k]);
	}
	
	closeFont(font);
	deleteIntPtr(mx);
	deleteIntPtr(my);
	deletePoint(point);
	deleteIntPtr(widthText);
	deleteIntPtr(heightText);
	
	deleteEvent(ev);
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	quitTTF();
	quitSDL2();
}
