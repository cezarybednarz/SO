#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>
#include <unistd.h>

#define CHARS 42

bool sprawdz_i_odwroc(char* perm, char* inv) {
    if(strlen(perm) != CHARS) {
        return 1;
    }
    for(int i = 0; i < CHARS; i++) {
        if(perm[i] < '1' || perm[i] > 'Z') {
            return 1;
        }
    }
    memset(inv, CHARS, CHARS); // (wskaznik, czym, ile)
    for(int i = 0; i < CHARS; i++) {
        perm[i] -= '1';
    }
    for(int i = 0; i < CHARS; i++) {
        if(inv[perm[i]] != CHARS) {
            return 1;
        }
        inv[perm[i]] = i;
    }
    return 0;
}

char modulo(char n, char diff) {
    return (n + diff + 42) % 42;
}

char perm[CHARS][CHARS][CHARS];

int main(int argc, char* argv[]) {
    if(argc != 5) {
        return 1;
    }
    if(argv[4][2]) {
        return 1;
    }
    char *L = argv[1];
    char *R = argv[2];
    char *T = argv[3];
    char Linv[CHARS], Rinv[CHARS];
    char Lkey = argv[4][0];
    char Rkey = argv[4][1];    
    if(Lkey < '1' || Lkey > 'Z' || Rkey < '1' || Rkey > 'Z') {
        return 1;
    }
    Rkey -= '1';
    Lkey -= '1';
    if(sprawdz_i_odwroc(L, Linv) || sprawdz_i_odwroc(R, Rinv)) {
        return 1;
    }
    if(strlen(T) != CHARS) {
        return 1;
    }
    for(int i = 0; i < CHARS; i++) {
        if(T[T[i] - '1'] - '1' != i || T[i] - '1' == i) {
            return 1;
        }
    }
    for(int i = 0; i < CHARS; i++) {
        T[i] -= '1';
    }
    char c;
    for(char LL = 0; LL < CHARS; LL++) {
        for(char RR = 0; RR < CHARS; RR++) {
            for(char CC = 0; CC < CHARS; CC++) {
                c = CC;
                    
                c = modulo(c, RR);
                c = R[c];
                c = modulo(c, CHARS - RR);

                c = modulo(c, LL);
                c = L[c];
                c = modulo(c, CHARS - LL);

                c = T[c];

                c = modulo(c, LL);
                c = Linv[c];
                c = modulo(c, CHARS - LL);

                c = modulo(c, RR);
                c = Rinv[c];
                c = modulo(c, CHARS - RR);

                perm[LL][RR][CC] = c + '1';
            }
        }
    }
    
    const int len = 4096;
    char buff[len + 10];
    int curr = 0;
    
    while(true) {
        curr = read(0, buff, len);
        if(!curr) {
            break;
        }
        for(int i = 0; i < curr; i++) {
            c = buff[i];
            c -= '1';
            Rkey = (Rkey + 1) % CHARS;
            if(Rkey == ('R' - '1') ||
                Rkey == ('L' - '1') ||
                Rkey == ('T' - '1')) {
                Lkey = (Lkey + 1) % CHARS;
            }
            printf("%c", perm[Lkey][Rkey][c]);
        }
    }
    return 0;
}
