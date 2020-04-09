
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
  
  
; %rdi (x) do potęgi %rsi (y) modulo %rcx (m) (iteracyjny algorytm szybkiego potęgowania x^y mod m)
power_modulo:
  mov     rax, 1               ; wynik potegowania (ret) w rax (na początku 1, bo n^0 == 1)
  
loop_power:                   
  cmp     rsi, 0
  je      loop_power_end       ; while(y > 0)
  
  bt      rsi, 0               ; sprawdza najmniejszy bit y (inaczej czy jest parzysta)
  jnc     its_even             ; skacz jak parzysta
  
  mul     rdi                  ; res *= x 
  
  xor     rdx, rdx
  div     rcx                 
  mov     rax, rdx             ; res %= m
  
its_even:
  shr     rsi, 1               ; y >>= 1
  
  mov     r8, rax              ; zapisz rax (res) w r8, bo wykonuję mnożenie
  mov     rax, rdi
  mul     rdi
  mov     rdi, rax             ; x *= x
  mov     rax, r8              ; odzyskaj stare rax (res)

  mov     r8, rax              ; zapisz rax (res) w r8, bo wykonuję modulowanie
  mov     rax, rdi
  xor     rdx, rdx
  div     rcx                 
  mov     rdi, rdx             ; res %= m
  mov     rax, r8              ; odzyskaj stare rax (res)
  
  jmp     loop_power           ; przejdz do kolejnej iteracji petli 

loop_power_end:
  ret                          ; ret jest juz gotowy w rax

  

; <=======> start funkcji <============>
pix:

  mov     rdi, rdi       
  mov     rsi, rsi
  mov     rcx, rdx
  call    power_modulo
  
  mov     rax, rax 
  jmp     exit
  
  
  
exit:
  ret

  

