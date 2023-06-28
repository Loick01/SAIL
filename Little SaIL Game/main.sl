import print_utils
import sailor_sdl2
import sailor_c_utils

import jeu1
import jeu2
import langton
import jeu_de_la_vie
import jeu3

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
	
	var mut tabButton : array<sdlrect;5>;
	for i in (0,5){ // (5 exclus)
		var rct : sdlrect = createRect(20 + (i%2)*350, 20+(i/2)*90,300,70);
		tabButton[i] = rct;
	}
	
	
	var button1_name : string  = "Jeu 1";
	var button2_name : string  = "Jeu 2";
	var button3_name : string  = "Jeu 3";
	var button4_name : string  = "Jeu de la vie";
	var button5_name : string  = "Fourmi de Langton";
	var button_num : int = 0;
	var mut tabSurfaces : array<sdlsurface;5>;
	var mut tabRectText : array<sdlrect;5>;
	var textRect : sdlrect;
	var surface : sdlsurface;
	
	// Impossible de faire une boucle ici. On est obligé de créer les surfaces à la main, vu que pour l'instant on ne peut pas faire de tableau de string (problème pour le texte 
	// sur le bouton). Si on a le temps, essayer de faire mieux
	getSizeText(font,button1_name,widthText,heightText);
	textRect = createRect(30 + (button_num%2)* 350, 30+(button_num/2)*90, getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button1_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button2_name,widthText,heightText);
	textRect = createRect(30 + (button_num%2)* 350, 30+(button_num/2)*90, getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button2_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button3_name,widthText,heightText);
	textRect = createRect(30 + (button_num%2)* 350, 30+(button_num/2)*90, getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button3_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button4_name,widthText,heightText);
	textRect = createRect(30 + (button_num%2)* 350, 30+(button_num/2)*90, getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button4_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	button_num = button_num + 1;
	
	getSizeText(font,button5_name,widthText,heightText);
	textRect = createRect(30 + (button_num%2)* 350, 30+(button_num/2)*90, getIntValue(widthText), getIntValue(heightText));
	surface = renderTextSolid(font, button5_name, white_color);
	tabSurfaces[button_num] = surface;
	tabRectText[button_num] = textRect;
	
	var sdltrue : sdlbool = getSdlTrue();
	var nullPtr : ptr_void = getNULLptr();
	
	var imgSurface : sdlsurface = loadImg("sail.svg"); // La librairie SDL_image permet plusieurs formats, dont svg, png, jpeg.
	var imgTexture : sdltexture = createTextureFromSurface(r,imgSurface);
	var imgWidth : ptr_int = createIntValue(0);
	var imgHeight : ptr_int = createIntValue(0);
	
	getSizeTexture(imgTexture,nullPtr,nullPtr,imgWidth,imgHeight);
	var iW : int = getIntValue(imgWidth) / 2;
	var iH : int = getIntValue(imgHeight) / 2; // L'image est trop grande, donc on réduit le rectangle dans lequel elle s'affiche
	var imgRect : sdlrect = createRect(400 - iW / 2,600 - iH + 20,iW,iH); // x = window width - iW / 2 , y = window height - iH
	
	loop{
		setColor(r, 255, 255, 255, 255);
		setBackgroundColor(r);
		renderCopy(r,imgTexture,nullPtr,imgRect); // Affiche le logo de SaIL
		
		setColor(r,13, 6, 69,255);
		for h in (0,5){ // (5 exclus)
			drawRect(r,tabButton[h]);			
			var texture : sdltexture = createTextureFromSurface(r,tabSurfaces[h]);
			renderCopy(r, texture, nullPtr, tabRectText[h]);
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
					for c in (0,5){ // (5 exclus)
						if (pointInRect(point,tabButton[c]) == 1){
							if (c == 0){
								jeu1(r);
							}
							if (c == 1){
								jeu2(r);
							}
							if (c == 2){
								jeu3(r);
							}		
							if (c == 3){
								jeu_de_la_vie(r);
							}		
							if (c == 4){
								langton(r);
							}						
						}
					}
				}
			}
		}
	}
	
	freeSurface(imgSurface);
	destroyTexture(imgTexture);
	deletePointer(imgWidth);
	deletePointer(imgHeight);
	deletePointer(imgRect);
	
	for deleteCount in (0,5){ // (5 exclus)
		deletePointer(tabRectText[deleteCount]);
		freeSurface(tabSurfaces[deleteCount]);
	}
	
	print_string("Sortie de la boucle\n");
	
	for k in (0,5){ // (5 exclus)
		deletePointer(tabButton[k]);
	}
	
	closeFont(font);
	deletePointer(mx);
	deletePointer(my);
	deletePointer(point);
	deletePointer(widthText);
	deletePointer(heightText);
	
	deletePointer(ev);
	
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	quitTTF();
	quitSDL2();
}
