open Core.Std
open Async.Std

let readme () =
  "Concatenate FILE(s), or standard input, to standard output"

let cat_stdin () =
  Pipe.iter_without_pushback (Reader.lines (Lazy.force Reader.stdin)) ~f:print_endline

let cat_file filename =
  Reader.file_contents filename >>| print_string

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
