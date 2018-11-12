#include<stdio.h>
int main(){
    FILE* f = fopen("./obj/ucore-kernel-initrd","r");
    fseek(f, 0, SEEK_END);
    int len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* p = new char[len];
    fread(p, 1, len, f);
    short* r = new short[4194304];
    for(int i = 0; i < 4194304; i++){
        r[i] = 0;
    }
    for(int i = 0; i < len; i++){
        if(i % 2 == 0){
            r[i / 2] |= (p[i] & 0xff);
        }else{
            r[i / 2] |= (p[i] << 8);
        }
    }
    FILE* f1 = fopen("./../cpu/cpu/kernel","w");
    for(int i = 0; i < 4194304; i++){
        fprintf(f1, "%04hx\n", r[i]);
    }
    return 0;
}