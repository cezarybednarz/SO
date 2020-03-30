SYS_READ  equ 0
SYS_WRITE equ 1
SYS_EXIT  equ 60
STDOUT    equ 1
STDIN     equ 0
MAX_LINE  equ 80
FIRST     equ 49
LAST      equ 90

LSIGN     equ 27   ; kod ascii L przesunięty do 0 
RSIGN     equ 33   ; kod ascii R przesunięty do 0
TSIGN     equ 35   ; kod ascii T przesunięty do 0

LSIGN_T   equ 1134 ; kod ascii L przesuniety do 0 i pomnozony przez 42
RSIGN_T   equ 1386 ; kod ascii R przesuniety do 0 i pomnozony przez 42
TSIGN_T   equ 1470 ; kod ascii T przesuniety do 0 i pomnozony przez 42

N         equ 42          ; Liczba znaków, która można szyfrować
NN        equ 1764        ; 42^2
NNN       equ 74088       ; 42^3

BUFFER    equ 41        ; dlugosc buforu do wczytywania / wypisywania


global _start             ; Wykonanie programu zaczyna się od etykiety _start.

section .data

section .rodata
  new_line db `\n`

section .bss
  Linv    resb N          ; odwrocona permutacja L
  Rinv    resb N          ; odwrocona permutacja R
  Tinv    resb N          ; odwrocona permutacja T
  Buff    resb BUFFER     ; bufor na wczytywanie wejścia
  
section .text
; sprawdza poprawność permutacji z %rdi i odwraca ją w %rsi
inverse: 
  xor     rax, rax        ; rax to zmienna długości słowa, którą zeruję
loop1:   
  cmp byte[rdi+rax], 0    ; sprawdz czy koniec slowa
  jz      loop1_end       ; koniec petli (wyjdz)
  cmp byte[rdi+rax], FIRST; porównaj z pierwszym znakiem alfabetu ('1')
  jb      exit_err        ; wyjdz jesli zly znak
  cmp byte[rdi+rax], LAST ; porównaj z ostatnim znakiem alfabetu ('Z')
  jg      exit_err        ; wyjdz jesli zly znak
  sub byte[rdi+rax], FIRST; przesun kod ascii do zera (żeby '1' mialo kod 0 itd.)
  
  mov     cl,[rdi+rax]    ; wartosc permutacji (dokąd wskazuje)
  mov     [rsi+rcx], al   ; stworz permutacje inv dla tego elementu
  
  inc     rax             ; zwieksz licznik liter
  jmp     loop1           ; powrót pętli loop1
  
loop1_end:
  cmp     rax, N          ; sprawdz czy ma 42 litery
  jne     exit_err        ; jesli nie ma, return 1
  
  xor     rax, rax        ; indeks w slowie (w petli)
  xor     rcx, rcx        ; ilosc zer w slowie
loop2:   
  cmp     rax, 42         ; sprawdz czy koniec slowa
  je      loop2_end       ; koniec petli (wyjdz)
  cmp byte[rdi+rax], 0    ; jesli zero
  jne     greater         
  inc     rcx             ; zwieksz rcx (licznik zer) jesli znak jest zerem
greater:
  inc     rax             ; zwieksz index
  jmp     loop2           ; powrót pętli loop2
  
loop2_end:
  cmp     rcx, 1          ; jesli jedno zero permutacje da sie obrócić
  jne     exit_err        ; jesli wiecej niz jedno zero, return 1
  ret                     ; wyjscie z funkcji inverse
  
; funkcja modulo rejestru r8, która odejmuje 42 (w pętli) jesli r8 >= 42
modulo:
  cmp     r8, N          
  jb      if_modulo          
  sub     r8, N          
  jmp     modulo
if_modulo:
  ret
  
  
  
; <===> początek programu <===>
_start:
  
  cmp qword[rsp], 5       ; sprawdz czy jest 5 argumentów
  jne     exit_err        ; jeśli nie to return 1
  
  mov     r9,  [rsp+16]   ; adres args[0] w r9  (L)
  mov     r10, [rsp+24]   ; adres args[1] w r10 (R)
  mov     r11, [rsp+32]   ; adres args[2] w r11 (T)
  mov     r8,  [rsp+40]   ; adres args[3] w r8, (LR) [później zostanie nadpisany]
  
  cmp byte[r8+2], 0       ; sprawdz ostatni argument nie jest za dlugi
  jne     exit_err        ; jesli za dlugi to return 1
  
  cmp byte[r8], FIRST
  jb      exit_err        ; jesli klucz mniejszy od '1' return 1
  cmp byte[r8+1], FIRST
  jb      exit_err        ; jesli klucz mniejszy od '1' return 1
  cmp byte[r8], LAST
  jg      exit_err        ; jesli klucz wiekszy od 'Z' return 1
  cmp byte[r8+1], LAST    
  jg      exit_err        ; jesli klucz wiekszy od 'Z' return 1
  
  sub byte[r8], FIRST     ; przesun bebenek L do zera
  sub byte[r8+1], FIRST   ; przesun bebenek R do zera
  
  mov     r12, r8         ; zapisuję znaczki LR w r12
  
  
