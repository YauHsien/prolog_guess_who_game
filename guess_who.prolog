:- dynamic vos/3.
:- dynamic candidates/2.
data_path('./data').
load([]) :- !,
    findall(S1, vos(_,_,S1), Ss),
    sort(Ss, Cs),
    length(Cs, Lcs),
    update(candidates(Lcs,Cs)).
load([row(V,O,S)|Rest]) :-
    update(vos(V,O,S)),
    load(Rest).

update(P) :-
    clean(P),
    assertz(P).

clean(P) :-
    retract(P), !;
    true.

:- dynamic v/1.
:- dynamic o/1.
:- dynamic s/1.

one_char :-
    clean(v(_)),
    clean(o(_)),
    clean(s(_)),
    candidates(N, Cs),
    random(0, N, I),
    nth0(I, Cs, Candidate),
    update(s(Candidate)),
    findall(V-O, vos(V,O,Candidate), Vos),
    length(Vos, M),
    random(0, M, J),
    nth0(J, Vos, V-O),
    update(v(V)),
    update(o(O)).

match(S, S).

init :- data_path(File_path),
        csv_read_file(File_path, Data, [separator(0'\s),strip(true),match_arity(false)]),
        load(Data),
        game.

game :-
    (s(_), !,
     true;
     one_char),
    v(V),
    o(O),
    format("Guess who ~p ~p?~nType name or `give up`; `hint` to get hints; `quit` to end this game.~n", [V,O]),
    read(G),
    s(S),
    ( ground(G), !,
      ( quit = G, !,
        format("Bye!~n"),
        halt ;
        hint = G, !,
        candidates(_, Cs),
        format("Candidates: ~p~n~n", [Cs]),
        game ;
        'give up' = G, !,
        format("So, it's ~p~n~n", [S]),
        game ;
        match(S, G), !,
        format("You got it!~n~n"),
        clean(s(_)),
        game ;
        format("You got it wrong! Ha!~n~n"),
        game
      ) ;
      format("User Prolog term syntax.~n~n"),
      game
    ).

:- init.
