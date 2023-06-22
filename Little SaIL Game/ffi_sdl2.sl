import ffi_c_utils

type window
type renderer
type sdlrect
type sdlevent
type sdleventcode
type sdlsurface
type sdltexture
type sdlfont
type sdlcolor


/*
Rappel : Si le nom de la fonction SAIL est identique à celle de la fonction C, alors :
				method nomFonction() : type;
			Sinon
				method nomFonctionSail() : type = "nomFonctionC";
*/

	
extern "FFI_SDL2.o SDL2 SDL2_ttf" {
	method initSDL2() : int;
	method quitSDL2() : int;
	
	method initTTF() : int;
	method quitTTF() : int;
	
	method openFont(file : string, size : int) : sdlfont;
	method closeFont(f : sdlfont) : int;
	
	method getSizeText(f : sdlfont, text : string, w : ptr_int, h : ptr_int) : int;
	
	method createColor(r : int, g : int, b : int, a : int) : sdlcolor;
	
	method renderTextSolid(f : sdlfont , text : string, color : sdlcolor) : sdlsurface;
	method freeSurface(surface : sdlsurface) : int = "freeSurface";
	
	method createTextureFromSurface(r : renderer, surface : sdlsurface) : sdltexture;
	method destroyTexture(texture : sdltexture) : int;
	
	method renderCopy(r : renderer, t : sdltexture, rect : sdlrect) : int;
	
	
	method createWindow(name : string ,width : int , height : int) : window;
	method vWindow(w : window) : int = "verificationWindow";
	
	method createRenderer(w : window) : renderer;
	method vRenderer(r : renderer) : int = "verificationRenderer";
	
	method setColor(rend : renderer, r : int , g : int , b : int , a : int) : int;
	method createRect(x : int, y : int, width : int, height : int) : sdlrect;
	method drawRect(rend : renderer, r : sdlrect) : int;
	method refresh(rend : renderer) : int;
	method delay(ms : int) : int;
	method setBackgroundColor(rend : renderer) : int;
	
	method createEvent() : sdlevent;
	method isEvent(ev : sdlevent) : int;
	
	method getSDLQUIT() : sdleventcode;
	method getSDLKEYDOWN() : sdleventcode;
	method getSPACESCANCODE() : sdleventcode;
	
	method getTypeEvent(ev : sdlevent) : sdleventcode;
	method getScancodeEvent(ev : sdlevent) : sdleventcode;
	
	method getMousePosition(x : ptr_int, y : ptr_int) : int;
	
	method rectIntersection(r1 : sdlrect, r2 : sdlrect) : int;
	
	method deleteRect(r : sdlrect) : int;
	method deleteEvent(ev : sdlevent) : int;
	method deleteWindow(w : window) : int;
	method deleteRenderer(r : renderer) : int
	
}
