SYS_WRITE equ 1
SYS_EXIT  equ 60
STDOUT    equ 1
MAX_LINE  equ 80
FIRST     equ 49
LAST      equ 90

N         equ 42          ; Liczba znaków, która można szyfrować
NN        equ 1764        ; 42^2
NNN       equ 74088       ; 42^3

; Wykonanie programu zaczyna się od etykiety _start.
global _start




section .data


section .rodata
  new_line db `\n`


section .bss
  Linv    resb N          ; odwrocona permutacja L
  Rinv    resb N          ; odwrocona permutacja R
  Tinv    resb N          ; odwrocona permutacja T
  L       resb 1          ; bebenek L 
  R       resb 1          ; bebenek R

section .text

; sprawdza permutacje z %rdi i odwraca ją w %rsi
inverse: 
  xor     r8, r8          ; r8 to zmienna długości słowa, którą zeruję
loop1:   
  cmp byte[rdi+r8], 0     ; sprawdz czy koniec slowa
  jz      inverse1        ; koniec petli (wyjdz)
  cmp byte[rdi+r8], FIRST ; porównaj z pierwszym znakiem alfabetu ('1')
  jb      exit_err        ; wyjdz jesli zly znak
  cmp byte[rdi+r8], LAST  ; porównaj z ostatnim znakiem alfabetu ('Z')
  jg      exit_err        ; wyjdz jesli zly znak
  sub byte[rdi+r8], FIRST ; przesun kod ascii do zera (żeby '1' mialo kod 0 itd.)
  inc     r8              ; zwieksz licznik liter
  jmp     loop1           ; powrót pętli loop1
inverse1:
  cmp     r8, N           ; sprawdz czy ma 42 litery
  jne     exit_err        ; jesli nie ma, return 1
  
  
  
  
  
  
  ret

; początek programu
_start:
  mov     rax, [rsp]      ; adres argc
  cmp     rax, 5          ; sprawdz czy jest 5 argumentów
  jne     exit_err        ; jeśli nie to return 1
  
  lea     r9,  [rsp + 16] ; adres args[0] w r9
  lea     r10, [rsp + 24] ; adres args[1] w r10
  lea     r11, [rsp + 32] ; adres args[2] w r11
  
; sprawdzanie permutacji L
  mov     rdi, [r9]       ; przekaz 1. argument do funkcji inverse
  mov     rsi, Linv       ; przekaz 2. argument do funkcji inverse
  call    inverse         ; sprawdzenie i odwrócenie permutacji L

;  TODO dwie pozostałe permutacje
  

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

  
  
  
  
  
  
  
  
  
  
  
  
