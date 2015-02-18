open Core.Std
open Async.Std

let main () : unit Deferred.t =
  printf "hello world!\n";
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
