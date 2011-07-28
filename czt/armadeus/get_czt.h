#define LINUX_CZT_UART "/dev/ttyUSB1"

// BAUD RATE is 115200 (1 Mhz)
#define CZT_BAUD B38400

// Initialization routine for pipper subsystem
void czt_init();

// Gets a single character from LINUX_CZT_UART
char get_cztc();

// Prints a single character from LINUX_CZT_UART
// Returns: Bytes written;  1 if successful and 0 if not. 
ssize_t put_cztc(char in);
