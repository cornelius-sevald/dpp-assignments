BACKEND?=opencl
PROG=flat-if-then-else

test: $(PROG).fut
	futhark test --backend=$(BACKEND) $<

bench: $(PROG).fut
	futhark bench --entry-point=bench_flatIf --backend=$(BACKEND) $<

clean:
	rm -fr *.c *.expected *.actual data/ $(PROG)

.PHONY: test clean
