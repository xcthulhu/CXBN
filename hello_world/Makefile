BASE=..
ARMADEUS_TOOLCHAIN_PATH=$(BASE)/armadeus/buildroot/output/build/staging_dir/usr/bin
CC=$(ARMADEUS_TOOLCHAIN_PATH)/arm-linux-gcc
CFLAGS=-Wall -Os
PROGS=hello

all : $(PROGS)

hello : hello.c
	$(CC) $(CFLAGS) -o $@ $<

clean :
	rm -f $(OBJS)

include $(BASE)/kermit_install.mk
