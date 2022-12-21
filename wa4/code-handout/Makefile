BACKEND?=opencl
MATRIX_INV=matrix-inversion
NUM_MATRICES=1 4 16 64 256 1024 4096 16384 65536
SIZE_MATRICES=1024 512 256 128 64 32 16 8 4

all: plot

plot: $(MATRIX_INV).pdf

$(MATRIX_INV).pdf: benchmark
	python plot.py $(MATRIX_INV) $(NUM_MATRICES) $(SIZE_MATRICES)


benchmark: $(MATRIX_INV)-tuned.json $(MATRIX_INV)-untuned.json

$(MATRIX_INV)-untuned.json: $(MATRIX_INV).fut
	rm -f $(MATRIX_INV).fut.tuning
	futhark bench --backend=$(BACKEND) --json=$@ $^

$(MATRIX_INV)-tuned.json: $(MATRIX_INV).fut $(MATRIX_INV).fut.tuning
	futhark bench --backend=$(BACKEND) --json=$@ $^

$(MATRIX_INV).fut.tuning: $(MATRIX_INV).fut
	futhark autotune --backend=$(BACKEND) $^

clean:
	rm -fr data $(MATRIX_INV) *.pdf *.bin *.c *.pyc *.json *.tuning

.PHONY: data plot all benchmark clean
