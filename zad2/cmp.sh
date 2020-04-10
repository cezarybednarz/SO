nasm -f elf64 -w+all -w+error -o pix.o pix.asm
gcc -std=c11 -Wall -Wextra -O2 -o pix *.c pix.o
