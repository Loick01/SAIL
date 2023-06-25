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
type sdlbool
	
extern "ffi_sdl2.o SDL2 SDL2_ttf" {
	method initSDL2() : int;
	method quitSDL2();
	
	method initTTF() : int;
	method quitTTF();
	
	method getSdlTrue() : sdlbool;
	method getSdlFalse() : sdlbool;
	
	method openFont(file : string, size : int) : sdlfont = "TTF_OpenFont";
	method closeFont(f : sdlfont) : int  = "TTF_CloseFont";
	
	method getSizeText(f : sdlfont, text : string, w : ptr_int, h : ptr_int)  = "TTF_SizeText";
	
	method createColor(r : int, g : int, b : int, a : int) : sdlcolor;
	
	method renderTextSolid(f : sdlfont , text : string, color : sdlcolor) : sdlsurface = "TTF_RenderText_Solid";
	method freeSurface(surface : sdlsurface) = "SDL_FreeSurface";
	
	method createTextureFromSurface(r : renderer, surface : sdlsurface) : sdltexture = "SDL_CreateTextureFromSurface";
	method destroyTexture(texture : sdltexture) = "SDL_DestroyTexture";
	
	method renderCopy(r : renderer, t : sdltexture, opt : ptr_void, rect : sdlrect) = "SDL_RenderCopy";
	
	method createWindow(name : string ,width : int , height : int) : window;
	method vWindow(w : window) : int = "verificationWindow";
	
	method createRenderer(w : window) : renderer;
	method vRenderer(r : renderer) : int = "verificationRenderer";
	
	method setColor(rend : renderer, r : int , g : int , b : int , a : int) = "SDL_SetRenderDrawColor";
	method setBackgroundColor(rend : renderer) = "SDL_RenderClear";
	
	method createRect(x : int, y : int, width : int, height : int) : sdlrect;
	method drawRect(rend : renderer, r : sdlrect) = "SDL_RenderFillRect";
	
	method createPoint(x : int, y : int) : sdlpoint;
	method setPointValues(p : sdlpoint, x : int, y : int);
	
	method refresh(rend : renderer) = "SDL_RenderPresent";
	method delay(ms : int) = "SDL_Delay";
	
	method createEvent() : sdlevent;
	method pollEvent(ev : sdlevent) : int = "SDL_PollEvent";
	method waitEvent(ev : sdlevent) : int = "SDL_WaitEvent";
	
	method getSDLQUIT() : sdleventcode;
	method getSDLKEYDOWN() : sdleventcode;
	method getSPACESCANCODE() : sdleventcode;
	method getMOUSEBUTTONDOWN() : sdleventcode;
	method getMouseButton(ev : sdlevent) : sdleventcode;
	method getMOUSEBUTTONLEFTCODE() : sdleventcode;
	
	method getTypeEvent(ev : sdlevent) : sdleventcode;
	method getScancodeEvent(ev : sdlevent) : sdleventcode;
	
	method getMousePosition(x : ptr_int, y : ptr_int) = "SDL_GetMouseState";
	
	method rectIntersection(r1 : sdlrect, r2 : sdlrect) : sdlbool = "SDL_HasIntersection";
	method pointInRect(p : sdlpoint, r : sdlrect) : int;// = "SDL_PointInRect";
	
	method deleteWindow(w : window) : int = "SDL_DestroyWindow";
	method deleteRenderer(r : renderer) : int = "SDL_DestroyRenderer"
	
}
