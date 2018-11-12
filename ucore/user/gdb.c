#include <ulib.h>
#include <stdio.h>
#include <string.h>
#include <dir.h>
#include <file.h>
#include <error.h>
#include <unistd.h>
int conv(char c){
    if(c > 47 && c < 58){
        return c - 48;
    }
    return c - 87;
}
int main(int argc, char** argv){
    if(argc < 2){
        cprintf("gdb need at least 1 argument");
        sys_exit(1);
    }
    char addr[8];
    int valid = 1;
    int i = 0;
    do{
        cprintf("\nPlease input the breakpoint(hex): ");
        valid = 1;
        for(i = 0; i < 8; i++){
            read(0, addr + i, sizeof(char));
            sys_putc(addr[i]);
            if((addr[i] < 48 || addr[i] > 57)&&(addr[i] < 97 || addr[i] > 102)){
                valid = 0;
            }
        }
    }while(valid == 0);
    unsigned int ad = 0;
    for(i = 0; i < 8; i++){
        ad = ad * 16 + conv(addr[i]);
    }
    sys_break(ad);
    cprintf("\n");
    sys_exec(argv[1], argc - 1, argv + 1);
    sys_exit(0);
}