#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>
#include <string.h>

void* getNULLptr(){
	return NULL;
}

int generateRandom(int min, int max){
	return min + (rand() % (max-min+1));
}

void setAleatoire(){
	srand(time(NULL));
}

int* createIntValue(int val){
	int * i = malloc(sizeof(int));
	*i = val;
	return i;
}

int getIntValue(int* p){
	return *p;
}

void setIntValue(int* p, int val){
	*p = val;
}

char* stringOfInt(int v){
	int nb; // Compte le nombre de chiffre composant le paramètre v
	if (v == 0){
		nb = 1;
	}else{
		int i = abs(v); 
		while (i > 0){
        	i = i / 10;
        	nb++;
		}
	}
	char* c = malloc(sizeof(char*)*nb);
	sprintf(c,"%d",v);
	return c;
}

char* stringConcat(char* s1, char* s2){
	int size_s1 = strlen(s1); // Size without '\0'
	int size_s2 = strlen(s2);
	char* res = malloc(sizeof(char)*(size_s1+size_s2));
	sprintf(res, "%s%s",s1,s2);
	return res;
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


