open Core.Std
open Async.Std

let main () : unit Deferred.t =
  let stdin = Lazy.force Reader.stdin in
  let lines = Reader.lines stdin in
  Pipe.iter_without_pushback lines ~f:print_endline

let () =
  Command.(run (async ~summary:"" Spec.empty main))
