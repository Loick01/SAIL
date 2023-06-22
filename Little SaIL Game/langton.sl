import print_utils
import ffi_sdl2
import ffi_c_utils

method drawTab(tab : array<int;4800>,r : renderer,antPos : int){
	var i : int = 0;
	while (i < 4800){ 
		if (i == antPos){
			setColor(r,13, 6, 69,255);
		}else{
			if (tab[i] == 1){
				setColor(r, 255, 255, 255, 255);
			}else{ // tab[i] = -1
				setColor(r, 30, 255, 30, 255);
			}
		}
		
		var rct : sdlrect = createRect((i % 80)*10,(i/80)*10, 9, 9); // 10 est la taille d'un carré
		drawRect(r, rct);
		deleteRect(rct);
		
		i = i + 1;	
	}
}

method step(nb_col : int ,antDir : int ) : int {
	if (antDir == 0){
		return (-1)*nb_col;
	}
	if (antDir == 1){
		return 1;
	}
	if (antDir == 2){
		return nb_col;
	}
	if (antDir == 3){
		return (-1);
	}
	return 0; // Cas impossible normalement
}

method langton(r : renderer){
	var timeRefresh : int = 20; // ms entre 2 refresh
	var ev : sdlevent = createEvent();
	var sdlquit : sdleventcode = getSDLQUIT();
	
	//var square_size : int = 10; // Carrée de taille 10*10
	var nb_line : int = 60; // Intégralité de la fenêtre
	var nb_col : int = 80;
	
	var taille : int = 4800;
	var mut tab : array<int;4800>;
	
	var i : int = 0;
	while (i < nb_line * nb_col){ // Rempli le tableau avec des 1, donc des cases blanches ( -1 pour les cases vertes )
		tab[i] = 1;
		i = i + 1;
		
	}
	
	var antPos : int = (nb_line/2) * nb_col + (nb_col/2); // Position initiale de la fourmi
	var antDir : int = 0; // 0 vers le haut, 1 vers la droite, 2 vers le bas , 3 vers la gauche  (initialement vers le haut)
	loop{ // Idem que while(true)
		if (isEvent(ev) == 1){
			if(getTypeEvent(ev) == sdlquit){
				break;
			}
		}
		setColor(r, 0, 0, 0, 255);
		setBackgroundColor(r);
		drawTab(tab,r,antPos);
		refresh(r);
		delay(timeRefresh);
		
		if (tab[antPos] == 1){                   // Tourne à droite de 90 degrés (4 pour les 4 directions);
			tab[antPos] = tab[antPos] * (-1);
			antDir = (antDir + 1) % 4;
		}else{									 // Tourne à gauche de 90 degrés
			tab[antPos] = tab[antPos] * (-1);
			if (antDir == 0){
				antDir = 3;
			}else{
				antDir = antDir - 1;
			}
		}
		antPos = antPos + step(nb_col,antDir); // On passe en paramètre le nombre de colonne pour savoir de combien avancer pour changer de ligne
		
	}
}