; sprawdzanie permutacji L
  mov     rdi, r9         ; przekaz 1. argument do funkcji inverse
  mov     rsi, Linv       ; przekaz 2. argument do funkcji inverse
  call    inverse         ; sprawdzenie i odwrócenie permutacji L

; sprawdzanie permutacji R
  mov     rdi, r10        ; przekaż 1. argument do funkcji inverse
  mov     rsi, Rinv       ; przekaz 2. argument do funkcji inverse
  call    inverse         ; sprawdzanie i odwrócenie permutacji R

; sprawdzanie permutacji T
  mov     rdi, r11        ; przekaż 1. argument do funkcji inverse
  mov     rsi, Tinv       ; przekaż 2 argument do funkcji inverse
  call    inverse         ; sprawdzenie i odwrócenie permutacji T (odwrócenie potrzebne do sprawdzenia cykli)

; sprawdzenie czy T jest poprawną permutacją (tylko cykle dlugosci 2)
  xor     rax, rax        ; indeks w slowie (w petli)
loop3:   
  cmp     rax, N          ; sprawdz czy koniec slowa
  je      loop3_end       ; koniec petli (wyjdz)
  
  movzx   edx, byte [Tinv+rax] ; zapisywanie do edx elementu Tinv[i]
  cmp     byte [r11+rax], dl ; sprawdzenie czy T[i] = Tinv[i] (jesli nie, to permutacja T nie ma cykli dl. 2)
  jne     exit_err        ; jeśli nie są równe to return 1
  
  cmp     byte [r11+rax], al ; sprwadzenie czy T[i] != i
  je      exit_err        ; jeśli równe to return 1
  
  inc     rax             ; zwieksz index
  jmp     loop3           ; powrót pętli loop2
loop3_end:
  
