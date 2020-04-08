
SYS_READ  equ 0
SYS_WRITE equ 1
STDIN     equ 0
STDOUT    equ 1
SYS_EXIT  equ 60

global pix

section .text

; <==> ABI <==>
; Function calls:     rdi, rsi, rdx, rcx, r8,  r9
; Unstable registers: rax, rcx, rdx, r8,  r9,  r10, r11
; Saved regiters[!]:  rbp, rbx, r12, r13, r14, r15


; mul, div:   RDX:RAX 	r/m64 	RAX 	RDX 	


; void pix(uint32_t *ppi, uint64_t *pidx, uint64_t max); // troche pozmienialem

; <=======> funkcje pomocnicze <=======>

; 64 bity po przecinku ilorazu %rdi / %rsi (2^64 * %rdi / %rsi, biorę czesc calkowitą)
div_fraction:
  mov     rdx, rdi             ; przenieś do licznika %rdi
  xor     rax, rax             ; wyzeruj rax, zeby umiescic tam wynik
  div     rsi                  ; %rdi / %rsi
  ret
  
; %rdi do potęgi %rsi modulo %rdx (iteracyjny algorytm szybkiego potęgowania)
power_modulo:
  
  

; <=======> start funkcji <============>
pix:

  mov     rdi, rdi       
  mov     rsi, rsi
  call    div_fraction
  
  mov     rax, rax 
  jmp     exit
  
  
  
exit:
  ret

  

