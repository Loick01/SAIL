type ptr_int

/*
Rappel : Si le nom de la fonction SAIL est identique à celle de la fonction C, alors :
				method nomFonction() : type;
			Sinon
				method nomFonctionSail() : type = "nomFonctionC";
*/

extern "FFI_C_UTILS.o" {
	method setAleatoire() : int = "setAleatoire";
	method generateRandom(min : int, max : int) : int;
	
	method buildString(time : int, score : int) : string ; //  ---------------- Ne pas garder cette fonction, elle est spécialisé pour le jeu 1 ----------------
		
	method createIntValue(val : int) : ptr_int;
	method getIntValue(p : ptr_int) : int ;
	method setIntValue(p : ptr_int, val : int) : int;
	method deleteIntPtr(i : ptr_int) : int;
	method deleteCharPtr(c : string) : int
}
