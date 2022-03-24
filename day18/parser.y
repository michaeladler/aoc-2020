%token_type {long}
%token_prefix TK_

%extra_argument { long *result }

%left PLUS TIMES.

%include {
#include <stdio.h>
#include <assert.h>
#include "parser.h"
}

%syntax_error {
  fprintf(stderr, "Syntax error\n");
}

program ::= expr(A). { /* fprintf(stderr, "Result: %ld\n", A); */ *result = *result + A; }

expr(A) ::= OPENP expr(B) CLOSEP. { A = (B); }
expr(A) ::= expr(B) PLUS expr(C). { /* fprintf(stderr, "Adding: %ld + %ld\n", B, C); */ A = B + C; }
expr(A) ::= expr(B) TIMES expr(C). { /* fprintf(stderr, "Multiplying: %ld * %ld\n", B, C); */ A = B * C; }
expr(A) ::= LONG(B). { A = B; }

