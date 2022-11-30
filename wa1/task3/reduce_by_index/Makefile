PROG=reduce_by_index
BENCHMARKS=test_my_reduce_by_index test_reduce_by_index
SIZES=100 1000 10000 100000 1000000 10000000

.PHONY: data clean plot all

all: plot

plot: bench_reduce_by_index.pdf

bench_reduce_by_index.pdf: benchmark
	python plot.py $(PROG) "$(BENCHMARKS)" $(SIZES)

benchmark: $(PROG)-opencl.json

$(PROG)-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

sync:
	futhark pkg sync

clean:
	rm -fr data $(PROG) *.pdf *.bin *.c *.pyc *.json
