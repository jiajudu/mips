#include<stdio.h>
int main(){
    FILE* f = fopen("./boot/loader.bin","r");
    fseek(f, 0, SEEK_END);
    int len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* p = new char[len];
    fread(p, 1, len, f);
    unsigned* r = new unsigned[128];
    for(int i = 0; i < 128; i++){
        r[i] = 0;
    }
    for(int i = 0; i < len; i++){
        *((char*)r + i) = p[i];
    }
    for(int i = 0; i < 128; i++){
        printf("%08x\n", r[i]);
    }
    return 0;
}