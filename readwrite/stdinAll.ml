(* We've seen how to read a single line from stdin. Now, we're going to read
 * all of stdin, one line at a time. And, we'll print out every line that we
 * read. This program will act identically to calling the command line utility
 * cat without any arguments. *)
open Core.Std
open Async.Std

let main () : unit Deferred.t =
  (* First, we grab stdin as usual. *)
  let stdin = Lazy.force Reader.stdin in

  (* The Reader module has an awesome function that's perfect for iterating
   * over the lines of a reader. Reader.lines returns a string pipe where each
   * element in the pipe is a line from the reader. We can then iterate over
   * the pipe and print the lines to stdout. *)
  let lines = Reader.lines stdin in
  Pipe.iter_without_pushback lines ~f:print_endline

(* Run this program and start typing! *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
