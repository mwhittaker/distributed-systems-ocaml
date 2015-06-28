(* Now that we've been introduced to the Reader module, we'll introduce
 * ourselves to the Writer module. There's no surprises here. Just like the
 * it's Reader counterpart, the Writer modules defines an abstract type t and a
 * whole bunch of functions to write to a Writer.t.
 *
 * In the last program, we read from stdin. Now, we'll write to stdout. *)
open Core.Std
open Async.Std

let main () : unit Deferred.t =
  (* Just like with Reader.stdin, we have to force the lazy Writer.stdout. *)
  let stdout = Lazy.force Writer.stdout in

  (* Then, we just call Writer.write_line to write a string to the Writer.t. *)
  Writer.write_line stdout "hello, world!";
  return ()

(* That's all there is to it! The Reader and Writer modules are intentionally
 * very similar, so once you are comfortable with one, you'll be comfortable
 * with both. *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
