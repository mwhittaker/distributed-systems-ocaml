open Core.Std
open Async.Std

let main () : unit Deferred.t =
  let stdin = Lazy.force Reader.stdin in
  Reader.read_line stdin >>| function
  | `Eof  -> print_endline "error"
  | `Ok x -> print_endline x

let () =
  Command.(run (async ~summary:"" Spec.empty main))
