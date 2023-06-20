type window
type renderer
type sdlrect
type sdlevent
type sdleventcode
type ptr_int
type sdlsurface
type sdltexture
type sdlfont
type sdlcolor

extern "FFI_SDL2.o SDL2 SDL2_ttf" {
	method initSDL2() : int = "initSDL2";
	method quitSDL2() : int = "quitSDL2";
	
	method initTTF() : int = "initTTF";
	method quitTTF() : int = "quitTTF";
	
	method openFont(file : string, size : int) : sdlfont = "openFont";
	method closeFont(f : sdlfont) : int = "closeFont";
	
	method getSizeText(f : sdlfont, text : string, w : ptr_int, h : ptr_int) : int = "getSizeText";
	
	method createColor(r : int, g : int, b : int, a : int) : sdlcolor = "createColor";
	
	method renderTextSolid(f : sdlfont , text : string, color : sdlcolor) : sdlsurface = "renderTextSolid";
	method freeSurface(surface : sdlsurface) : int = "freeSurface";
	
	method createTextureFromSurface(r : renderer, surface : sdlsurface) : sdltexture = "createTextureFromSurface";
	method destroyTexture(texture : sdltexture) : int = "destroyTexture";
	
	method renderCopy(r : renderer, t : sdltexture, rect : sdlrect) : int = "renderCopy";
	
	method setAleatoire() : int = "setAleatoire";
	
	method buildString(score : int , time : int) : string = "buildString"; //  ---------------- Ne pas garder cette fonction, elle est spécialisé pour le jeu 1 ----------------
	
	method createWindow(name : string ,width : int , height : int) : window = "createWindow";
	method vWindow(w : window) : int = "verificationWindow";
	
	method createRenderer(w : window) : renderer = "createRenderer";
	method vRenderer(r : renderer) : int = "verificationRenderer";
	
	method setColor(rend : renderer, r : int , g : int , b : int , a : int) : int = "setColor";
	method createRect(x : int, y : int, width : int, height : int) : sdlrect = "createRect";
	method drawRect(rend : renderer, r : sdlrect) : int = "drawRect";
	method refresh(rend : renderer) : int = "refresh";
	method delay(ms : int) : int = "delay";
	method setBackgroundColor(rend : renderer) : int = "setBackgroundColor";
	
	method createEvent() : sdlevent = "createEvent";
	method isEvent(ev : sdlevent) : int = "isEvent";
	
	method getSDLQUIT() : sdleventcode = "getSDLQUIT";
	method getSDLKEYDOWN() : sdleventcode = "getSDLKEYDOWN";
	method getSPACESCANCODE() : sdleventcode = "getSPACESCANCODE";
	
	method getTypeEvent(ev : sdlevent) : sdleventcode = "getTypeEvent";
	method getScancodeEvent(ev : sdlevent) : sdleventcode = "getScancodeEvent";
	
	method generateRandom(min : int, max : int) : int = "generateRandom";
	method createIntValue(val : int) : ptr_int = "createIntValue";
	method getIntValue(p : ptr_int) : int = "getIntValue";
	method setIntValue(p : ptr_int, val : int) : int = "setIntValue";
	
	method deleteRect(r : sdlrect) : int = "deleteRect";
	method deleteEvent(ev : sdlevent) : int = "deleteEvent";
	method deleteIntPtr(i : ptr_int) : int = "deleteIntPtr";
	method deleteWindow(w : window) : int = "deleteWindow";
	method deleteRenderer(r : renderer) : int = "deleteRenderer"
	
}
