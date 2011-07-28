/* Blink LED example */

#include <msp430f2274.h>

/** Delay function. **/
void delay(unsigned int d) {
  int i;
  for (i = 0; i<d; i++) {
    nop();
  }
}

int main(void) {
  WDTCTL = WDTPW | WDTHOLD;
  P4DIR |= 0x01;
  P4OUT = 0x01;

  for (;;) {
    P4OUT = ~P4OUT;
    delay(0x4fff);
  }
}
