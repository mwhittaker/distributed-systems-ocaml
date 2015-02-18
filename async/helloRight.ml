open Core.Std
open Async.Std

let main () : unit =
  printf "hello world!\n"

let () =
  main ();
  never_returns (Scheduler.go ())
