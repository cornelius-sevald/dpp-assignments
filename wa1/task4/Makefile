CC?=cc
CFLAGS=-O3 -std=c99
FUTHARK_BACKEND?=multicore
PROG=ising
SIZES=100 1000 10000 100000 1000000 10000000

ifeq ($(FUTHARK_BACKEND),opencl)
OS=$(shell uname -s)
ifeq ($(OS),Darwin)
LDFLAGS=-framework OpenCL -lm
else
LDFLAGS=-lOpenCL -lm
endif
else ifeq ($(FUTHARK_BACKEND),cuda)
LDFLAGS=-lcuda -lnvrtc -lm
else ifeq ($(FUTHARK_BACKEND),c)
LDFLAGS= -lm
else ifeq ($(FUTHARK_BACKEND),multicore)
LDFLAGS=-lpthread -lm
else
$(error Unknown FUTHARK_BACKEND: $(FUTHARK_BACKEND).  Must be 'opencl', 'cuda', 'multicore', or 'c')
endif

all: ising-tui plot

# BENCHMARKS

plot: test_ising.pdf

test_ising.pdf: benchmark
	python plot.py $(PROG) test_ising $(SIZES)

benchmark: ising-opencl.json ising-multicore.json ising-c.json

ising-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

ising-multicore.json: $(PROG).fut
	futhark bench --backend=multicore --json=$@ $^

ising-c.json: $(PROG).fut
	futhark bench --backend=c --json=$@ $^

# TUI

ising.h ising.c: ising.fut
	futhark $(FUTHARK_BACKEND) --library $<

ising.o: ising.c
	$(CC) -c -o $@ $^ $(CFLAGS)

ising-tui.o: ising-tui.c ising.h
	$(CC) -c -o $@ $< $(CFLAGS)

ising-tui: ising-tui.o ising.o
	$(CC) -o $@ $^ $(LDFLAGS)

clean:
	rm -fr ising-tui *.o ising.c ising.o ising.c data $(PROG) *.pdf *.bin *.pyc *.json
