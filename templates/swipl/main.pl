#!/usr/bin/env swipl

:- use_module(library(clpfd)).

% TODO
part1(Input, Answer) :-
  writeln(Input),
  writeln(Answer).

% TODO
part2(Input, Answer) :-
  writeln(Input),
  writeln(Answer).

?- 
  read_file_to_string("input.txt", Input, []),

  part1(Input, Answer1),
  writeln(Answer1),

  part2(Input, Answer1),
  writeln(Answer2).
