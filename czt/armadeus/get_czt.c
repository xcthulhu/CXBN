#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h>
#include "get_czt.h"

#include "../../checksum_ref.c"

static int fd = -1;
static int acquiring = 0;

// Initialization routine
// WARNING: Absolutely REQUIRED before reading data
void czt_init() {
  /* Based on tutorial on UNIX serial ports:
     http://www.easysw.com/~mike/serial/serial.html
     ~mpwd 7/7/2011
  */
  struct termios options;

  // Open LINUX_CZT_UART port file descriptor
  fd = open(LINUX_CZT_UART, 
                O_RDWR | O_NOCTTY | O_NDELAY);

  if (fd == -1)
    perror("open_port: Unable to open " LINUX_CZT_UART);
  else
    fcntl(fd, F_SETFL, FNDELAY); // Use non-blocking behavior

  // Get the current options for the port
  tcgetattr(fd, &options);

  // Set the BAUD Rate to CZT_BAUD
  cfsetispeed(&options, CZT_BAUD);

  // Ignore break condition
  options.c_iflag |= (IGNBRK | IGNCR);

  // Enable CLOCAL and CREAD
  // MUST ALWAYS BE SET
  options.c_cflag |= (CLOCAL | CREAD);

  // No parity (8N1)
  options.c_cflag &= ~CSIZE;  // Mask the character size bits
  options.c_cflag |= CS8;     // Use 8 character bits
  options.c_cflag &= ~PARENB; // Disable parity bit
  options.c_cflag &= ~CSTOPB; // 1 Stop bit

  tcsetattr(fd, TCSANOW, &options);
}

// Prints a single character from LINUX_CZT_UART
ssize_t put_cztc(char in) {
  return write(fd,(&in),sizeof(in));
}

// Gets a single character from LINUX_CZT_UART
// BUFFERED
// Returns 0xFF in case of failure
char get_cztc() {
  static int i = 0, j = 0, timeout = 3;
  static char buf[255];
  if (i >= j) i = j = 0;
  if (i == 0) j = read(fd,buf,sizeof(buf));
  if (j==-1 || i >= j)     // No data read or in insane state
  {
     i = j = 0;
     if (timeout > 0) {
        timeout--;
        return get_cztc();
     } else {
            perror("Timeout tries exceeded for CZT ADC");
            timeout = 3;
            return 0xFF;     // Shouldn't ever happen
     }
     /*
     // If we are acquiring data, 
     // resend request to MSP430 to transmit
     // and try to read a character again 
     if (acquiring && timeout > 3)
     {
	pip_acquire();
        return get_pipc();
     }
     else {
            perror("Timeout tries exceeded for pipper");
            return 0xFF;     // Shouldn't ever happen
     }
     */
  }
  else return buf[i++];
}
