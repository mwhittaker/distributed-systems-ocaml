(* In this program, we'll write a simplified version of the command line
 * utility cat. When cat is invoked with no arguments, it echoes user input
 * line by line. When passed a list of filenames, cat prints the contents of
 * each file to the screen. Cat also has a bunch of command line flags to alter
 * its behaviour, but we won't implement any of those. *)
open Core.Std
open Async.Std

let readme () =
  "Concatenate FILE(s), or standard input, to standard output"

(* First, we write a function to transfer stdin to stdout. *)
let cat_stdin () =
  let stdin  = Lazy.force Reader.stdin in
  let stdout = Lazy.force Writer.stdout in
  Reader.transfer stdin (Writer.pipe stdout)

(* Next, we write a function to print the contents of a file. *)
let cat_file filename =
  let stdout = Lazy.force Writer.stdout in
  Reader.with_file filename
    ~f:(fun file -> Reader.transfer file (Writer.pipe stdout))

(* Finally, we write our main function. If the user didn't specify any
 * filenames, we echo stdin. Otherwise, we print out the contents of the
 * provided files. *)
let main filenames () : unit Deferred.t =
  match filenames with
  | [] -> cat_stdin ()
  | fs -> Deferred.List.iter fs ~f:cat_file

let () =
  Command.async
    ~summary:"concatenate files and print on the standard output"
    ~readme:readme
    Command.Spec.(
      empty
      +> anon (sequence ("FILE" %: file))
    )
    main
  |> Command.run
