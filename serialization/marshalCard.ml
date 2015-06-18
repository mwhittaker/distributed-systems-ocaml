open Core.Std
open Async.Std

type suit =
  | Spades
  | Hearts
  | Diamonds
  | Clubs
with sexp

type rank =
  | One
  | Two
  | Three
  | Four
  | Five
  | Six
  | Seven
  | Eight
  | Nine
  | Ten
  | Jack
  | Queen
  | King
  | Ace
with sexp

type card = {
  suit: suit;
  rank: rank;
} with sexp

let main () : unit Deferred.t =
  let card = {
    suit = Spades;
    rank = Ace;
  } in

  (* card -> string *)
  let s = Marshal.to_string card [] in
  print_endline s;

  (* card -> string -> card *)
  let card' = Marshal.from_string s 0 in
  print_endline (Sexp.to_string (sexp_of_card card'));

  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
