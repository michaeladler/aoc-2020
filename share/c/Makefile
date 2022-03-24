default: libaoc.so

%.o: %.c
	cc -Wall -fPIC -O3 -march=native -c $<

libaoc.so: aoc_nt.o
	cc -shared -o $@ $^

.PHONY: clean
clean:
	rm -f *.so *.o
