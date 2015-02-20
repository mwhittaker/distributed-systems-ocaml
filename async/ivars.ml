open Core.Std
open Async.Std

let basics () : unit Deferred.t =
  let i = Ivar.create () in
  don't_wait_for (after (sec 1.0) >>| fun () -> Ivar.fill i "hello");
  let d = Ivar.read i in
  d >>| print_endline

let choices_fill () : unit Deferred.t =
  (*
  let i = Ivar.create () in
  Deferred.all_unit [
    (after (sec 2.) >>| fun () -> Ivar.fill i "haskell");
    (after (sec 1.) >>| fun () -> Ivar.fill i "ocaml");
  ] >>= fun () ->
  Ivar.read i >>= fun s ->
  print_endline s;
  *)
  return ()

let choices_fill_if_empty () : unit Deferred.t =
  let i = Ivar.create () in
  Deferred.all_unit [
    (after (sec 2.) >>| fun () -> Ivar.fill_if_empty i "haskell");
    (after (sec 1.) >>| fun () -> Ivar.fill_if_empty i "ocaml");
  ] >>= fun () ->
  Ivar.read i >>| print_endline

let main () : unit Deferred.t =
  basics () >>= fun () ->
  choices_fill () >>= fun () ->
  choices_fill_if_empty () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
