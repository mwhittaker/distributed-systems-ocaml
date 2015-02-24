open Core.Std
open Async.Std

(* dirs with a [doc.odocl] file. *)
let dirs = [
  "async";
  "readwrite";
  "tcp";
]

(* intro file *)
let intro = "intro.txt"

(* output file *)
let index = "index.txt"

let write_odocl (index: Writer.t) (dir: string) : unit Deferred.t =
  (* print header *)
  Writer.writef index "{9 %s}\n" dir;

  (* print chapter *)
  Reader.file_contents ("../" ^ dir ^ "/chapter.txt") >>= fun chapter_txt ->
  Writer.write_line index "";
  Writer.write index chapter_txt;
  Writer.write_line index "";

  (* begin list *)
  Writer.writef index "{ol\n";

  Reader.open_file ("../" ^ dir ^ "/doc.odocl") >>= fun r ->
  let lines = Reader.lines r in
  let write_line s = Writer.writef index " {- {{:code_%s.html} [%s]}}\n" s s in
  Pipe.iter_without_pushback lines ~f:write_line >>= fun () ->

  (* end list *)
  Writer.write index "}\n\n";

  return ()

let write_index (index: Writer.t) : unit Deferred.t =
  Reader.file_contents intro >>= fun intro_txt ->
  Writer.write index intro_txt;
  Writer.write_line index "";
  Deferred.List.iter dirs ~f:(write_odocl index)

let main () : unit Deferred.t =
  try_with (fun () -> Writer.with_file index ~f:write_index) >>| function
  | Ok ()   -> ()
  | Error e -> print_endline (Exn.to_string e)

let () =
  Command.(run (async ~summary:"" Spec.empty main))
