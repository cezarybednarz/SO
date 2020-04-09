
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

; zadanie jest bezpośrednią implementacją wzoru podanego na stronie:
; https://math.stackexchange.com/questions/880904/how-do-you-use-the-bbp-formula-to-calculate-the-nth-digit-of-%CF%80

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



; Oblicza funkcję 16^n * S_j dla danego n: %rdi (j), %rsi (n)
Sj_for_n:
  mov     r10, rdi             ; j w r10
  mov     r11, rsi             ; n w r11

  xor     r8, r8               ; w r8 trzymam wynik (na poczatku 0)
  
  xor     r9, r9               ; indeks w pętli (k)
; petla po %r9 (k) od 0 do %rsi (n) sluzy do policzenia pierwszej sumy ze wzorku
first_loop:
  mov     rdi, 16              ; podstawa (pierwszy argument funkcji power_modulo)
  
  mov     rsi, r11             ; n
  sub     rsi, r9              ; wykladnik n-k (drugi argument funkcji power_modulo)
  
  mov     rcx, r9              ; k
  shl     rcx, 3               ; 8*k
  add     rcx, r10             ; modulo 8*k+j (trzeci argument funkcji power_modulo)
  
  call    power_modulo         ; odpalam funkcje z trzema wyliczonymi argumentami
  
  mov     rdi, rax             ; w rdi zapisane 16^(n-k) mod 8*k+j
  
  mov     rsi, r9              ; k
  shl     rsi, 3               ; 8*k
  add     rsi, r10             ; 8*k+j (w rdi)
  
  call    div_fraction         ; rdi / rsi  czyli  (16^(n-k) mod 8*k+j) / (8*k+j)

  add     r8, rax              ; sume zwiekszam o wartosc wywolanej funkcji
  
  inc     r9                   ; k++
  cmp     r9, r11              ; k <= n
  jg      first_loop_end       ; wyjdz z petli jesli k > n
  
  jmp first_loop           
first_loop_end:
  
  mov     rax, r8 ; debug
  
  ret
  

; <=======> start funkcji <============>
pix:

  mov     rdi, rdi       
  mov     rsi, rsi
  ;mov     rcx, rdx
  call    Sj_for_n
  
  mov     rax, rax 
  jmp     exit
  
  
  
exit:
  ret

  

