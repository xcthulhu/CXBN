#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h>
#include "get_pip.h"

#include "../../checksum_ref.c"

static int pip_fd = -1;
static int acquiring = 0;

// Initialization routine for pipper subsystem
// WARNING: Absolutely REQUIRED before reading data
void pipper_init() {
  /* Based on tutorial on UNIX serial ports:
     http://www.easysw.com/~mike/serial/serial.html
     ~mpwd 7/7/2011
  */
  struct termios pip_options;

  // Open LINUX_PIPPER_UART port file descriptor
  pip_fd = open(LINUX_PIPPER_UART, 
                O_RDWR | O_NOCTTY | O_NDELAY);

  if (pip_fd == -1)
    perror("open_port: Unable to open " LINUX_PIPPER_UART);
  else
    fcntl(pip_fd, F_SETFL, FNDELAY); // Use non-blocking behavior

  // Get the current options for the port
  tcgetattr(pip_fd, &pip_options);

  // Set the BAUD Rate to PIPPER_BAUD
  cfsetispeed(&pip_options, PIPPER_BAUD);

  // Enable CLOCAL and CREAD
  // MUST ALWAYS BE SET
  pip_options.c_cflag |= (CLOCAL | CREAD);

  // No parity (8N1)
  pip_options.c_cflag &= ~CSIZE;  // Mask the character size bits
  pip_options.c_cflag |= CS8;     // Use 8 character bits
  pip_options.c_cflag &= ~PARENB; // Disable parity bit
  pip_options.c_cflag &= ~CSTOPB; // 1 Stop bit

  tcsetattr(pip_fd, TCSANOW, &pip_options);
}

// Prints a single character from LINUX_PIPPER_UART
ssize_t put_pipc(char in) {
  return write(pip_fd,(&in),sizeof(in));
}

// Initiates transaction with PIPPER
void pip_acquire() {
        put_pipc(PIPPER_ACQUIRE);
}

// Gets a single character from LINUX_PIPPER_UART
// BUFFERED
// Returns 0xFF in case of failure
char get_pipc() {
  static int i = 0, j = 0;
  static char buf[255];
  if (i >= j) i = j = 0;
  if (i == 0) j = read(pip_fd,buf,sizeof(buf));
  if (j==-1 || i >= j)     // No data read or in insane state
  {
     i = j = 0;
     /* If we are acquiring data, 
        resend request to MSP430 to transmit
        and try to read a character again    */
     if (acquiring)
     {
	pip_acquire();
        return get_pipc();
     }
     else return 0xFF;     // Shouldn't ever happen
  }
  else return buf[i++];
}

// Gets a floating point from LINUX_PIPPER_UART
float get_pipf() {
  int i;
  float f = 0;
  char floatchars[sizeof(f)];
  for (i = 0; i < sizeof(f); i++) floatchars[i] = get_pipc();
  memcpy(&f, floatchars, sizeof(f));
  return f;
}

// Acquires data from the MSP430 assigned to the pipper
struct pipper get_pipper() {
  int i;
  float pip_floats[PIPPER_FLOATS];
  unsigned char src_chk_a, src_chk_b, my_chk_a, my_chk_b;
  struct pipper pip_data;

  acquiring = 1;
  pip_acquire();

  // Read pipper UART until we get a valid packet is found
  do {
    // Wait until get sync signal
    while(!(   get_pipc() == PIPPER_SYNC_CHAR1 
	       && get_pipc() == PIPPER_SYNC_CHAR2));
    // Read floats
    for (i = 0; i < PIPPER_FLOATS; i++) pip_floats[i] = get_pipf();
    src_chk_a = get_pipc(); src_chk_b = get_pipc();
    // Calculate checksums
    my_chk_a = check_a((char *)pip_floats,sizeof(pip_floats));
    my_chk_b = check_b((char *)pip_floats,sizeof(pip_floats));
  } while (!(my_chk_a == src_chk_a && my_chk_b == src_chk_b));
  // Loop until valid checksum

  // Once data is acquired, coerce into pipper structure
  pip_data.t0=pip_floats[0]; pip_data.t1=pip_floats[1]; 
  pip_data.t2=pip_floats[2]; pip_data.t3=pip_floats[3];
  pip_data.t4=pip_floats[4]; pip_data.t5=pip_floats[5];
  pip_data.t6=pip_floats[6]; pip_data.t7=pip_floats[7];
  
  // Stop acquiring and return
  acquiring = 0;
  return pip_data;
}
