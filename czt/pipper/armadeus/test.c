#include <stdio.h>
#include <unistd.h>
#include "get_pip.h"

int main() {
  struct pipper pip;
  pipper_init();
  while (1) {
	usleep(50000);
	pip = get_pipper();
	printf("%g\t%g\t%g\t%g\t%g\t%g\t%g\t%g\n",
               pip.t0, pip.t1, pip.t2, pip.t3, pip.t4, pip.t5, pip.t6, pip.t7);
  }
  return 0;
}
