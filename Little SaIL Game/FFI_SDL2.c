#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>

int initSDL2(){
	return SDL_Init(SDL_INIT_VIDEO);
}

int initTTF(){
	return TTF_Init();
}

int quitTTF(){
	TTF_Quit();
	return 1;
}

int quitSDL2(){
	SDL_Quit();
	return 1;
}

TTF_Font* openFont(const char* file, int size){
	return TTF_OpenFont(file, size); // Vérifier l'extension du fichier
}

int closeFont(TTF_Font* f){
	TTF_CloseFont(f);
	return 1;
}

int getSizeText(TTF_Font* f, const char* text, int* w, int* h){
 	TTF_SizeText(f, text, w, h);
	return 1;
}

SDL_Color createColor(int r, int g, int b, int a){
	SDL_Color c = {r,g,b,a};
	return c;
}

SDL_Surface* renderTextSolid(TTF_Font* f, const char* text, SDL_Color color){
	return TTF_RenderText_Solid(f, text, color); 
}

int freeSurface(SDL_Surface* surface){
	SDL_FreeSurface(surface);
	return 1;
}

SDL_Texture* createTextureFromSurface(SDL_Renderer* r, SDL_Surface* s){
	return SDL_CreateTextureFromSurface(r,s);
}

int destroyTexture(SDL_Texture *t){
	SDL_DestroyTexture(t);
	return 1;
}

int renderCopy(SDL_Renderer* r, SDL_Texture* t, SDL_Rect* rect){
	SDL_RenderCopy(r, t, NULL, rect);
	return 1;
}

SDL_Window* createWindow(const char* name,int width, int height){
	SDL_Window* window = SDL_CreateWindow(name, SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,width, height, SDL_WINDOW_SHOWN);
	return window;
}

int verificationWindow(SDL_Window* w){
	if(w == NULL){
		return 1;
	}
	return 0;
}

SDL_Renderer* createRenderer(SDL_Window* w){
	SDL_Renderer *renderer = SDL_CreateRenderer(w, -1, SDL_RENDERER_ACCELERATED);
	return renderer;
}

int verificationRenderer(SDL_Renderer *r){
	if(r == NULL){
		return 1;
	}
	return 0;
}

int setColor(SDL_Renderer* rend, int r, int g, int b, int a){
	SDL_SetRenderDrawColor(rend, r, g, b, a);
	return 0;
}

SDL_Rect* createRect(int pos_x, int pos_y, int width, int height){
	SDL_Rect* r = malloc(sizeof(SDL_Rect));
	r->x = pos_x;
	r->y = pos_y;
	r->w = width;
	r->h = height;
	return r;
}	

int drawRect(SDL_Renderer* rend, SDL_Rect* r){
	SDL_RenderFillRect(rend, r);
	return 0;
}

int refresh(SDL_Renderer* rend){
	SDL_RenderPresent(rend);
	return 0;
}

int delay(int ms){
	SDL_Delay(ms);
	return 0;
}

int setBackgroundColor(SDL_Renderer* rend){
	SDL_RenderClear(rend);
	return 0;
}

SDL_Event* createEvent(){
	SDL_Event *e = malloc(sizeof(SDL_Event));
	return e;
}

int isEvent(SDL_Event* ev){
	if (SDL_PollEvent(ev)){
		return 1;
	}
	return 0;
}

int getSDLQUIT(){
	return SDL_QUIT;
}	

int getSDLKEYDOWN(){
	return SDL_KEYDOWN;
}

int getScancodeEvent(SDL_Event* ev){
	return (*ev).key.keysym.scancode;
}

int getSPACESCANCODE(){
	return SDL_SCANCODE_SPACE;
}

int getTypeEvent(SDL_Event* ev){
	return (*ev).type;
}

int deleteRect(SDL_Rect* r){
	free(r);
	return 1;
}

int deleteEvent(SDL_Event* ev){
	free(ev);
	return 1;
}

int deleteWindow(SDL_Window* w){
	if (w != NULL){
		SDL_DestroyWindow(w);
	}
	return 1;
}

int deleteRenderer(SDL_Renderer* r){
	if (r != NULL){
		SDL_DestroyRenderer(r);
	}
    return 1;
}


	
	
	
	
	
	
