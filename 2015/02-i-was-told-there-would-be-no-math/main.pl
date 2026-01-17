#!/usr/bin/env swipl

:- use_module(library(clpfd)).

% handle parse failures
paper([], _, _, 0).
paper(H, W, L, Paper) :-
  min(H * W, W * L, H * L, Extra),
  Paper #= 2 * (H * W + W * L + H * L) + Extra.


min(A, B, C, R) :- 
  min(A, B, R1),
  min(R1, C, R).

min(A, B, A) :- A #=< B.
min(A, B, B) :- B #=< A.

code_digit(Code, Digit) :- 
  Code #= Digit + 48.
char_digit(Char, Digit) :- 
  char_code(Char, Code),
  code_digit(Code, Digit).

to_dims(Row, H, W, L) :-
  split_string(Row, "x", "", Dims),
  parse(Dims, H, W, L).

parse([A, B, C], H, W, L) :-
  atom_number(A, H),
  atom_number(B, W),
  atom_number(C, L).


% parse([A, 'x', B, 'x', C], H, W, L) :- 
%   atom_number(A, H),
%   atom_number(B, W),
%   atom_number(C, L).
%
% parse(_, [], [], []).

ribbon(String, Ribbon) :-
  string_chars(String, Chars),
  to_dims(Chars, H, W, L),
  paper(H, W, L, Ribbon).

sum([], _, Acc, Acc).
sum([X|Rest], Goal, Acc, Total) :-
  call(Goal, X, N),
  NextAcc #= N + Acc,
  sum(Rest, Goal, NextAcc, Total).

part1(Input, Answer) :-
  split_string(Input, "\n", "", Lines),
  sum(Lines, ribbon, 0, Answer).

?- 
  read_file_to_string("input.txt", Input, []),
  part1(Input, Answer1),
  writeln(Answer1).
