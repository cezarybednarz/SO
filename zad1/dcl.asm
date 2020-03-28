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

read_L:

read_R:

read_T:

_start:
  mov     rax, [rsp]
  cmp     rax, 5          ; sprawdz czy jest 5 argumentów
  jne     exit_err        ; jeśli nie to return 1
  
  
  
  
  
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

  
  
  
  
  
  
  
  
  
  
  
  
