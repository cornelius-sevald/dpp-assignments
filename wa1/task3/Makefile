PROG=segmented
BENCHMARKS=test_segscan test_scan test_segreduce test_reduce

SIZES=100 1000 10000 100000 1000000 10000000
.PHONY: data clean plot all

all: plot

plot: bench_segmented.pdf

bench_segmented.pdf: benchmark
	python plot.py $(PROG) "$(BENCHMARKS)" $(SIZES)

benchmark: $(PROG)-opencl.json

$(PROG)-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

clean:
	rm -fr data $(PROG) *.pdf *.bin *.c *.pyc *.json
