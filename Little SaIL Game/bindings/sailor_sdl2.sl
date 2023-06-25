import sailor_c_utils

type window
type renderer
type sdlrect
type sdlpoint
type sdlevent
type sdleventcode
type sdlsurface
type sdltexture
type sdlfont
type sdlcolor
	
extern "ffi_sdl2.o SDL2 SDL2_ttf" {
	method initSDL2() : int;
	method quitSDL2();
	
	method initTTF() : int;
	method quitTTF();
	
	method openFont(file : string, size : int) : sdlfont;
	method closeFont(f : sdlfont) : int;
	
	method getSizeText(f : sdlfont, text : string, w : ptr_int, h : ptr_int);
	
	method createColor(r : int, g : int, b : int, a : int) : sdlcolor;
	
	method renderTextSolid(f : sdlfont , text : string, color : sdlcolor) : sdlsurface;
	method freeSurface(surface : sdlsurface);
	
	method createTextureFromSurface(r : renderer, surface : sdlsurface) : sdltexture;
	method destroyTexture(texture : sdltexture);
	
	method renderCopy(r : renderer, t : sdltexture, rect : sdlrect);
	
	method createWindow(name : string ,width : int , height : int) : window;
	method vWindow(w : window) : int = "verificationWindow";
	
	method createRenderer(w : window) : renderer;
	method vRenderer(r : renderer) : int = "verificationRenderer";
	
	method setColor(rend : renderer, r : int , g : int , b : int , a : int);
	method setBackgroundColor(rend : renderer);
	
	method createRect(x : int, y : int, width : int, height : int) : sdlrect;
	method drawRect(rend : renderer, r : sdlrect);
	
	method createPoint(x : int, y : int) : sdlpoint;
	method setPointValues(p : sdlpoint, x : int, y : int);
	method deletePoint(p : sdlpoint);
	
	method refresh(rend : renderer);
	method delay(ms : int);
	
	method createEvent() : sdlevent;
	method pollEvent(ev : sdlevent) : int;
	method waitEvent(ev : sdlevent) : int;
	
	method getSDLQUIT() : sdleventcode;
	method getSDLKEYDOWN() : sdleventcode;
	method getSPACESCANCODE() : sdleventcode;
	method getMOUSEBUTTONDOWN() : sdleventcode;
	method getMouseButton(ev : sdlevent) : sdleventcode;
	method getMOUSEBUTTONLEFTCODE() : sdleventcode;
	
	method getTypeEvent(ev : sdlevent) : sdleventcode;
	method getScancodeEvent(ev : sdlevent) : sdleventcode;
	
	method getMousePosition(x : ptr_int, y : ptr_int);
	
	method rectIntersection(r1 : sdlrect, r2 : sdlrect) : int;
	method pointInRect(p : sdlpoint, r : sdlrect) : int;
	
	method deleteRect(r : sdlrect);
	method deleteEvent(ev : sdlevent);
	method deleteWindow(w : window) : int;
	method deleteRenderer(r : renderer) : int
	
}
