#!/usr/bin/env swipl

read_file_to_chars(Filename, Content) :-
    read_file_to_codes(Filename, Codes, []),
    maplist(char_code, Content, Codes).

% Part 1
santa_part1([], 0).
santa_part1([')' | Rest], Floor) :- 
  santa_part1(Rest, Subtally),
  Floor is Subtally - 1.

santa_part1(['(' | Rest], Floor) :- 
  santa_part1(Rest, Subtally),
  Floor is Subtally + 1.

?- 
  read_file_to_chars("input.txt", Input),
  santa_part1(Input, Floor), 
  writeln(Floor).



% santa_part2(+Steps, +Floor, +Pos, +TargetFloor, -TargetPos)
% When we reach the target floor, we have reached the target position
santa_part2(_, TargetFloor, TargetPos, TargetFloor, TargetPos).
% when the remaining steps is empty, we should stop, target pos not found
santa_part2([], _, _, _, -1).
santa_part2(['(' | Rest], Floor, Pos, TargetFloor, TargetPos) :- 
  NextFloor is Floor + 1,
  NextPos is Pos + 1,
  santa_part2(Rest, NextFloor, NextPos, TargetFloor, TargetPos).

santa_part2([')' | Rest], Floor, Pos, TargetFloor, TargetPos) :- 
  NextFloor is Floor - 1,
  NextPos is Pos + 1,
  santa_part2(Rest, NextFloor, NextPos, TargetFloor, TargetPos).
%
% % Part 2
% % % the empty list means we traverse no floors
% santa_part2([], _, 0, []) :- !.
% % reaching floor -1, means we have reached our goal:
% santa_part2(_, Index, -1, Index) :- !.
% santa_part2([')' | Rest], Index, Floor, FirstIndex) :- 
%   NextFloor is Floor - 1,
%   NextIndex is Index + 1,
%   santa_part2(Rest, NextIndex, NextFloor, FirstIndex).
% %
% % santa_part2(['(' | Rest], Index, Floor, FirstIndex) :- 
% %   santa_part2(Rest, 1 + Index, Floor2), 
% %   Floor is Floor2 + 1.
% %
?-
  read_file_to_chars("input.txt", Input),
  santa_part2(Input, 0, 0, -1, Pos), 
  writeln(Pos).
