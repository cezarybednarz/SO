
SYS_READ  equ 0
SYS_WRITE equ 1
STDIN     equ 0
STDOUT    equ 1
SYS_EXIT  equ 60

extern    pixtime

global pix

section .text

; <==> ABI <==>
; Function calls:     rdi, rsi, rdx, rcx, r8,  r9
; Unstable registers: rax, rcx, rdx, r8,  r9,  r10, r11
; Saved regiters[!]:  rbp, rbx, r12, r13, r14, r15


; mul, div:   RDX:RAX 	r/m64 	RAX 	RDX 	



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
  
  cmp     rcx, 1               ; czy m = 1 (jesli tak, to wynik to zawsze bedzie 0)
  jne     loop_power           ; jesli nie to wykonuj reszte funkcji
  mov     rax, 0               ; jeśli tak to zwróc 0 (wszystko mod 1 daje w wyniku 0)
  ret
  
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
  push    rsi                  ; zapisuję rdi na stosie
  
  mov     r10, rdi             ; j w r10
  mov     r11, rsi             ; n w r11
  
  xor     r12, r12             ; w r12 trzymam wynik (na poczatku 0)
  
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
  
  add     r12, rax             ; sume zwiekszam o wartosc wywolanej funkcji
  
  inc     r9                   ; k++
  cmp     r9, r11              ; k <= n
  jg      first_loop_end       ; wyjdz z petli jesli k > n
  
  jmp     first_loop           
first_loop_end:
  
  
  mov     rdi, 1
  mov     rsi, 16
  call    div_fraction         ; liczę 1/16
  mov     r13, rax             ; w r13 zapisuję 1/16 (potem bede mnozyl)
  
  mov     r9, r11              ; w r11 jest n
  inc     r9                   ; w r9 to n+1, r9 bedzie indeksem k w pętli
second_loop:
  mov     rax, r13             ; 1/16 w r13 (licznik)
  
  mov     r14, r9              
  shl     r14, 3
  add     r14, r10             ; w r14 jest 8*k+j
  
  xor     rdx, rdx             ; wyzeruj wyższe bity przed dzieleniem
  div     r14                  ; (1/16) / (8*k + j), inaczej curPart = numerator / denominator;
  
  cmp     rax, 0               ; if(curPart == 0) break;
  je      second_loop_end      ; jesli jest zero (czyli nic nie zmieni), to wyjdz
  
  add     r12, rax             ; dodaj ulamek do sumy (res += curPart)
  
  mov     rdi, 1
  mov     rsi, 16
  call    div_fraction         ; liczę 1/16
  
  mov     r15, rax             ; mianownik fracMul (getDivFraction(1, 16))
  mov     rax, r13             ; licznik fracMul   (cur16Pow)
  xor     rdx, rdx             ; w rdx bedzie wynik mnozenia (chcemy gorne 64 bity liczby 128 bitowej)
  mul     r15                  ; cur16Pow * getDivFraction(1, 16) 
  
  mov     r13, rdx             ; cur16Pow = fracMul(cur16Pow, getDivFraction(1, 16)); 
  
  inc     r9                   ; k++
  jmp     second_loop          
second_loop_end:
  
  mov     rax, r12
  pop     rsi                  ; odzyskuję rdi ze stosu
  ret     
  
; oblicza {16^n * pi}, jeden argument rsi (n)
pi_for_n:
  push    r8
  push    r9
  push    r10                  
  push    r11                  ; zachowuję indeksy  
  
  xor     rbx, rbx             ; wynik zapisuję w rbx (zeruję)
  
  ; w rsi jest trzymane n, wiec nie musze go podawać do wywołań Sj_for_n
  mov     rdi, 1               ; 1
  call    Sj_for_n             ; S1 = getSjForN(1, N)
  shl     rax, 2               ; 4*S1
  add     rbx, rax             ; ret += 4*S1
  
  mov     rdi, 4               ; 4
  call    Sj_for_n             ; S4 = getSjForN(4, N)
  shl     rax, 1               ; 2*S2
  sub     rbx, rax             ; ret -= 2*S4
  
  mov     rdi, 5               ; 5
  call    Sj_for_n             ; S5 = getSjForN(5, N)
  sub     rbx, rax             ; ret -= S5
  
  mov     rdi, 6               ; 6
  call    Sj_for_n             ; S6 = getSjForN(6, N)
  sub     rbx, rax             ; ret -= S6
  
  
  mov     rax, rbx             ; res jest w rbx      
  
  pop     r11
  pop     r10
  pop     r9
  pop     r8                   ; odzyskuję indeksy
  
  ret                          
  

  
; void pix(uint32_t *ppi, uint64_t *pidx, uint64_t max); // troche pozmienialem
; rdi (*ppi), rsi(*pidx), rdx(max)  
  
; <=======> start funkcji pix <========>
pix:
  
  
  
  
  push    r12
  push    r13
  push    r14
  push    r15                  
  push    rbx                  ; zapisuje stan w tych rejestrach, zeby potem z nich korzystać
    
  mov     r8, rdi              ; r8  = *ppi
  mov     r9, rsi              ; r9  = *pidx
  mov     r10, rdx             ; r10 = max
                               ; r11 = *pidx przed inkrementacją


; ; wywolanie pixtime
;   rdtsc                        ; result stored in edx:eax
;   mov    rdi, rdx                     
;   shl    rax, 32               ; move eax content into high 32 bits of rax
;   shld   rdi, rax, 32          ; rdi = edx:eax
;   call   pixtime



; mov     rsi, 0;debug
; call    pi_for_n ; debug
; jmp     exit  ; debug

; wlasciwa czesc funkcji pix:
main_loop:
  mov     r11, 1
  lock \
  xadd    qword [r9], r11
  cmp     r11, r10
  jae     main_loop_end
  
  ;shl     r11, 2
  mov     rsi, r11
  shl     rsi, 3
  call    pi_for_n
  shr     rax, 32
  mov     dword [r8 + 4*r11], eax
  
  jmp     main_loop
main_loop_end:
  
  
  
  
  
  
  jmp     exit  
  
exit:
  pop     rbx           
  pop     r15
  pop     r14
  pop     r13
  pop     r12                  ; odzyskuję wartości w rejestrach i wyrównuję stos (ABI)
  
; ; wywolanie pixtime
;   rdtsc                        ; result stored in edx:eax
;   mov    rdi, rdx                     
;   shl    rax, 32               ; move eax content into high 32 bits of rax
;   shld   rdi, rax, 32          ; rdi = edx:eax
;   call   pixtime
  
  ret

