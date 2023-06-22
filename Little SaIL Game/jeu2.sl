import print_utils
import ffi_sdl2
import ffi_c_utils

method playGame2(r : renderer, ev : sdlevent, sdlquit : sdleventcode,mouse_x : ptr_int, mouse_y : ptr_int, center_x : int, center_y : int,square_x : ptr_int,square_y : ptr_int,radius : int, sw : int, sh : int,rect_x : ptr_int,rect_y : ptr_int, random : int) : int{
	if (isEvent(ev) == 1){
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
			
	var player : sdlrect = createRect(getIntValue(square_x), getIntValue(square_y), 50, 50);
	setColor(r,255,255,255,255);
	drawRect(r, player);
	
	/* Apparemment il y a un problème avec les tableaux dont les éléments sont de types externes
	var mut tabRect : array<sdlrect;3>;
	setColor(r,230,45,69,255);
	var n : int = 0;
	var i : int = 0;
	var rx : int = getIntValue(rect_x);
	var ry : int = getIntValue(rect_y);
	while (i<2){
		var rct1 : sdlrect = createRect(rx, ry + i*(sw-sh), sw, sh);
		drawRect(r, rct1);
		tabRect[n] = rct1;
		n = n + 1;
		
		var rct2 : sdlrect = createRect(rx + i*(sw-sh), ry, sh, sw);
		drawRect(r, rct2);
		tabRect[n] = rct2;
		n = n + 1;
		
		i = i + 1;
	}
	*/
	
	setColor(r,13, 6, 69,255);
	var rx : int = getIntValue(rect_x);
	var ry : int = getIntValue(rect_y);
	
	
	// Pas mal de modification ici à faire si les structs sont disponibles
	
	var rct1 : sdlrect = createRect(rx, ry, sw, sh);              // Plus tard, on en créera que 3 des 4, et on en deleteRect() que 3
	var rct2 : sdlrect = createRect(rx, ry + (sw-sh), sw, sh);
	var rct3 : sdlrect = createRect(rx, ry, sh, sw);
	var rct4 : sdlrect = createRect(rx + (sw-sh), ry, sh, sw);
	
	if (random != 0){
		drawRect(r, rct1);
	}
	if (random != 1){
		drawRect(r, rct2);
	}
	if (random != 2){
		drawRect(r, rct3);
	}
	if (random != 3){
		drawRect(r, rct4);
	}
	
	if (rectIntersection(player,rct1) == 1 and random != 0){
		return 0;
	}
	if (rectIntersection(player,rct2) == 1 and random != 1){
		return 0;
	}
	if (rectIntersection(player,rct3) == 1 and random != 2){
		return 0;
	}
	if (rectIntersection(player,rct4) == 1 and random != 3){
		return 0;
	}
	
	
	deleteRect(rct1);
	deleteRect(rct2);
	deleteRect(rct3);
	deleteRect(rct4);
	
	deleteRect(player);
	
	
	setIntValue(rect_x,getIntValue(rect_x)+3); // On le bouge de la moitié de ce qu'on le réduit (6/2 = 3)
	setIntValue(rect_y,getIntValue(rect_y)+3);
	return 1;
}				
			
method jeu2(){
	setAleatoire();
	
	var window_width : int = 800;
	var window_height : int = 600;
	
	if (initSDL2() != 0){
		print_string("Erreur initialisation SDL2\n");
	}
	var w : window = createWindow("My SaIL window",window_width,window_height);
	if (vWindow(w) == 1){
		print_string("Erreur création fenêtre\n");
	}
	
	initTTF(); // Tester si l'initialisation a réussi (renvoie un int)
	
	var r : renderer = createRenderer(w);
	if (vRenderer(r) == 1){
		print_string("Erreur création renderer\n");
	}
    
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
			play = playGame2(r,ev,sdlquit,mouse_x,mouse_y,center_x, center_y,square_x,square_y,radius,sw, sh,rect_x,rect_y,random);
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
	
	deleteRenderer(r); // Attention : Toujours supprimer le renderer avant la window
	deleteWindow(w);
	
	deleteIntPtr(mouse_x);
	deleteIntPtr(mouse_y);
	deleteIntPtr(square_x);
	deleteIntPtr(square_y);
	deleteIntPtr(rect_x);
	deleteIntPtr(rect_y);
	
	quitTTF();
	quitSDL2();
	
	
}
