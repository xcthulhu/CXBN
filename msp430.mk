CC=$(BASEDIR)/mspgcc4/bin/msp430-gcc
CFLAGS=-Os -mmcu=msp430x2274 -Wall
# Probably need to change the TTY depending on how you plugged things in
TTY=/dev/ttyUSB2

all: $(OBJ)

%.elf: %.c
	$(CC) $(CFLAGS) -o $@ $<

install: $(OBJ)
	mspdebug -d $(TTY) uif "prog $<"

uninstall: $(OBJ)
	mspdebug -d $(TTY) uif "erase"

clean: 
	rm -f $(OBJ)
