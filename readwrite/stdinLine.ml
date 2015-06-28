(* Welcome! In this program, we'll take a look at the Reader module found
 * inside Async.Std. The Reader module defines an abstract type t, where an
 * instance of type Reader.t represents an entity that's capable of reading
 * from something like a file or TCP connection. For example, you can construct
 * a reader for stdin and read from the user (that's what we'll do in this
 * program). Or, you can construct a reader from a file and read the contents
 * file (we'll do this soon). Or, you can construct a reader from a TCP
 * connection and read messages from another process (we'll do this in a later
 * chapter).
 *
 * You may notice that an object of type Reader.t is very similar to an
 * instance of type Pipe.Reader.t. That's because they are very similar. A
 * Reader.t is like the reader end of the pipe, except that the writer end of
 * the pipe may be something like a file or TCP connection. In fact, the two
 * are so similar, there are functions in the Reader module for converting the
 * reader end of a pipe into a Reader.t and for converting a Reader.t into the
 * reader end of a pipe!
 *
 * In this chapter, we'll see a very short example of how to use the Reader
 * module by reading a line from standard in and printing it to the screen. *)
open Core.Std
open Async.Std

let main () : unit Deferred.t =
  (* First up, we create a Reader.t from stdin. Luckily, the Reader module has
   * exactly this already! The only hiccup is that Reader.stdin is of type
   * `Reader.t Core.Std.Lazy.t`. It's not too important what that means; all we
   * have to do is call Lazy.force to get the Reader.t we're looking for. *)
  let stdin = Lazy.force Reader.stdin in

  (* The Reader module has a lot of functions to read from a Reader.t:
   * Reader.read, Reader.read_char, Reader.really_read, etc. For now, we just
   * want to read a single from the user, so we'll use Reader.read_line. As
   * the name suggests, it reads all the data up to and including the newline
   * character.
   *
   * Of course, reading could go wrong. For example, we could read from a file
   * that's been deleted or read from a TCP connection that's been closed. So,
   * Reader.read_line, and all the other reading functions in the Reader
   * module, return a Read_result.t. A Read_result.t is either `Eof (signifying
   * we've hit the end of the reader) or an `Ok x, where the x is the data
   * we're after. If our read here doesn't work, we'll just print "error".
   * Otherwise, we'll print whatever line the user typed in. *)
  Reader.read_line stdin >>| function
  | `Eof  -> print_endline "error"
  | `Ok x -> print_endline x

(* Go ahead and run this program, then type something in and hit enter! *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
