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

void quitSDL2(){
	SDL_Quit();
}

void quitTTF(){
	TTF_Quit();
}

TTF_Font* openFont(const char* file, int size){
	return TTF_OpenFont(file, size);
}

void closeFont(TTF_Font* f){
	TTF_CloseFont(f);
}

void getSizeText(TTF_Font* f, const char* text, int* w, int* h){
 	TTF_SizeText(f, text, w, h);
}

SDL_Color createColor(int r, int g, int b, int a){
	SDL_Color c = {r,g,b,a};
	return c;
}

SDL_Surface* renderTextSolid(TTF_Font* f, const char* text, SDL_Color color){
	return TTF_RenderText_Solid(f, text, color); 
}

void freeSurface(SDL_Surface* surface){
	SDL_FreeSurface(surface);
}

SDL_Texture* createTextureFromSurface(SDL_Renderer* r, SDL_Surface* s){
	return SDL_CreateTextureFromSurface(r,s);
}

void destroyTexture(SDL_Texture *t){
	SDL_DestroyTexture(t);
}

void renderCopy(SDL_Renderer* r, SDL_Texture* t, SDL_Rect* rect){
	SDL_RenderCopy(r, t, NULL, rect);
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

void setColor(SDL_Renderer* rend, int r, int g, int b, int a){
	SDL_SetRenderDrawColor(rend, r, g, b, a);
}

void setBackgroundColor(SDL_Renderer* rend){
	SDL_RenderClear(rend);
}

SDL_Rect* createRect(int pos_x, int pos_y, int width, int height){
	SDL_Rect* r = malloc(sizeof(SDL_Rect));
	r->x = pos_x;
	r->y = pos_y;
	r->w = width;
	r->h = height;
	return r;
}	

void drawRect(SDL_Renderer* rend, SDL_Rect* r){
	SDL_RenderFillRect(rend, r);
}

SDL_Point* createPoint(int v1, int v2){
	SDL_Point* p = malloc(sizeof(SDL_Point));
	p->x = v1;
	p->x = v2;
	return p;
}

void setPointValues(SDL_Point* p, int v1, int v2){
	p->x = v1;
	p->y = v2;
}

void refresh(SDL_Renderer* rend){
	SDL_RenderPresent(rend);
}

void delay(int ms){
	SDL_Delay(ms);
}

SDL_Event* createEvent(){
	SDL_Event *e = malloc(sizeof(SDL_Event));
	return e;
}

int pollEvent(SDL_Event* ev){
	return SDL_PollEvent(ev);
}

int waitEvent(SDL_Event* ev){
	return SDL_WaitEvent(ev);
}

int getSDLQUIT(){
	return SDL_QUIT;
}	

int getSDLKEYDOWN(){
	return SDL_KEYDOWN;
}

int getSPACESCANCODE(){
	return SDL_SCANCODE_SPACE;
}

int getMOUSEBUTTONDOWN(){
	return SDL_MOUSEBUTTONDOWN;
}

int getTypeEvent(SDL_Event* ev){
	return (*ev).type;
}

int getScancodeEvent(SDL_Event* ev){
	return (*ev).key.keysym.scancode;
}

int getMouseButton(SDL_Event* ev){
	return (*ev).button.button; 
}

int getMOUSEBUTTONLEFTCODE(){
	return SDL_BUTTON_LEFT;
}

void getMousePosition(int* x, int* y){
	SDL_GetMouseState(x,y);
}

int rectIntersection(SDL_Rect* r1, SDL_Rect* r2){
	if (SDL_HasIntersection(r1,r2)){
		return 1;
	}
	return 0;
}

int pointInRect(SDL_Point* p, SDL_Rect* r){
	if (SDL_PointInRect(p,r)){
		return 1;
	}
	return 0;
}

void deleteRect(SDL_Rect* r){
	free(r);
}

void deletePoint(SDL_Point* p){
	free(p);
}

void deleteEvent(SDL_Event* ev){
	free(ev);
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


	
	
	
	
	
	
