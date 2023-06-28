import print_utils
import sailor_sdl2
import sailor_c_utils

method printOnScreen(r : renderer, temps : int, score : int) : int{
	var font : sdlfont = openFont("roboto-bold.ttf", 30); // Déplacer toutes ces valeurs (pour ne pas avoir à les créer à chaque frame)
	var color : sdlcolor = createColor(255,255,255,255);
	
	var tempsValue : string = stringOfInt(temps/1000);
	var scoreValue : string = stringOfInt(score);
	
	var stringTemps : string = stringConcat("Temps restant : ",tempsValue);
	var stringScore : string = stringConcat("        Score : ",scoreValue);
	var text : string = stringConcat(stringTemps,stringScore);
	
	var widthText : ptr_int = createIntValue(0);
	var heightText : ptr_int = createIntValue(0);
	getSizeText(font,text,widthText,heightText);
	var textRect : sdlrect = createRect(20,600 - getIntValue(heightText) - 10, getIntValue(widthText), getIntValue(heightText));
	
	var surface : sdlsurface = renderTextSolid(font, text, color);
	var texture : sdltexture = createTextureFromSurface(r,surface);
	var nullPtr : ptr_void = getNULLptr();
	
	renderCopy(r, texture, nullPtr, textRect);
	
	destroyTexture(texture);
	freeSurface(surface);
	closeFont(font);
	
	deletePointer(widthText);
	deletePointer(heightText);
	
	deletePointer(text);
	deletePointer(stringScore);
	deletePointer(stringTemps);
	deletePointer(scoreValue);
	deletePointer(tempsValue);
	
	return 1;
}

method playGame3(r : renderer, ev : sdlevent, sdlquit : sdleventcode, lengthGame : int, score : ptr_int,following : string, letter : string,letterFont : sdlfont, letterColor : sdlcolor, followColor : sdlcolor, sdlkeydown : sdleventcode) : int{
	if (pollEvent(ev) == 1){
		if(getTypeEvent(ev) == sdlquit){
			return 0;
		}
		if(getTypeEvent(ev) == sdlkeydown){
            var keyName : string = getKeyName(getKeyCode(ev));
            if (stringEqual(keyName,letter) == 0){
            	setIntValue(score,getIntValue(score)+1);
            	return 2;
            }
        }
	}
	
	setColor(r, 25, 144, 38, 255);
	setBackgroundColor(r);
	printOnScreen(r, lengthGame, getIntValue(score)); // Affiche sur la fenêtre le score et le temps restant
		
	var surfaceLetter : sdlsurface = renderTextSolid(letterFont, letter, letterColor);
	var surfaceFollowing : sdlsurface = renderTextSolid(letterFont, following, followColor);
	
	var textureLetter : sdltexture = createTextureFromSurface(r,surfaceLetter);
	var textureFollowing : sdltexture = createTextureFromSurface(r,surfaceFollowing);
	var nullPtr : ptr_void = getNULLptr();
	
	var letterHeight : ptr_int = createIntValue(0);
	var letterWidth : ptr_int = createIntValue(0);
	var followingWidth : ptr_int = createIntValue(0);
	
	getSizeText(letterFont,letter,letterWidth,letterHeight);
	var lW : int = getIntValue(letterWidth);
	var letterRect : sdlrect = createRect(20,300 - (getIntValue(letterHeight)/2), lW, getIntValue(letterHeight));
	
	getSizeText(letterFont,following,letterWidth,letterHeight);
	var followingRect : sdlrect = createRect(20+lW,300 - (getIntValue(letterHeight)/2), getIntValue(letterWidth), getIntValue(letterHeight));
	
	renderCopy(r, textureLetter, nullPtr, letterRect);
	renderCopy(r, textureFollowing, nullPtr, followingRect);
	
	destroyTexture(textureLetter);
	destroyTexture(textureFollowing);
	freeSurface(surfaceLetter);
	freeSurface(surfaceFollowing);
	deletePointer(letterHeight);
	deletePointer(letterWidth);
	
	return 1;
}				

method addLetter(s : string) : string{
	var random : int = generateRandom(65,90);
	s = stringConcat(s,intToString(random));
	return s;
}
		
method jeu3(r : renderer){   
	var window_width : int = 800;
	var window_height : int = 600; 
	var timeRefresh : int = 20; //(ms entre 2 refresh)
	var lengthGame : int = 30000; // (temps d'une partie en ms)
	var ev : sdlevent = createEvent();
	var sdlquit : sdleventcode = getSDLQUIT();	
	var score : ptr_int = createIntValue(0);
	var sdlkeydown : sdleventcode = getSDLKEYDOWN();
	
	var letterFont : sdlfont = openFont("roboto-bold.ttf",256);
	var letterColor : sdlcolor = createColor(255,255,255,255);
	var followColor : sdlcolor = createColor(255,255,255,100);

	var following : string = "";
	var letter : string = "";
	
	var i : int = 0;
	while (i < 5){ // 5 lettres aléatoire pour following
		following = addLetter(following);
		i = i + 1;
	}
	
	while(lengthGame > 0){
		letter = getCharAt(following,0); // Récupère la première lettre
		
		var new_follow : string = "";
		var k : int = 1; // Décale les lettres vers la gauche
		while (k < 5){
			new_follow = stringConcat(new_follow,getCharAt(following,k)); // Utiliser plutôt un substring
			k = k + 1;
		}
		following = new_follow; 
		following = addLetter(following); // Ajoute une nouvelle lettre
		
		var play : int = 1;
		while (play == 1){
			play = playGame3(r,ev,sdlquit,lengthGame,score,following,letter,letterFont,letterColor,followColor,sdlkeydown);
			refresh(r);
			lengthGame = lengthGame - timeRefresh;
		    if (lengthGame < 0){
		    	break;
		    }
		    delay(timeRefresh);
		}
		if (play == 0){
			break;
		} 
		 
	}
	
	print_string("Votre score est de : ");
	print_int(getIntValue(score));
	print_newline();
	
	deletePointer(ev);
}
