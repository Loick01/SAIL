import print_utils
import sailor_sdl2
import sailor_c_utils


method printOnScreen(r : renderer, score : int) : int{
	var font : sdlfont = openFont("roboto-bold.ttf", 30); // Déplacer toutes ces valeurs (pour ne pas avoir à les créer à chaque frame)
	var color : sdlcolor = createColor(255,255,255,255);
	
	var scoreValue : string = stringOfInt(score);
	var text : string = stringConcat("Score : ",scoreValue); // stringConcat sera à revoir dans la FFI
	
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
	deleteCharPtr(scoreValue);
	
	return 1;
}

method playGame2(r : renderer, ev : sdlevent, sdlquit : sdleventcode,mouse_x : ptr_int, mouse_y : ptr_int, center_x : int, center_y : int,square_x : ptr_int,square_y : ptr_int,radius : int, sw : int, sh : int,rect_x : ptr_int,rect_y : ptr_int, random : int,score : int) : int{
	if (pollEvent(ev) == 1){
		if(getTypeEvent(ev) == sdlquit){
			return 0;
		}
	}
	
	setColor(r, 25, 144, 38, 255);
	setBackgroundColor(r);
			
	// Calcul de la nouvelle position du joueur en fonction de la position de la souris
	getMousePosition(mouse_x,mouse_y);
	var mx : int = getIntValue(mouse_x);
	var my : int = getIntValue(mouse_y);
			
	var dx : int = mx - center_x;
	var dy : int = my - center_y;
	var distance : int = squareroot(square(dx) + square(dy)); // Peut être mettre en float pour un résultat plus précis
	
	if (distance != 0){ // Ne pas diviser par 0
		var dx_prime : int = (radius*dx)/distance;
		var dy_prime : int = (radius*dy)/distance;
				
		setIntValue(square_x, center_x + dx_prime);
		setIntValue(square_y, center_y + dy_prime);
	}
			
	var player : sdlrect = createRect(getIntValue(square_x) - 25, getIntValue(square_y) - 25, 50, 50); // 50 est la taille du carrée, et 25 pour la moitié du carrée
	setColor(r,255,255,255,255);
	drawRect(r, player);
	
	var mut tabRect : array<sdlrect;3>;
	setColor(r,13, 6, 69,255);
	var n : int = 0;
	var i : int = 0;
	var rx : int = getIntValue(rect_x);
	var ry : int = getIntValue(rect_y);
	while (i<2){
		var rct1 : sdlrect = createRect(rx, ry + i*(sw-sh), sw, sh);
		tabRect[n] = rct1;
		
		if (random == n){
			deleteRect(rct1);
			random = -1; // Pour s'assurer que la condition soit fausse
		}else{
			drawRect(r, rct1);
			n = n + 1;
		}
		
		var rct2 : sdlrect = createRect(rx + i*(sw-sh), ry, sh, sw);
		tabRect[n] = rct2;
		
		if (random == n){
			deleteRect(rct2);
			random = -1;
		}else{
			drawRect(r, rct2);
			n = n + 1;
		}
		
		i = i + 1;
	}
	
	i = 0;
	while (i < 3){
		if (rectIntersection(player,tabRect[i]) == 1){
			return 0;
		}else{
			deleteRect(tabRect[i]);
		}
		i = i + 1;
	}	
	deleteRect(player);
	
	printOnScreen(r, score); // Affiche sur la fenêtre le score et le temps restant
	setIntValue(rect_x,getIntValue(rect_x)+3); // On le bouge de la moitié de ce qu'on le réduit (6/2 = 3)
	setIntValue(rect_y,getIntValue(rect_y)+3);
	return 1;
}				
			
method jeu2(r : renderer){   
	var window_width : int = 800;
	var window_height : int = 600; 
	var timeRefresh : int = 20; //(ms entre 2 refresh)
	var ev : sdlevent = createEvent();
	var sdlquit : sdleventcode = getSDLQUIT();	
	var score : int = 0;

	var mouse_x : ptr_int = createIntValue(0);
	var mouse_y : ptr_int = createIntValue(0);
	
	var square_x : ptr_int = createIntValue(375);
	var square_y : ptr_int = createIntValue(150);
	
	var center_x : int = window_width/2;
	var center_y : int = window_height/2;
	var radius : int = 150;
	
	var initialEpaisseur : int = 50;
	var rect_x : ptr_int = createIntValue(0);
	var rect_y : ptr_int = createIntValue(0);
	var sw: int = window_width; // Taille d'un côté du carré
	var sh : int = initialEpaisseur; // Epaisseur des rect formant le carré
	
	var play : int = 1;
	while(play == 1){
		sw = window_width;
		var random : int = generateRandom(0,3);
		setIntValue(rect_x,0);
		setIntValue(rect_y,(window_width-window_height) / -2); // On suppose que la fenetre est plus longue que haute, donc le carré déborde en haut et en bas au départ
		while(sw > sh){
			play = playGame2(r,ev,sdlquit,mouse_x,mouse_y,center_x, center_y,square_x,square_y,radius,sw, sh,rect_x,rect_y,random,score);
			sw = sw - 6;
			refresh(r);
			delay(timeRefresh);
			if (play == 0){
				score = score - 1;
				break;
			} 
		} 
		score = score + 1;
	}
	
	print_string("Votre score est de : ");
	print_int(score);
	print_newline();
	
	deleteEvent(ev);
	
	deleteIntPtr(mouse_x);
	deleteIntPtr(mouse_y);
	deleteIntPtr(square_x);
	deleteIntPtr(square_y);
	deleteIntPtr(rect_x);
	deleteIntPtr(rect_y);
}
