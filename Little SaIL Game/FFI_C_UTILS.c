#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

int generateRandom(int min, int max){
	return min + (rand() % (max-min+1));
}

int setAleatoire(){
	srand(time(NULL));
	return 1;
}

int* createIntValue(int val){
	int * i = malloc(sizeof(int));
	*i = val;
	return i;
}

int getIntValue(int* p){
	return *p;
}

int setIntValue(int* p, int val){
	*p = val;
	return 1;
}

int deleteIntPtr(int* i){
	free(i);
	return 1;
}

int deleteCharPtr(char* c){
	free(c);
	return 1;
}

char* buildString(int time, int score){	//  ---------------- Ne pas garder cette fonction, elle est spécialisé pour le jeu 1 ----------------	
	char* c = malloc(sizeof(char)*50);
	sprintf(c, "Temps restant : %d       Score : %d",time/1000,score);
	return c;
}

int square(int v){
	return v*v;
}

int squareroot(int v){
	return (int)sqrt((double)v);
}

int maxInt(int v1, int v2){
	return (v1 >= v2 ? v1 : v2);
}


