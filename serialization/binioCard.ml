open Core.Std
open Async.Std

module Suit = struct
  type t =
    | Spades
    | Hearts
    | Diamonds
    | Clubs
  with bin_io, sexp
end

module Rank = struct
  type t =
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
  with bin_io, sexp
end

module Card = struct
  type t = {
    suit: Suit.t;
    rank: Rank.t;
  } with bin_io, sexp
end

let main () : unit Deferred.t =
  let open Suit in
  let open Rank in
  let open Card in

  let card = {
    suit = Spades;
    rank = Ace;
  } in
  let card_module = (module Card: Bin_prot.Binable.S with type t = Card.t) in

  (* card -> string *)
  let s = Binable.to_string card_module card in
  print_endline s;

  (* card -> string -> card *)
  let card' = Binable.of_string card_module s in
  print_endline (Sexp.to_string (Card.sexp_of_t card'));
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
