#include <stdio.h>
#include <unistd.h>
#include "get_czt.h"

int main() {
  czt_init();
  put_cztc('A');
  printf("%c (should be 'A')", get_cztc());
  return 0;
}
