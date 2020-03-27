#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <string.h>

const char CHARS = 42;

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

int main(int argc, char* argv[]) {
    if(argc != 5) {
        return 1;
    }
    char *L = argv[1];
    char *R = argv[2];
    char *T = argv[3];
    char Linv[CHARS], Rinv[CHARS];
    char Lkey = argv[4][0] - '1';
    char Rkey = argv[4][1] - '1';    
    if(sprawdz_i_odwroc(L, Linv) || sprawdz_i_odwroc(R, Rinv)) {
        return 1;
    }
    if(strlen(T) != CHARS) {
        return 1;
    }
    for(int i = 0; i < CHARS; i++) {
        if(T[T[i] - '1'] - '1' != i) {
            return 1;
        }
    }
    for(int i = 0; i < CHARS; i++) {
        L[i] -= '1';
        R[i] -= '1';
        T[i] -= '1';
    }
    char c;
    while(scanf(" %c", &c)) {
        if(c < '1' || c > 'Z') {
            return 1;
        }
        c -= '1';
        Rkey = (Rkey + 1) % CHARS;
        if(Rkey == ('R' - '1') ||
           Rkey == ('L' - '1') ||
           Rkey == ('T' - '1')) {
            Lkey = (Lkey + 1) % CHARS;
        }
        // permutacje
        // Qr-1R-1Qr Ql-1L-1Ql T Ql-1LQl Qr-1RQr
        c = modulo(c, Rkey);
        c = R[c];
        c = modulo(c, CHARS - Rkey);
        
        c = modulo(c, Lkey);
        c = L[c];
        c = modulo(c, CHARS - Lkey);
        
        c = T[c];
        
        c = modulo(c, Lkey);
        c = Linv[c];
        c = modulo(c, CHARS - Lkey);
        
        c = modulo(c, Rkey);
        c = Rinv[c];
        c = modulo(c, CHARS - Rkey);
        
        printf("%c", c + '1');
    }
    return 0;
}
