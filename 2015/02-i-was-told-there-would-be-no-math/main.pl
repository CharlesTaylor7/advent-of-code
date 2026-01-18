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

ribbon_and_paper(H, W, L, P, R) :-
  msort([H , W , L], [A, B | _]),
  P #= 
    2 * (H * W + W * L + H * L) % the total surface area
    + A * B, % the smallest face
  R #= 
    2 * (A + B) % the two smallest perimeters
    + H * W * L % the bow
.


read_row(Spec, H, W, L) :-
  split_string(Spec, "x", "", Dims),
  parse(Dims, H, W, L).

parse([A, B, C], H, W, L) :-
  atom_number(A, H),
  atom_number(B, W),
  atom_number(C, L).


?- test(read_row, ["3x4x5", 3, 4, 5]).

accumulate(Spec, [P1, R1], [P2, R2]) :-
  read_row(Spec, H, W, L),
  ribbon_and_paper(H, W, L, P, R),
  P2 #= P + P1,
  R2 #= R + R1.

/*
* 
*/
solution(Input, Answer) :-
  split_string(Input, "\n", "\n", Lines),
  foldl(accumulate, Lines, [0, 0], Answer).

?- 
  read_file_to_string("input.txt", Input, []),
  solution(Input, Answer),
  writeln(Answer).
