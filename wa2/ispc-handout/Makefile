# Set ISPC_TARGET to 'host' to use the best instructions for your
# machine.  Note that I have observed that results may differ from
# sequential execution for some targets.  I am not certain whether
# this is an ISPC bug.

N_RUNS?=10
ISPC_TARGET?=sse4
ISPC=ispc -O3 --target=$(ISPC_TARGET) --pic
CC=gcc
CFLAGS=-O3 -std=c99 -Wall -Wextra -pedantic -fPIC
PROGRAMS=mandelbrot sum relax filter scan pack rle

.PHONY: all run bench

all: $(PROGRAMS)

run: $(PROGRAMS) $(PROGRAMS:%=run_%)

bench: $(PROGRAMS) $(PROGRAMS:%=bench_%)

run_%: % %.c
	echo $*
	./$*

bench_%: % %.c
	./bench.sh -n $(N_RUNS) $*

$(PROGRAMS): %: %.c %.o %.h timing.h
	$(CC) -o $@ $(CFLAGS) $*.c $*.o

%.o %.h: %.ispc
	$(ISPC) $< -o $*.o -h $*.h

%.s: %.ispc
	$(ISPC) $< -o $*.s --emit-asm --x86-asm-syntax=intel

clean:
	rm -f $(PROGRAMS) $(PROGRAMS:=.o) $(PROGRAMS:=.h)