; preprocessing polegający na sprawdzeniu wszystkich możliwych ustawien bębenka L, R 
; i dla każdego możliwego znaku (i zapisanie tablicy szyfruj[42][42][42] na stosie 
; poprzez zagnieżdżoną potrójnie pętlę 
; wskaźnik na tablicę umieszczę w rejestrze %rdi

  sub     rsp, NNN        ; przesun stos o 42^3 (miejsce na całą tablice
  sub     rsp, 8          ; align do liczby podzielnej przez 16 (mozna wyrzucic potem)
  xor     rsi, rsi        ; L*42^2 + R*42 + C (wyzeruj)
  
; 3 zagnieżdżone pętle
  xor     rax, rax        ; wyzeruj L
loopL:
  xor     rcx, rcx        ; wyzeruj R
loopR:
  xor     rdx, rdx        ; wyzeruj C
loopC:
; tutaj wnętrze pętli 
  
  mov     r8, rdx         ; nadpisuje poprzednio zajęte r8, żeby wykorzystać je do obliczenia permutacji (potem je odzyskam)

  add     r8, rcx         ; QR[c]
  call    modulo          
  mov     dil, byte [r10+r8]
  movzx   r8, dil         ; R[c]
  add     r8, N          
  sub     r8, rcx         ; Q-1R[c]

  add     r8, rax         ; QL[c]
  call    modulo          
  mov     dil, byte [r9+r8]
  movzx   r8, dil         ; L[c]
  add     r8, N
  sub     r8, rax         ; Q-1L[c]
  
  call    modulo          
  mov     dil, byte [r11+r8]
  movzx   r8, dil         ; T[c]
  
  add     r8, rax         ; QL[c]
  call    modulo          
  mov     dil, byte [Linv+r8]
  movzx   r8, dil         ; Linv[c]
  add     r8, N
  sub     r8, rax         ; Q-1L[c]
  
  add     r8, rcx         ; QR[c]
  call    modulo          
  mov     dil, byte [Rinv+r8]
  movzx   r8, dil         ; Rinv[c]
  add     r8, N          
  sub     r8, rcx         ; Q-1R[c]
  
  call    modulo          ; wyrownanie
  
  mov byte[rsp+rsi], r8b        ; dopisanie do tablicy szyfruj[42][42][42] wyniku (można to napisać lepiej)

  
; koniec wnętrza pętli
  add     rsi, 1          ; dodaj 1 do zsumowanego indeksu
  add     rdx, 1          ; dodaj 1 do C
  cmp     rdx, N          ; sprawdz czy C < 42
  je      loopC_end       ; jesli nie to wyjdz z trzeciej petli
  jmp     loopC           ; kolejny krok pętli po C
loopC_end:
  add     rcx, 1          ; dodaj 1 do R
  cmp     rcx, N          ; sprawdz czy R < 42 
  je      loopR_end       ; jesli nie to wyjdz z drugiej petli
  jmp     loopR           ; kolejny krok pętli po R
loopR_end:
  add     rax, 1          ; dodaj 1 do L
  cmp     rax, N          ; sprwadz czy L < 42
  je      loopL_end       ; jesli nie to wyjdz z pierszej petli
  jmp     loopL           ; kolejny krok pętli po L
loopL_end:

  mov     r10, rsp        ; %r10 to bedzie wskaznik na tablice
  
  movzx   r13, byte[r12]
  add     r12, 1
  movzx   r14, byte[r12]
  
  mov     rax, NN
  mul     r13b
  mov     r9, rax         ; w r9 przechowuję pozycję bebenka L
  
  mov     rax, N
  mul     r14b
  mov     r8, rax         ; w r8 przechowuję pozycje bebenka R
  
; pętla wczytująca znaki blokowo po BUFFER znaków na raz
input_loop:
  mov     rax, SYS_READ   ; syscall read
  mov     rdi, STDIN      ; deskryptor stdin
  mov     rsi, Buff       ; bufor
  mov     rdx, BUFFER     ; dlugosc buforu
  syscall                 ; syscall: wczytaj znaki
  
  mov     r12, rax        ; zapisuje w %r12 dlugosc slowa
  xor     r14, r14        ; %r14 bedzie iterowalo az do dlugosci slowa
  
  cmp     rax, 0          ; czy wczytał zero znaków
  je      exit            ; wtedy wczytaliśmy całe wejście (return 0)

; pętla wczytująca kolejne znaki z bufora (w rax liczba pozostałych znaków)
char_loop:
  cmp byte[rsi+r14], FIRST    ; jesli mniejsze od '1'
  jb      exit_err        ; return 1
  
  cmp byte[rsi+r14], LAST     ; jesli wieksze od 'Z'
  jg      exit_err        ; return 1
  
  sub byte[rsi+r14], FIRST      ; przesuń przetwarzany znak do zera
  
  add     r8, N           ; przesun bebenek R
  cmp     r8, NN          ; sprawdz czy bebenek R jest równy 42
  jne     cond1
  mov     r8, 0           ; wyzeruj jeśli jest
  
  
cond1:
  cmp     r8, LSIGN_T     ; sprawdz czy bebenek R jest rowny L
  jne     c1
  add     r9, NN          ; i przesuń bebenek L
c1:
  cmp     r8, RSIGN_T     ; sprawdz czy bebenek R jest rowny R
  jne     c2         
  add     r9, NN          ; i przesuń bebenek L
c2:
  cmp     r8, TSIGN_T     ; sprawdz czy bebenek R jest rowny T
  jne     cond2
  add     r9, NN          ; i przesuń bebenek L
  
cond2:
  cmp     r9, NNN         ; sprawdz bebenek L jest równy 42^3
  jne     cond3
  mov     r9, 0           ; wyzeruj jeśli jest
  
cond3:

  xor     r15, r15        ; wyzeruj r15
  add     r15, r9         ; dodaj L
  add     r15, r8         ; dodaj R
  movzx   r11, byte[rsi+r14]  ; wez znaczek
  add     r15, r11        ; dodaj C
  add     r15, r10        ; dodaj adres miejsca na stosie
  
  mov     r11, [r15]
  mov     byte[rsi+r14], r11b       ; szyfruj[L][R][C]
  
  add byte[rsi+r14], FIRST      ; przesuń do normalnego znaku
  
  dec     rax             ; zmniejsz liczbe przerobionych znaków
  cmp     rax, 0          ; czy prerobilem wszystkie znaki
  je      char_loop_end   ; jesli tak to wczytaj kolejną porcję
  inc     r14             ; zwieksz iterator dlugosci slowa
  jmp     char_loop       ; przetwórz kolejny znak (przejdz na poczatek petli)
  
char_loop_end:
  mov     rax, SYS_WRITE  ; syscall write
  mov     rdi, STDOUT     ; deskryptor stdout
  mov     rsi, Buff       ; przesuwam do początku buforu
  mov     rdx, r12        ; ilosc bajtow do wypisania
  syscall                 ; syscall: wypisz znaki
  
  jmp     input_loop
  
  
exit:                    
  mov     eax, SYS_EXIT
  xor     edi, edi        ; kod powrotu 0
  syscall
  ret

exit_err:                   
  mov     eax, SYS_EXIT
  mov     edi, 1          ; kod powrotu 1
  syscall
  ret

  
  
  
  
  
  
  
  
  
  
  
  
