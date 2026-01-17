#!/usr/bin/env swipl

read_input(File, Input) :-
    open(File, read, Stream),
    read_line_to_codes(Stream, Codes),
    maplist(code_to_atom, Codes, Input),
    close(Stream).

code_to_atom(Code, Atom) :-
    char_code(Atom, Code).


% ?- input(I), santa_direction(I, T).

santa_direction([],0).
santa_direction([')' | R], T) :- santa_direction(R, T2), T is T2 - 1.
santa_direction(['(' | R], T) :- santa_direction(R, T2), T is T2 + 1.
?- santa_direction([')', '('], T), write(T).
