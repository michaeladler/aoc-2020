#include <stdio.h>
#include <stdlib.h>
#include "parser2.c"
#include <string.h>

%%{

machine calc;

action newline_tok {
   //Terminate this calculation.
   Parse(lparser, 0, 0, &result);
}

action plus_tok {
   Parse(lparser, TK_PLUS, 0, &result);
}

action times_tok {
   Parse(lparser, TK_TIMES, 0, &result);
}

action openp_tok {
   Parse(lparser, TK_OPENP, 0, &result);
}

action closep_tok {
   Parse(lparser, TK_CLOSEP, 0, &result);
}

action number_tok{
   strncpy(tmp, ts, te - ts);
   tmp[te-ts] = '\0';
   Parse(lparser, TK_LONG, atol(tmp), &result);
}

number = [0-9]+;
plus = '+';
openp = '(';
closep = ')';
times = '*';
newline = '\n';

main := |*
  number => number_tok;
  plus => plus_tok;
  openp => openp_tok;
  closep => closep_tok;
  times => times_tok;
  newline => newline_tok;
  space;
*|;

}%%

%% write data;

int main(int argc, char **argv)
{
    char buffer[32768];
    FILE* f;
    long numbytes;

    //Read the whole file into the buffer.
    f = fopen("input.txt", "r");
    fseek(f, 0, SEEK_END);
    numbytes = ftell(f);
    fseek(f, 0, SEEK_SET);
    fread(buffer, 1, numbytes, f);
    fclose(f);

    char tmp[256];
    long result = 0;

    //Parse the buffer in one fell swoop.
    int cs;
    int act;
    const char* ts;
    const char* te;

    void* lparser = ParseAlloc(malloc);

    %% write init;
    const char* p = buffer;
    const char* pe = buffer + numbytes;
    const char* eof = pe;

    %% write exec;

    ParseFree(lparser, free);

    printf("Part 2: %ld\n", result);
    return 0;
}

