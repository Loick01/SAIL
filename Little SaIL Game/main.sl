import print_utils
import ffi_sdl2

method printOnScreen(r : renderer, score : ffi_sdl2::ptr_int , temps : int) : int{
	var font : sdlfont = openFont("roboto-bold.ttf", 30); // Déplacer toutes ces valeurs (pour ne pas avoir à les créer à chaque frame)
	var color : sdlcolor = createColor(255,255,255,255);
	var text : string = "Chaine a construire !"; // buildString(getIntValue(score),temps); //  Dans la ffi, cette fonction est sépcialisée pour le jeu 1, donc ne pas la garder
	
	var widthText : ffi_sdl2::ptr_int = createIntValue(0); // 0 par défaut, à voir si on crée une autre fonction sans paramètre
	var heightText : ffi_sdl2::ptr_int = createIntValue(0);
	getSizeText(font,text,widthText,heightText);
	var textRect : ffi_sdl2::sdlrect = createRect(20,600 - getIntValue(heightText) - 10, getIntValue(widthText), getIntValue(heightText));
	
	var surface : sdlsurface = renderTextSolid(font, text, color);
	var texture : sdltexture = createTextureFromSurface(r,surface);
	
	renderCopy(r, texture, textRect);
	
	destroyTexture(texture);
	freeSurface(surface);
	closeFont(font);
	
	deleteIntPtr(widthText);
	deleteIntPtr(heightText);
	
	return 1;
}


method playGame(r : ffi_sdl2::renderer,ev : sdlevent, red_x : int, red_width : int, player_x : ffi_sdl2::ptr_int, direction : ffi_sdl2::ptr_int, sdlquit : ffi_sdl2::sdleventcode ,sdlkeydown : ffi_sdl2::sdleventcode, sdlspace_scancode : ffi_sdl2::sdleventcode, whiteZone : ffi_sdl2::sdlrect, redZone : ffi_sdl2::sdlrect, score : ffi_sdl2::ptr_int, lengthGame : int, missRed : ffi_sdl2::ptr_int) : int { // Problème avec 2ème définition d'un même type à cause des arguments ici
	if (isEvent(ev) == 1){
		if(getTypeEvent(ev) == sdlquit){
			return 0;
		}
		if(getTypeEvent(ev) == sdlkeydown and getIntValue(missRed) == 0){
			if (getScancodeEvent(ev)== sdlspace_scancode){
				if (getIntValue(player_x) >= red_x and red_x + red_width >= getIntValue(player_x) 
            		or
            	(getIntValue(player_x) + 20 >= red_x and red_x + red_width >= getIntValue(player_x) + 20)){
            		setIntValue(score,getIntValue(score)+1);
            		return 2;
            	}else{
            		setIntValue(missRed,50);
            	}
			}
		}
	}
	
	if (getIntValue(missRed) > 0){
		setIntValue(missRed, getIntValue(missRed) - 1);
	}
	
	setColor(r, 25, 144, 38, 255);
	setBackgroundColor(r);
	
	printOnScreen(r,score,lengthGame); // Affiche sur la fenêtre le score et le temps restant
	
	setColor(r,255,255,255,255);
	drawRect(r, whiteZone);
	
	setColor(r,11, 28, 125,255);
	drawRect(r, redZone);
	
	if (getIntValue(missRed) == 0){
		setColor(r,0,0,0,255);
	}else{
		setColor(r,240,20,20,255);
	}
	var player : ffi_sdl2::sdlrect = createRect(getIntValue(player_x),200,20,200); // y = (WINDOW_HEIGHT / 2) - (PLAYER_HEIGHT / 2) 
	drawRect(r, player);
	
	setIntValue(player_x,getIntValue(player_x)+(20 * getIntValue(direction)));
	
	
	if (getIntValue(player_x) <= 50){
    	setIntValue(direction,1);
    }else{
    	if (getIntValue(player_x) + 20 >= 750){
    		setIntValue(direction,-1);
    	}
    }
    
    deleteRect(player);
    
	return 1;
}

process Main(){
	setAleatoire();
	
	if (initSDL2() != 0){
		print_string("Erreur initialisation SDL2\n");
	}
	var w : window = createWindow("My SaIL window",800,600);
	if (vWindow(w) == 1){
		print_string("Erreur création fenêtre\n");
	}
	
	initTTF(); // Tester si l'initialisation a réussi (renvoie un int)
	
	var r : ffi_sdl2::renderer = createRenderer(w);
	if (vRenderer(r) == 1){
		print_string("Erreur création renderer\n");
	}
    
	var timeRefresh : int = 20; //(ms entre 2 refresh)
	var lengthGame : int = 15000; // (temps d'une partie en ms)
	var ev : ffi_sdl2::sdlevent = createEvent();

	var player_x : ffi_sdl2::ptr_int = createIntValue(50);
	var direction : ffi_sdl2::ptr_int = createIntValue(1);
	var score : ffi_sdl2::ptr_int = createIntValue(0);
	var missRed : ffi_sdl2::ptr_int = createIntValue(0);
	
	var sdlquit : ffi_sdl2::sdleventcode = getSDLQUIT();
	var sdlkeydown : ffi_sdl2::sdleventcode = getSDLKEYDOWN();
	var sdlspace_scancode : ffi_sdl2::sdleventcode = getSPACESCANCODE();
	
	var whiteZone : ffi_sdl2::sdlrect = createRect(50, 280 , 700, 40);
	
	while(lengthGame > 0){
		var play : int = 1;
		var red_width = generateRandom(50,250);
		var red_x  = generateRandom(50,750-red_width);
		var redZone : ffi_sdl2::sdlrect = createRect(red_x,280,red_width,40);
		while (play == 1){
			play = playGame(r,ev,red_x,red_width,player_x,direction,sdlquit,sdlkeydown, sdlspace_scancode,whiteZone, redZone, score, lengthGame, missRed);
			refresh(r);
			lengthGame = lengthGame - timeRefresh;
		    if (lengthGame < 0){
		    	break;
		    }
		    delay(timeRefresh);
		}
		deleteRect(redZone);
		if (play == 0){
			break;
		}  
	}
	
	print_string("Votre score est de : ");
	print_int(getIntValue(score));
	print_newline();
	
	deleteRect(whiteZone);
	deleteEvent(ev);
	deleteIntPtr(player_x);
	deleteIntPtr(direction);
	deleteIntPtr(score);
	deleteIntPtr(missRed);
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	quitTTF();
	quitSDL2();
	
	
}


