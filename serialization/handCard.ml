open Core.Std
open Async.Std

type suit =
  | Spades
  | Hearts
  | Diamonds
  | Clubs

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

type card = {
  suit: suit;
  rank: rank;
}

let string_of_suit (suit: suit) : string =
  match suit with
  | Spades   -> "Spades"
  | Hearts   -> "Hearts"
  | Diamonds -> "Diamonds"
  | Clubs    -> "Clubs"

let suit_of_string (s: string) : suit option =
  match s with
  | "Spades"   -> Some Spades
  | "Hearts"   -> Some Hearts
  | "Diamonds" -> Some Diamonds
  | "Clubs"    -> Some Clubs
  | _          -> None

let string_of_rank (rank: rank) : string =
  match rank with
  | One   -> "One"
  | Two   -> "Two"
  | Three -> "Three"
  | Four  -> "Four"
  | Five  -> "Five"
  | Six   -> "Six"
  | Seven -> "Seven"
  | Eight -> "Eight"
  | Nine  -> "Nine"
  | Ten   -> "Ten"
  | Jack  -> "Jack"
  | Queen -> "Queen"
  | King  -> "King"
  | Ace   -> "Ace"

let rank_of_string (s: string) : rank option =
  match s with
  | "One"   -> Some One
  | "Two"   -> Some Two
  | "Three" -> Some Three
  | "Four"  -> Some Four
  | "Five"  -> Some Five
  | "Six"   -> Some Six
  | "Seven" -> Some Seven
  | "Eight" -> Some Eight
  | "Nine"  -> Some Nine
  | "Ten"   -> Some Ten
  | "Jack"  -> Some Jack
  | "Queen" -> Some Queen
  | "King"  -> Some King
  | "Ace"   -> Some Ace
  | _       -> None

let string_of_card (card: card) : string =
  let {suit; rank} = card in
  (string_of_suit suit) ^ " " ^ (string_of_rank rank)

let card_of_string (s: string) : card option =
  let (>>=) o f =
    match o with
    | Some x -> f x
    | None -> None
  in

  match String.split s ~on:' ' with
  | [suit; rank] ->
    suit_of_string suit >>= fun suit ->
    rank_of_string rank >>= fun rank ->
    Some {suit; rank}
  | _ -> None

let main () : unit Deferred.t =
  let card = {
    suit = Spades;
    rank = Ace;
  } in

  (* card -> string *)
  let s = string_of_card card in
  print_endline s;

  (* card -> string -> card *)
  (match card_of_string s with
  | Some card' -> print_endline (string_of_card card')
  | None -> failwith "impossible");

  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
