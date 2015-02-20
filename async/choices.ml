open Core.Std
open Async.Std

let time () : unit Deferred.t =
  after (sec 1.) >>= fun () ->
  printf "%d\n" 1;
  after (sec 1.) >>= fun () ->
  printf "%d\n" 2;
  after (sec 1.) >>| fun () ->
  printf "%d\n" 3

let delayed (t: float) (x: 'a) : 'a Deferred.t =
  after (sec t) >>= fun () ->
  return x

let def_all () : unit Deferred.t =
  Deferred.all [delayed 0.5 "hello"; delayed 1. "world"; delayed 1.5 "!"] >>| fun l ->
  List.iter l ~f:(print_endline)

let def_all_unit () : unit Deferred.t =
  Deferred.all_unit [
    (after (sec 0.5) >>| fun () -> print_endline "hello");
    (after (sec 1.0) >>| fun () -> print_endline "world");
    (after (sec 1.5) >>| fun () -> print_endline "!");
  ]

let def_any () : unit Deferred.t =
  Deferred.any [delayed 0.5 "fast!"; delayed 1.0 "slow!"] >>| print_endline

let def_any_unit () =
  Deferred.any_unit [
    (after (sec 0.5) >>| fun () -> print_endline "fast");
    (after (sec 1.0) >>| fun () -> print_endline "slow");
    (after (sec 1.5) >>| fun () -> print_endline "slowest");
  ]

let def_both () : unit Deferred.t =
  Deferred.both (delayed 1. "hello") (delayed 0.5 42) >>| fun (a, b) ->
  printf "%s, %d\n" a b

let main () : unit Deferred.t =
  time () >>= fun () ->
  def_all () >>= fun () ->
  def_all_unit () >>= fun () ->
  def_any () >>= fun () ->
  def_any_unit () >>= fun () ->
  def_both () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
