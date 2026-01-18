#!/usr/bin/env swipl

:- use_module(library(clpfd)).

/*
* test/2
* run a test case and report failure to stdout
*/
test(Predicate, Args) :-
  Goal =.. [Predicate | Args],
  (
    call(Goal) -> true;
    format("Testcase ~w failed!", Goal)
  ).


% TODO
part1(Input, Answer) :-
  writeln(Input),
  writeln(Answer).

% TODO
part2(Input, Answer) :-
  writeln(Input),
  writeln(Answer).

?- read_file_to_string("input.txt", Input, [])
, part1(Input, Answer1)
, writeln(Answer1)
  % part2(Input, Answer1),
  % writeln(Answer2)
.
