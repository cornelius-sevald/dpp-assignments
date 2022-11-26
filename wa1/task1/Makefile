PROG=process
SIZES=100 1000 10000 100000 1000000 10000000

.PHONY: data clean plot all

all: plot

plot: test_process.pdf test_process_idx.pdf

test_process.pdf: benchmark
	python plot.py $(PROG) test_process $(SIZES)

test_process_idx.pdf: benchmark
	python plot.py $(PROG) test_process_idx $(SIZES)

benchmark: process-opencl.json process-c.json

process-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

process-c.json: $(PROG).fut
	futhark bench --backend=c --json=$@ $^

clean:
	rm -fr data $(PROG) *.pdf *.bin *.c *.pyc *.json
