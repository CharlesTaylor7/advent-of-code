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

/*
* min/4
* find the minimum of 3 values
*/
min(A, B, C, R) :- 
  min(A, B, R1),
  min(R1, C, R).

/*
* min/3
* find the minimum of 2 values
* left biased min
*/
min(A, B, A) :- A #=< B.
min(A, B, B) :- B #< A.

/*
* paper/4
*/
paper(H, W, L, Paper) :-
  min(H * W, W * L, H * L, Extra),
  Paper #= 2 * (H * W + W * L + H * L) + Extra.

?- test(paper, [2, 2, 2, 28]).

to_dims(Row, H, W, L) :-
  split_string(Row, "x", "", Dims),
  parse(Dims, H, W, L).

parse([A, B, C], H, W, L) :-
  atom_number(A, H),
  atom_number(B, W),
  atom_number(C, L).


?- test(to_dims, ["3x4x5", 3, 4, 5]).
% parse([A, 'x', B, 'x', C], H, W, L) :- 
%   atom_number(A, H),
%   atom_number(B, W),
%   atom_number(C, L).
%
% parse(_, [], [], []).

ribbon(String, Ribbon) :-
  to_dims(String, H, W, L),
  paper(H, W, L, Ribbon).

?- test(ribbon, ["3x4x5", 106]).


map_then_sum(Dims, Acc, Total) :-
  ribbon(Dims, Ribbon),
  Total #= Acc + Ribbon.
/*
* 
*/
part1(Input, Answer) :-
  split_string(Input, "\n", "\n", Lines),
  foldl(map_then_sum, Lines, 0, Answer).

?- 
  read_file_to_string("input.txt", Input, []),
  part1(Input, Answer1),
  writeln(Answer1).
