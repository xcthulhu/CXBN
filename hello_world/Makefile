BASEDIR=..
ARMADEUS_TOOLCHAIN_PATH=$(BASEDIR)/armadeus/buildroot/output/build/staging_dir/usr/bin/
CC=$(ARMADEUS_TOOLCHAIN_PATH)/arm-linux-gcc
CFLAGS=-Wall -Os
OBJS=hello

all : $(OBJS)

hello : hello.c
	$(CC) $(CFLAGS) -o $@ $<

clean :
	rm -f $(OBJS)
