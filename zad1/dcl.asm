SYS_WRITE equ 1
SYS_EXIT  equ 60
STDOUT    equ 1
MAX_LINE  equ 80
FIRST     equ 49
LAST      equ 90

N         equ 42          ; Liczba znaków, która można szyfrować
NN        equ 1764        ; 42^2
NNN       equ 74088       ; 42^3

BUFFER    equ 4096        ; dlugosc buforu do wczytywania / wypisywania


global _start             ; Wykonanie programu zaczyna się od etykiety _start.

section .data

section .rodata
  new_line db `\n`

section .bss
  Linv    resb N          ; odwrocona permutacja L
  Rinv    resb N          ; odwrocona permutacja R
  Tinv    resb N          ; odwrocona permutacja T
  
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
  
  mov     cl,[rdi+rax]   ; wartosc permutacji (dokąd wskazuje)
  mov     [rsi+rcx], al  ; stworz permutacje inv dla tego elementu
  
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
  
  
  
; początek programu
_start:
  cmp qword[rsp], 5       ; sprawdz czy jest 5 argumentów
  jne     exit_err        ; jeśli nie to return 1
  
  mov     r9,  [rsp+16]   ; adres args[0] w r9
  mov     r10, [rsp+24]   ; adres args[1] w r10
  mov     r11, [rsp+32]   ; adres args[2] w r11
  mov     r8,  [rsp+40]   ; adres args[3] w r8
  
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

  
  
  
  
  
  
  
  
  
  
  
  
