import print_utils
import sailor_sdl2
import sailor_c_utils

method drawTab(tab : array<int;1200>,r : renderer){
	var i : int = 0;
	while (i < 1200){ 
		if (tab[i] == 1){ // Cellule vivante de couleur verte
			setColor(r, 30, 255, 30, 255);
		}else{ // Cellule morte (-1) de couleur blanche
			setColor(r, 255, 255, 255, 255);
		}
		
		var rct : sdlrect = createRect((i % 40)*20,(i/40)*20, 18, 18); // 20 est la taille d'un carré, 40 est le nombre de colonne
		drawRect(r, rct);
		deleteRect(rct);
		
		i = i + 1;	
	}
}

method step(tab  : array<int;1200>, nb_line : int, nb_col : int) : array<int;1200>{
	var mut res : array<int;1200>;
	var i : int = 0;
	while (i < 1200){ 
		var compteur : int = 0;
		
		var i_line : int = i / nb_col;
		var i_col : int = i % nb_col;
		
		// Trouver une meilleur manière que tous ces tests
		if (i_col != nb_col - 1){ // A droite
			if (tab[i+1] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_col != 0){ // A gauche
			if (tab[i - 1] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != nb_line - 1){ // En bas
			if (tab[i+nb_col] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != 0){ // En haut
			if (tab[i - nb_col] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != 0 and i_col != 0){ // Haut à gauche
			if (tab[i - nb_col - 1] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != 0 and i_col != nb_col - 1){ // Haut à droite
			if (tab[i - nb_col + 1] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != nb_line - 1 and i_col != 0){ // Bas à gauche
			if (tab[i + nb_col - 1] == 1){
				compteur = compteur + 1;
			}
		}
		if (i_line != nb_line - 1 and i_col != nb_col - 1){ // Bas à droite
			if (tab[i + nb_col + 1] == 1){
				compteur = compteur + 1;
			}
		}
		
		
		if (tab[i] == -1){
			if(compteur == 3){ // Cellule morte devient vivante si 3 cellules voisines vivantes
				res[i] = 1; // La cellule naît
			}else{
				res[i] = -1
			}
		}else{ // Cellule vivante
			if (compteur < 2 or compteur > 3){ // Cellule vivante a moins de 2 ou plus de 3 cellules voisines vivantes
				res[i] = -1; // La cellule meurt
			}else{
				res[i] = 1;
			}
		}
		i = i + 1;	
	}
	return res;
}


method jeu_de_la_vie(r : renderer){
	var timeRefresh : int = 100; // ms entre 2 refresh
	
	//var square_size : int = 20; // Carrée de taille 10*10
	var nb_line : int = 30;
	var nb_col : int = 40;
	
	var taille : int = 1200;
	var mut tab : array<int;1200>;
	
	var i : int = 0;
	while (i < nb_line * nb_col){ // Rempli le tableau avec des -1, donc des cellules mortes (1 pour cellules vivantes)
		tab[i] = -1;
		i = i + 1;
		
	}
	
	var ev : sdlevent = createEvent();
	var spacePressed : bool = false;
	var sdlkeydown : sdleventcode = getSDLKEYDOWN();
	var sdlspace_scancode : sdleventcode = getSPACESCANCODE();
	var sdlmousebuttondown : sdleventcode = getMOUSEBUTTONDOWN();
	var sdlbuttonleft : sdleventcode = getMOUSEBUTTONLEFTCODE();
	var sdlquit : sdleventcode = getSDLQUIT();
	var mx : ptr_int = createIntValue(0);
	var my : ptr_int = createIntValue(0);
	
	loop{ // Idem que while(true)
		while (pollEvent(ev) == 1){
			if (getTypeEvent(ev) == sdlquit){
				break;
			}
			if (getTypeEvent(ev) == sdlkeydown){
				if (getScancodeEvent(ev)== sdlspace_scancode){
					spacePressed = !spacePressed; // Inverse 
				}
			}
			if (getTypeEvent(ev) == sdlmousebuttondown and spacePressed){
				if (getMouseButton(ev) == sdlbuttonleft){
					getMousePosition(mx,my);
					var pos : int = (getIntValue(my) / 20) * nb_col + (getIntValue(mx) / 20);
					tab[pos] = tab[pos] * -1;	
				}
			}
		}
		
		setColor(r, 0, 0, 0, 255);
		setBackgroundColor(r);
		drawTab(tab,r);
		refresh(r);
		delay(timeRefresh);
		if (!spacePressed){
			tab = step(tab,nb_line,nb_col);
		}
		
	}
	deleteEvent(ev);
	deleteIntPtr(mx);
	deleteIntPtr(my);
}
