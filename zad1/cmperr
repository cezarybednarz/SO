chmod u+x cmp.sh;
nasm -f elf64 -g -F dwarf -o ./dcl.o ./dcl.asm
ld -o ./dcl ./dcl.o
echo "skompilowano z debugiem!"
gdb --args dcl $(cat przyklady/t1.key)
set disassembly-flavor intel



