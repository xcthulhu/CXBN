#include "msp430x22x4.h"
#include <signal.h>
#include <string.h>

#define SYNC_CHAR1  'T'
#define SYNC_CHAR2  'e'

unsigned char MST_Data, SLV_Data;
unsigned short temp[8];
unsigned int data1, data2;
float conv_temp[8];
static unsigned char UART_index = 0;

unsigned char uart_buffer[36];

int main(void)
{
    WDTCTL = WDTPW + WDTHOLD;                 // Stop watchdog timer
    BCSCTL1 = CALBC1_8MHZ;                    // Set DCO
    DCOCTL = CALDCO_8MHZ;
    P1OUT = 0x00;                             // P1 setup for LED
    P1DIR |= 0x01;                            //
    //P3OUT = 0x40;                           // Set slave reset
    P3DIR |= (BIT3);
    P3DIR &= ~(BIT2+BIT5);
    P3DIR |= (BIT4);
    P3SEL |= (BIT3+BIT2);                     // P3.2,3 USCI_B0 option select
    P3SEL |= (BIT4 + BIT5);                   // P3.4,5 = USCI_A0 TXD/RXD

    P4DIR |= (BIT0 + BIT1 + BIT2 + BIT3 + BIT4 + BIT5 + BIT6 + BIT7); // P4.0,1,2,3,4,5,6,7. CS
    P4SEL &= ~(BIT0 + BIT1 + BIT2 + BIT3 + BIT4 + BIT5 + BIT6 + BIT7);
    P4OUT = 0xFF;

    UCB0CTL0 |= UCCKPL + UCMSB + UCMST + UCSYNC;  // 3-pin, 8-bit SPI master
    UCB0CTL1 |= UCSSEL_2;                     // SMCLK
    UCA0CTL1 |= UCSSEL_2;                     // SMCLK
    TACCR0 = 62500;
    TACTL = TASSEL_2 + MC_2 + ID_3;           // SMCLK, contmode
    UCB0BR0 |= 0x02;                          // /2
    UCB0BR1 = 0;                              //
    UCA0BR0 = 0x45;                           // 1MHz 115200
    UCA0BR1 = 0;                              // 1MHz 115200
    UCA0MCTL = UCBRS2 + UCBRS0;               // Modulation UCBRSx = 5
    UCA0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
    UCB0CTL1 &= ~UCSWRST;                     // **Initialize USCI state machine**
    IE2 |= UCB0RXIE;                          // Enable USCI_B0 RX interrupt
    IE2 |= UCA0RXIE;                          // Enable USCI0 RX interrupt
    IE2 |= UCA0TXIE;
    TACCTL0 = CCIE;                           // TACCR0 interrupt enabled

    __bis_SR_register(LPM0_bits + GIE);       // CPU off, enable interrupts

    return 0;
}

//Temp_SPI
/**** IMPORTANT NOTE ****/
/*  The following code specifies that "Timer_A"
    will use an interrupt vector named "TIMERA0_VECTOR"

>>>>>>
#pragma vector=TIMERA0_VECTOR
__interrupt void Timer_A(void)
<<<<<<

    This code is ***NOT VALID*** in gcc

    Read the following for a description on how
    to correctly write functions returning interrupt
    vectors in mspgcc:

    http://mspgcc.sourceforge.net/manual/x918.html

    ~mpwd
*/

interrupt (TIMERA0_VECTOR) Timer_A(void)
{
    volatile int i = 0;
    unsigned long int value[8];
    TACCR0 = 62500;

    MST_Data = 0x01;                          // Initialize data values
    SLV_Data = 0x00;

    do
    {
        P4OUT = ~(BIT0 << i);
        UCB0TXBUF = MST_Data;                 // Transmit first character
        UCB0TXBUF = MST_Data;

        while (!(IFG2 & UCB0RXIFG));          // USCI_B0 TX buffer ready?
        data1 = UCB0RXBUF;                    // R15 = 00|MSB
        data1 = data1 << 8;
        while (!(IFG2 & UCB0RXIFG));          // USCI_B0 TX buffer ready?
        data2 = UCB0RXBUF;
        temp[i] = data1 + data2;              // R14 = 00|LSB
        temp[i] = temp[i] >> 3;
        if ((0x1000 & temp[i]) == 0x1000)
        {
            temp[i] = temp[i] & 0x0FFF;
            temp[i] = (temp[i] | 0x8000);
        }
        conv_temp[i] = temp[i] * 0.0625;
        P4OUT = 0xFF;
        //memcpy(&conv_temp[i], &value[i], 4);
        i++;
    }
    while (i<8);

    P1OUT ^= 0X01;
    UART_index = 0;

    unsigned char ck_a = 0x00, ck_b = 0x00;
    for (i=2; i<=33; i++)
    {
        ck_a = ck_a + uart_buffer[i];
        ck_b = ck_a + ck_b;
    }
    uart_buffer[0] = SYNC_CHAR1;
    uart_buffer[1] = SYNC_CHAR2;
    uart_buffer[34] = ck_a;
    uart_buffer[35] = ck_b;
    memcpy(&uart_buffer[2], &conv_temp[0], sizeof(conv_temp));
    IE2 |= UCA0RXIE;
}

// UART
//#pragma vector=USCIAB0RX_VECTOR
//__interrupt void USCIA0RX_ISR(void)
interrupt (USCIAB0RX_VECTOR) USCIA0RX_ISR(void)
{
    if((IFG2 & UCA0RXIFG) == UCA0RXIFG)
    {
        unsigned char received;
        received = UCA0RXBUF;
        if (received == 'S')
        {
            IE2 |= UCA0TXIE;
        }
    }
}

//#pragma vector=USCIAB0TX_VECTOR
//__interrupt void USCIA0TX_ISR(void)
interrupt (USCIAB0TX_VECTOR) USCIA0TX_ISR(void)
{
    //unsigned char* conv_temp_ptr;
    if((IFG2 & UCA0TXIFG) == UCA0TXIFG)
    {
        //conv_temp_ptr = (unsigned char*) &conv_temp[0];
        UCA0TXBUF = (uart_buffer[UART_index++]);
        if (UART_index >= 36)
        {
            UART_index = 0;
            IE2 &= ~UCA0TXIE;
        }
    }

    /**** Delete this??  Why would we be blinking lights in space??? ~mpwd ****/
    //if ((IFG2 & UCB0RXIFG) == UCB0RXIFG)
    //{
    //	while( !(IFG2 & UCB0TXIFG));
    //	  if (UCB0RXBUF == SLV_Data)                // Test for correct character RX'd
    //		P1OUT |= 0x01;                          // If correct, light LED
    //	  else
    //		P1OUT &= ~0x01;                         // If incorrect, clear LED

    //	    MST_Data++;                               // Increment master value
    //	    SLV_Data++;                               // Increment expected slave value
    //		UCB0TXBUF = MST_Data;                     // Send next value

    //	 for (i = 30; i; i--);                     // Add time between transmissions to
    //}
}
