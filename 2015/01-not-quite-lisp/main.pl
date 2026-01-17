#!/usr/bin/env swipl

read_input(File, Input) :-
    open(File, read, Stream),
    read_line_to_codes(Stream, Codes),
    maplist(char_code, Input, Codes),
    close(Stream).


% ?- input(I), santa_direction(I, T).

santa_direction([],0).
santa_direction([')' | R], T) :- santa_direction(R, T2), T is T2 - 1.
santa_direction(['(' | R], T) :- santa_direction(R, T2), T is T2 + 1.
?- 
  read_input("input.txt", Input),
  santa_direction(Input, Tally), 
  write(Tally).
