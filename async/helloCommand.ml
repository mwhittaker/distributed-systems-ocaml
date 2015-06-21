(* To write an async program that terminates, we'll use Jane Street's Command
 * library, which you can learn more about in Chapter 14 of Real World OCaml.
 *)
open Core.Std
open Async.Std

(* The first thing that's changed about our program is that we've made main
 * return a unit Deferred.t rather than just a unit. *)
let main () : unit Deferred.t =
  print_endline "hello world!";
  return ()

(* Also, rather than simply invoking main, we've instead used the Command
 * library to call main. I'll let you read about the details of the Command
 * library in Real World OCaml, but to summarize, this code says this program
 * should accept no command line arguments and should run the main function
 * when invoked.
 *
 * Go ahead and run this program. It prints "hello, world!" and then it
 * terminates! Awesome; this is exactly what we wanted. From now, we'll make
 * sure all our programs use the Command library. *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
