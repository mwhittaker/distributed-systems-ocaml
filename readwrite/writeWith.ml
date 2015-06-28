(* In writeString.ml, we saw how to write a string to a file. We opened a file,
 * wrote to it, and closed the file. It's important we always close the writers
 * we open, but it's all to easy to forget to close the writer. In this
 * program, we'll see an alternate way to operate on files that makes it
 * impossible for us to forget to close them. *)
open Core.Std
open Async.Std

(* First, let's write a function to write the message we want to a generic
 * writer. As before, we use Writer.write_line to do so. *)
let write_msg (w: Writer.t) : unit Deferred.t =
  let msg = "hello world!" in
  Writer.write_line w msg;
  return ()

let main () : unit Deferred.t =
  let file = "writeWith.txt" in
  (* Now, instead of calling Writer.open_file, and then Writer.close, we'll use
   * Writer.with_file. Writer.with_file takes in the filename of the file we're
   * interested in. It'll open the file and pass it to the function we provide.
   * When our function finishes, it'll close the file for us. Now, we don't
   * have to worry about closing the file. *)
  Writer.with_file file ~f:write_msg

let () =
  Command.(run (async ~summary:"" Spec.empty main))
