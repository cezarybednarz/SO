#include <stdint.h>
#include <stdio.h>
#include <inttypes.h>
#include "pix.h"

#define max 1000

void pixtime(__attribute__((unused)) uint64_t clock_tick) {
  fprintf(stderr, "%016lX\n", clock_tick);
}

int main(void) {
  uint32_t arr[max] = {0};
  uint64_t ind = 0;
    
  printf("%" PRIu64 "\n", pix(arr, &ind, max));
  
  
  for (int i = 0; i < (int)max; i++) {
    printf("%08X\n", arr[i]);
  }
  
  return 0;
}
