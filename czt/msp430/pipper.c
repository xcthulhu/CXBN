#include "msp430x22x4.h"
#include <signal.h>
#include <string.h>
#include "../pipper_common.h"

// WARNING: Do not multiply include in one compiled object
#include "../../checksum_ref.c"

unsigned char received;
unsigned char uart_buffer[36];
unsigned int data1, data2;
unsigned short adc;
unsigned char MST_Data[8];
float conv_adc;
static unsigned char uart_index;
float value[8];

void main(void)
{
	WDTCTL = WDTPW | WDTHOLD;                 // Stop watchdog timer
  	BCSCTL1 = CALBC1_1MHZ;                    // Set DCO
  	DCOCTL = CALDCO_1MHZ;
  	P4OUT = (BIT0);                           // P4 setup for LED
  	P4DIR |= (BIT0);                          //
 	P3DIR |= (BIT0 | BIT1 | BIT3 | BIT4);     // P3 setup for SPI ADC
  	P3DIR &= ~(BIT2 | BIT5);                           
  	P3SEL |= (BIT4 | BIT5);                   // P3.4,5 = USCI_A0 TXD/RXD
  	P3SEL |= (BIT1 | BIT2 | BIT3);
  	P3OUT |= (BIT0);
  
  	UCB0CTL0 |= UCCKPL | UCMSB | UCMST | UCSYNC;  // 3-pin, 8-bit SPI master
  	UCB0CTL1 |= UCSSEL_2;                     // SMCLK
  	UCA0CTL1 |= UCSSEL_2;                     // SMCLK
  	TACCR0 = 62500;
  	TACTL = TASSEL_2 | MC_2 | ID_3;           // SMCLK, contmode
  	UCB0BR0 = 0x02;                           // /2
  	UCB0BR1 = 0;                              //
	UCA0BR0 = 0x08;                           // 1MHz 115200
  	UCB0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
	UCA0MCTL = UCBRS2 | UCBRS0;               // Modulation UCBRSx = 5
	UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
	IE2 |= UCA0RXIE;                          // Enable USCI0 RX interrupt
  	IE2 |= UCA0TXIE;
  	TACCTL0 = CCIE;                           // TACCR0 interrupt enabled

  	__bis_SR_register(LPM0_bits + GIE);       // CPU off, enable interrupts
}

int spi_adc (int i)
{
	// Initialize data values
	// MST_Data Array. <Hex - Binary> 
	// |BIT0 |BIT1  |BIT2  |BIT3  |BIT4  |BIT5 |BIT6 |BIT7
	// |N/A  |ZERO  |ADD0  |ADD1  |ADD2  |REF  |PM0  |PM1
  	MST_Data[0] = 0x00;                        // [0] = 00000000                  
  	MST_Data[1] = 0x08;                        // [1] = 00001000
  	MST_Data[2] = 0x10;                        // [2] = 00010000
  	MST_Data[3] = 0x18;                        // [3] = 00011000
  	MST_Data[4] = 0x20;                        // [4] = 00100000
  	MST_Data[5] = 0x28;                        // [5] = 00101000
  	MST_Data[6] = 0x30;                        // [6] = 00110000
  	MST_Data[7] = 0x38;                        // [7] = 00111000
  	
	P3OUT &= ~(BIT0);
  	UCB0TXBUF = MST_Data[i];                // Transmit first character	
  	while (!(IFG2 & UCB0RXIFG));            // USCI_B0 TX buffer ready?
	data1 = UCB0RXBUF;                      // R15 = 00|MSB
	data1 = data1 << 8;                     // Bit shifting first byte
	UCB0TXBUF = 0x00;
	while (!(IFG2 & UCB0RXIFG));            // USCI_B0 TX buffer ready?
	data2 = UCB0RXBUF;
	adc = data1 + data2;                    // R14 = 00|LSB
	P3OUT |= (BIT0);
	return (adc*2.5)/4096.;                 // Voltage value conversion 
}

//SPI ADC
interrupt (TIMERA0_VECTOR) Timer_A (void)
{
	int i;
	
  	TACCR0 = 62500;
	P4OUT ^= (BIT0);                                           // Toggle LED

	uart_index = 0;
	
	uart_buffer[0] = PIPPER_SYNC_CHAR1;                        // Transmitting Syncronization charaters
	uart_buffer[1] = PIPPER_SYNC_CHAR2;

	for (i = 0; i < 8; i++)
		value[i] = spi_adc(i);                             // Sampling the data

	memcpy(&uart_buffer[2], &value[0], sizeof(value));         // Memcpy for values
	uart_buffer[34] = check_a((char *)value, sizeof(value));   // Transmitting checksums
	uart_buffer[35] = check_b((char *)value, sizeof(value));
	
	IE2 |= UCA0RXIE; 
}

//UART Communication
interrupt (USCIAB0RX_VECTOR) USCIA0RX_ISR (void)
{
	if((IFG2 & UCA0RXIFG) == UCA0RXIFG)
	{
		received = UCA0RXBUF;
		if (received == 'p')
		{	
			IE2 |= UCA0TXIE;
		}
	}
}

interrupt (USCIAB0TX_VECTOR) USCIA0TX_ISR(void)
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
