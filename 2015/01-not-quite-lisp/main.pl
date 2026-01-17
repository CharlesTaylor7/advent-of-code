#!/usr/bin/env swipl

read_input(File, Input) :-
    open(File, read, Stream),
    read_line_to_codes(Stream, Codes),
    maplist(char_code, Input, Codes),
    close(Stream).

% Part 1
santa_part1([], 0).

santa_part1([')' | Rest], Floor) :- 
  santa_part1(Rest, Floor2), 
  Floor is Floor2 - 1.

santa_part1(['(' | Rest], Floor) :- 
  santa_part1(Rest, Floor2), 
  Floor is Floor2 + 1.

?- 
  read_input("input.txt", Input),
  santa_part1(Input, Floor), 
  write(Floor).
%
% % Part 2
% % the empty list means we traverse no floors
santa_part2([], _, 0, []) :- !.
% reaching floor -1, means we have reached our goal:
santa_part2(_, Index, -1, Index) :- !.
santa_part2([')' | Rest], Index, Floor, FirstIndex) :- 
  NextFloor is Floor - 1,
  NextIndex is Index + 1,
  santa_part2(Rest, NextIndex, NextFloor, FirstIndex).
%
% santa_part2(['(' | Rest], Index, Floor, FirstIndex) :- 
%   santa_part2(Rest, 1 + Index, Floor2), 
%   Floor is Floor2 + 1.
%
% ?-
%   read_input("input.txt", Input),
%   santa_part2(Input, Index, -1), 
%   write(Index).
