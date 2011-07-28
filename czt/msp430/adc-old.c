/* Blink LED example */

#include <msp430f2274.h>
#include <signal.h>

int main(void) {
  WDTCTL = WDTPW | WDTHOLD;
  WDTCTL = WDTPW + WDTHOLD;                 // Stop watchdog timer
  BCSCTL1 = CALBC1_1MHZ;                    // Set DCO
  DCOCTL = CALDCO_1MHZ;
  P4OUT = (BIT0);                           // P4 setup for LED
  P4DIR |= (BIT0);
  
  // UART Configuration
  UCA0MCTL = UCBRS2 | UCBRS0;               // Modulation UCBRSx = 5
  UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
  IE2 |= UCA0RXIE;                          // Enable USCI0 RX interrupt
  IE2 |= UCA0TXIE;
  UCA0BR0 = 0x08;                           // 1MHz 115200
  UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
  IE2 |= UCA0RXIE;                          // Enable USCI0 RX interrupt
  IE2 |= UCA0TXIE;
  TACCTL0 = CCIE;                           // TACCR0 interrupt enabled

  //  for (;;) {
  //  P4OUT = ~P4OUT;
  //   delay(0x4fff);
  // }
}

//UART Communication
interrupt (USCIAB0RX_VECTOR) USCIA0RX_ISR (void)
{
  if((IFG2 & UCA0RXIFG) == UCA0RXIFG)
    {
      if (UCA0RXBUF == 'p')
	{	
	  P4OUT = ~P4OUT;
	}
    }
}

/*interrupt (USCIAB0TX_VECTOR) USCIA0TX_ISR(void)
{
  if((IFG2 & UCA0TXIFG) == UCA0TXIFG)
    {	
      UCA0TXBUF = (uart_buffer[uart_index++]);
      if (uart_index >= 36)
	{
	  uart_index = 0;
	  IE2 &= ~UCA0TXIE;
	}
    }
}
*/
