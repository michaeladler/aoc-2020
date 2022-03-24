all: day18_part1 day18_part2

###############################################################################
# Part 1
###############################################################################
day18_part1: lexer.o
	cc -O2 -g -march=native lexer.o -o day18_part1

parser.c: parser.y
	lemon $<

lexer.c: lexer.rl parser.c
	ragel $< -o $@

lexer.o: lexer.c
	cc -O2 -g -march=native -c $<

###############################################################################
# Part 2
###############################################################################
day18_part2: lexer2.o
	cc -O2 -g -march=native lexer2.o -o day18_part2

parser2.c: parser2.y
	lemon $<

lexer2.c: lexer2.rl parser2.c
	ragel $< -o $@

lexer2.o: lexer2.c
	cc -O2 -g -march=native -c $<

###############################################################################
# Cleanup
###############################################################################
clean:
	rm -f *.o lexer*.c parser*.h parser*.c parser*.out day18_part*
