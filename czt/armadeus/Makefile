CC=gcc
CFLAGS=-Os -Wall
OBJS=get_pip.o test.o
BENCH_TEST=test

all: $(OBJS) $(BENCH_TEST)

$(BENCH_TEST): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $@

clean:
	rm -f $(OBJS) $(BENCH_TEST)
