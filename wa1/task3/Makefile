SEG_PROG=segmented
SEG_BENCHMARKS=test_segscan test_scan test_segreduce test_reduce
RBI_PROG=reduce_by_index
RBI_BENCHMARKS=test_my_reduce_by_index test_reduce_by_index
SIZES=100 1000 10000 100000 1000000 10000000

.PHONY: data clean plot all

all: plot

plot: bench_segmented.pdf bench_reduce_by_index.pdf

bench_segmented.pdf: benchmark
	python plot.py $(SEG_PROG) "$(SEG_BENCHMARKS)" "i32 bool" $(SEG_SIZES)

bench_reduce_by_index.pdf: benchmark
	python plot.py $(RBI_PROG) "$(RBI_BENCHMARKS)" "i64 i32" $(SEG_SIZES)

benchmark: $(SEG_PROG)-opencl.json $(RBI_PROG)-opencl.json

$(SEG_PROG)-opencl.json: $(SEG_PROG).fut
	futhark bench --backend=opencl --json=$@ $^

$(RBI_PROG)-opencl.json: $(RBI_PROG).fut
	futhark bench --backend=opencl --json=$@ $^

sync:
	futhark pkg sync

clean:
	rm -fr data $(SEG_PROG) $(RBI_PROG) *.pdf *.bin *.c *.pyc *.json
