SYS_WRITE equ 1
SYS_EXIT  equ 60
STDOUT    equ 1
MAX_LINE  equ 80

N         equ 42          ; Liczba znaków, która można szyfrować
NN        equ 1764        ; 42^2
NNN       equ 74088       ; 42^3


; Wykonanie programu zaczyna się od etykiety _start.
global _start




section .data


section .rodata
  new_line db `\n`


section .bss
  Lperm   resb N
  Rperm   resb N
  Tperm   resb N
  Linv    resb N
  Rinv    resb N
  Tinv    resb N


section .text
_start:
  lea     rbp, [rsp + 8]  ; adres args[0]
loop:
  mov     rsi, [rbp]      ; adres kolejnego argumentu
  test    rsi, rsi
  jz      exit            ; Napotkano zerowy wskaźnik, nie ma więcej argumentów.
  cld                     ; Zwiększaj indeks przy przeszukiwaniu napisu.
  xor     al, al          ; Szukaj zera.
  mov     ecx, MAX_LINE   ; Ogranicz przeszukiwanie do MAX_LINE znaków.
  mov     rdi, rsi        ; Ustaw adres, od którego rozpocząć szukanie.
  repne \
  scasb                   ; Szukaj bajtu o wartości zero.
  mov     rdx, rdi
  mov     eax, SYS_WRITE
  mov     edi, STDOUT
  sub     rdx, rsi        ; liczba bajtów do wypisania
  syscall
  mov     eax, SYS_WRITE
  mov     edi, STDOUT
  mov     rsi, new_line   ; Wypisz znak nowej linii.
  mov     edx, 1          ; Wypisz jeden bajt.
  syscall
  add     rbp, 8          ; Przejdź do następnego argumentu.
  jmp     loop
  
  
  
exit_err:                   
  mov     eax, SYS_EXIT
  mov     edi, 1          ; kod powrotu 1
  syscall
  ret
exit:                    
  mov     eax, SYS_EXIT
  xor     edi, edi        ; kod powrotu 0
  syscall

  
  
  
  
  
  
  
  
  
  
  
  
