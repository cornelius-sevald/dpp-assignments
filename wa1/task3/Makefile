PROG=segmented
SCAN_BENCHMARKS=test_segscan test_scan
REDUCE_BENCHMARKS=test_segreduce test_reduce

SIZES=100 1000 10000 100000 1000000 10000000
.PHONY: data clean plot all

all: plot

plot: bench_segscan.pdf bench_segreduce.pdf

bench_segscan.pdf: benchmark
	python plot.py $(PROG) segmented_scan "$(SCAN_BENCHMARKS)" $(SIZES)

bench_segreduce.pdf: benchmark
	python plot.py $(PROG) segmented_reduce "$(REDUCE_BENCHMARKS)" $(SIZES)

benchmark: $(PROG)-opencl.json

$(PROG)-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

clean:
	rm -fr data $(PROG) *.pdf *.bin *.c *.pyc *.json
