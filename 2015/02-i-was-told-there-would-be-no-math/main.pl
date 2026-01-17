#!/usr/bin/env swipl

read_input(File, Input) :-
    open(File, read, Stream),
    read_line_to_codes(Stream, Codes),
    maplist(char_code, Input, Codes),
    close(Stream).

% Part 1
soln([], 0).

?- 
  read_input("input.txt", Input),
  soln(Input, Answer), 
  writeln(Answer).
