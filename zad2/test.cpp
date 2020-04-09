#include <iostream>

extern "C"
{
    #include "pix.h"
    void pixtime(uint64_t __attribute__((unused)) t){}
}

int main() {
    
    std::cout << pix(2, 100000, 1000) << "\n";
    
}
