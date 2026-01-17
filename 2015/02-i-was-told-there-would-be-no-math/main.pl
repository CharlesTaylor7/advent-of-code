#!/usr/bin/env swipl

read_file_to_chars(Filename, Content) :-
    read_file_to_codes(Filename, Codes, []),
    maplist(char_code, Content, Codes).

part1(Input, Answer) :-
  !. % TODO

part2(Input, Answer) :-
  !. % TODO

?- 
  read_file_to_chars("input.txt", Input),
  part1(Input, Answer1),
  writeln(Answer1),
  part2(Input, Answer2),
  writeln(Answer2).
