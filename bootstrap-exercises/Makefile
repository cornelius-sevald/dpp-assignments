SRC=$(wildcard *.fut)
EXE=$(patsubst %.fut,%,$(SRC))

test: $(SRC)
	@for f in $(SRC) ; do printf "%s:\n" $$f ; futhark test $$f ; done

clean:
	rm -f *.c *.actual *.expected
	rm -f $(EXE)
