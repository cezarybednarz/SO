#include <stdlib.h>
#include <stdio.h>

int rr(int a, int b) {
    return rand() % (b - a + 1) + a;
}

int main(int argc, char* argv[]) { 
    if(argc != 2) {
        printf("zle argumenty\n");
    }
    int n = atoi(argv[1]);
    for(int i = 0; i < n; i++) {
        printf("%c", rr((int)'1', (int)'Z'));
    }
}
