#include "../pipper_common.h"
#define LINUX_PIPPER_UART "/dev/ttyUSB1"

// BAUD RATE is 115200 (1 Mhz)
#define PIPPER_BAUD B115200

// Initialization routine for pipper subsystem
void pipper_init();

// Gets pipper data
struct pipper get_pipper();

/*
// Gets a single character from LINUX_PIPPER_UART
char get_pipc();

// Prints a single character from LINUX_PIPPER_UART
// Returns: Bytes written;  1 if successful and 0 if not. 
ssize_t put_pipc(char in);

// Gets a float from pipper character device
float get_pipf();
*/
