import print_utils
import ffi_sdl2
import ffi_c_utils

method printOnScreen(r : renderer, temps : int, score : int) : int{
	var font : sdlfont = openFont("roboto-bold.ttf", 30); // Déplacer toutes ces valeurs (pour ne pas avoir à les créer à chaque frame)
	var color : sdlcolor = createColor(255,255,255,255);
	
	var tempsValue : string = stringOfInt(temps/1000);
	var scoreValue : string = stringOfInt(score);
	
	var stringTemps : string = stringConcat("Temps restant : ",tempsValue); // stringConcat sera à revoir dans la FFI
	var stringScore : string = stringConcat("        Score : ",scoreValue);
	var text : string = stringConcat(stringTemps,stringScore);
	
	var widthText : ptr_int = createIntValue(0); // 0 par défaut, à voir si on crée une autre fonction sans paramètre
	var heightText : ptr_int = createIntValue(0);
	getSizeText(font,text,widthText,heightText);
	var textRect : sdlrect = createRect(20,600 - getIntValue(heightText) - 10, getIntValue(widthText), getIntValue(heightText));
	
	var surface : sdlsurface = renderTextSolid(font, text, color);
	var texture : sdltexture = createTextureFromSurface(r,surface);
	
	renderCopy(r, texture, textRect);
	
	destroyTexture(texture);
	freeSurface(surface);
	closeFont(font);
	
	deleteIntPtr(widthText);
	deleteIntPtr(heightText);
	
	deleteCharPtr(text);
	deleteCharPtr(stringScore);
	deleteCharPtr(stringTemps);
	deleteCharPtr(scoreValue);
	deleteCharPtr(tempsValue);
	
	return 1;
}


method playGame(r : renderer,ev : sdlevent, red_x : int, red_width : int, player_x : ptr_int, direction : ptr_int, sdlquit : sdleventcode ,sdlkeydown : sdleventcode, sdlspace_scancode : sdleventcode, whiteZone : sdlrect, redZone : sdlrect, lengthGame : int, score : ptr_int, missRed : ptr_int) : int { // Problème avec 2ème définition d'un même type à cause des arguments ici
	if (isEvent(ev) == 1){
		if(getTypeEvent(ev) == sdlquit){
			return 0;
		}
		if(getTypeEvent(ev) == sdlkeydown and getIntValue(missRed) == 0){
			if (getScancodeEvent(ev)== sdlspace_scancode){
				if (getIntValue(player_x) >= red_x and red_x + red_width >= getIntValue(player_x)           // Vérification sans la fonction SDL_HasIntersection()
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
	
	printOnScreen(r,lengthGame, getIntValue(score)); // Affiche sur la fenêtre le score et le temps restant
	
	setColor(r,255,255,255,255);
	drawRect(r, whiteZone);
	
	setColor(r,11, 28, 125,255);
	drawRect(r, redZone);
	
	if (getIntValue(missRed) == 0){
		setColor(r,0,0,0,255);
	}else{
		setColor(r,240,20,20,255);
	}
	var player : sdlrect = createRect(getIntValue(player_x),200,20,200); // y = (WINDOW_HEIGHT / 2) - (PLAYER_HEIGHT / 2) 
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

method jeu1(r : renderer){
	var timeRefresh : int = 20; //(ms entre 2 refresh)
	var lengthGame : int = 15000; // (temps d'une partie en ms)
	var ev : sdlevent = createEvent();

	var player_x : ptr_int = createIntValue(50);
	var direction : ptr_int = createIntValue(1);
	var score : ptr_int = createIntValue(0);
	var missRed : ptr_int = createIntValue(0);
	
	var sdlquit : sdleventcode = getSDLQUIT();
	var sdlkeydown : sdleventcode = getSDLKEYDOWN();
	var sdlspace_scancode : sdleventcode = getSPACESCANCODE();
	
	var whiteZone : sdlrect = createRect(50, 280 , 700, 40);
	
	while(lengthGame > 0){
		var play : int = 1;
		var red_width = generateRandom(50,250);
		var red_x  = generateRandom(50,750-red_width);
		var redZone : sdlrect = createRect(red_x,280,red_width,40);
		while (play == 1){
			play = playGame(r,ev,red_x,red_width,player_x,direction,sdlquit,sdlkeydown, sdlspace_scancode,whiteZone, redZone, lengthGame, score, missRed);
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
}


