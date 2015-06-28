(* At this point, we've seen how to read data from standard in, and we've seen
 * how to write data to files. Now, we'll do both! This program will take in a
 * filename as an argument. We'll then read input from stdin and append it to
 * the specified file. A user may use this program to write a new message to
 * the file every day, sort of like a diary. *)
open Core.Std
open Async.Std

(* First we write a function to transfer the contents of stdin to the end of
 * the diary. *)
let stdin_to_diary (w: Writer.t) : unit Deferred.t =
  (* First, we grab stdin like usual. *)
  let stdin = Lazy.force Reader.stdin in
  (* Next, we use Writer.pipe to convert our Writer.t into a Pipe.Writer.t.
   * Then, we use Reader.transfer to transfer the contents of stdin to the
   * writer. *)
  Reader.transfer stdin (Writer.pipe w)

let main filename () : unit Deferred.t =
  (* We use Writer.with_file as before, but this time we open the file for
   * appending. This let's us open a file without erasing its contents. *)
  Writer.with_file ~append:true filename ~f:stdin_to_diary

let () =
  Command.async
    ~summary:"Enter an entry in a diary."
    Command.Spec.(empty +> anon ("filename" %: string))
    main
  |> Command.run
