(* In this program, we'll write a string to a file. We've already written a
 * program to write a string to stdout, and the great thing about the Writer
 * module it's agnostic about whatever it is we're writing to. So, we'll write
 * to the file the same way we wrote to stdout! We don't have to learn much
 * new. *)
open Core.Std
open Async.Std

let main () : unit Deferred.t =
  (* First, we define the message we want to write and the name of the file we
   * want to write to. *)
  let msg = "hello world!" in
  let file = "writeString.txt" in

  (* Next, we open up a file with the filename we chose up above. If the file
   * already existed, it's contents are erased. Writer.open_file returns,
   * expectedly, a Writer.t. *)
  Writer.open_file file >>= fun w ->

  (* Once we have our hands on w, we call Writer.write_line just like we did
   * when we wrote to stdout. *)
  Writer.write_line w msg;

  (* Finally, we close the file. We're required to close all the writers we
   * open. *)
  Writer.close w

let () =
  Command.(run (async ~summary:"" Spec.empty main))
