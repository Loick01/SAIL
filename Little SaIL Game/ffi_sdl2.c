#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_image.h>

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

SDL_Color createColor(int r, int g, int b, int a){
	SDL_Color c = {r,g,b,a};
	return c;
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

SDL_Rect* createRect(int pos_x, int pos_y, int width, int height){
	SDL_Rect* r = malloc(sizeof(SDL_Rect));
	r->x = pos_x;
	r->y = pos_y;
	r->w = width;
	r->h = height;
	return r;
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

SDL_Event* createEvent(){
	SDL_Event *e = malloc(sizeof(SDL_Event));
	return e;
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

int getMOUSEBUTTONUP(){
	return SDL_MOUSEBUTTONUP;
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

int getMOUSEBUTTONRIGHTCODE(){
	return SDL_BUTTON_RIGHT;
}

SDL_bool getSdlTrue(){
	return SDL_TRUE;
}

SDL_bool getSdlFalse(){
	return SDL_FALSE;
}

int pointInRect(SDL_Point* p, SDL_Rect* r){
	if (SDL_PointInRect(p,r)){
		return 1;
	}
	return 0;
}


	
	
	
	
	
	
