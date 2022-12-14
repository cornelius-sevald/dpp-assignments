BACKEND?=opencl
IF_THEN_ELSE=flat-if-then-else
QUICKSORT=quicksort-flat

all: test bench

test: test-if test-quicksort

bench: bench-if bench-quicksort

test-if: $(IF_THEN_ELSE).fut
	futhark test --backend=$(BACKEND) $<

bench-if: $(IF_THEN_ELSE).fut
	futhark bench --backend=$(BACKEND) $<

test-quicksort: $(QUICKSORT).fut
	futhark test --backend=$(BACKEND) $<

bench-quicksort: $(QUICKSORT).fut
	futhark bench --backend=$(BACKEND) $<

clean:
	rm -fr *.c *.expected *.actual data/ $(IF_THEN_ELSE) $(QUICKSORT)

.PHONY: test clean
