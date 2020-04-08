#include <iostream>

extern "C"
{
    #include "pix.h"
    void pixtime(uint64_t __attribute__((unused)) t){}
}

int main() {
    
    std::cout << pix(3, 5, 0) << "\n";
    
}
