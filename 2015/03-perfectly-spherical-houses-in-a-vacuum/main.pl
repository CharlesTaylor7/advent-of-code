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


visited(Steps, Visited) :-
  foldl(santa_step, Steps, [[0, 0]], Visited).


santa_step('>', Acc, Result) :-
  Acc = [[X, Y] | _],
  Result = [[X + 1 , Y] | Acc].

santa_step('<', Acc, Result) :-
  Acc = [[X, Y]|_],
  Result = [[X-1,Y]|Acc].

santa_step('^', Acc, Result) :-
  Acc = [[X, Y]|_],
  Result = [[X,Y-1]|Acc].

santa_step('v', Acc, Result) :-
  Acc = [[X, Y]|_],
  Result = [[X,Y+1]|Acc].

% handle misc characters like newline
santa_step(_, Acc, Acc).
  
% TODO
part1(Input, Answer) :-
  visited(Input, Answer).

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
