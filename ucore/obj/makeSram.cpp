#include<stdio.h>
int main(){
    FILE* f = fopen("./obj/ucore-kernel-initrd","r");
    fseek(f, 0, SEEK_END);
    int len = ftell(f);
    fseek(f, 0, SEEK_SET);
    char* p = new char[len];
    fread(p, 1, len, f);
    unsigned int* r = new unsigned int[2097152];
    for(int i = 0; i < 2097152; i++){
        r[i] = 0;
    }
    for(int i = 0; i < len; i++){
        *((char*)r + i) = p[i];
    }
    unsigned int* s = new unsigned int[262144];
    for(int i = 0; i < 262144; i++){
        s[i] = 0;
    }
    //printf("%08x\n", r[0]);
    unsigned s1;
    unsigned s2;
    unsigned s3;
    unsigned s4;
    unsigned s5;
    unsigned s6;
    unsigned t0;
    s1 = r[7];
    s2 = r[11] & 0xffff;
    s3 = r[6];
    //printf("%08x\n", s1);
    //printf("%08x\n", s2);
    //printf("%08x\n", s3);
    do{
        s4 = r[(s1 + 8) / 4] & 0x1fffffff;
        s5 = r[(s1 + 16) / 4];
        s6 = r[(s1 + 4) / 4];
        //printf("%08x\n", s4);
        //printf("%08x\n", s5);
        //printf("%08x\n", s6);
        if(s5 > 0){
            do{
                t0 = r[s6 / 4];
                //printf("%08x\n", t0);
                s[s4 / 4] = t0;
                s6 += 4;
                s4 += 4;
                s5 -= 4;
            }while(s5 > 0);
        }
        s1 += 32;
        s2 --;
    }while(s2 > 0);
    FILE* f1 = fopen("./../cpu/cpu/sramdata","w");
    for(int i = 0; i < 262144; i++){
        fprintf(f1, "%08x\n", s[i]);
    }
    return 0;
}