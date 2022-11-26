PROG=prefix-sum
BENCHMARKS=test_hillis_steele test_work_efficient test_scan
SIZES=32768 65536 131072 262144 524288 1048576 2097152 4194304 8388608 16777216
.PHONY: data clean plot all

all: plot

plot: bench_prefix_sums.pdf

bench_prefix_sums.pdf: benchmark
	python plot.py $(PROG) "$(BENCHMARKS)" $(SIZES)

benchmark: $(PROG)-opencl.json

$(PROG)-opencl.json: $(PROG).fut
	futhark bench --backend=opencl --json=$@ $^

clean:
	rm -fr data $(PROG) *.pdf *.bin *.c *.pyc *.json
