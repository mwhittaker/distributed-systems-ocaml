open Core.Std
open Async.Std

let print_odocl (dir: string) : unit Deferred.t =
  (* print header *)
  printf "{9 %s}\n" dir;

  (* begin list *)
  printf "{ol\n";

  Reader.open_file ("../" ^ dir ^ "/doc.odocl") >>= fun r ->
  let lines = Reader.lines r in
  let print_line s = printf " {- {{:code_%s.html} [%s]}}\n" s s in
  Pipe.iter_without_pushback lines ~f:print_line >>= fun () ->

  (* end list *)
  printf "}\n\n";

  return ()

let main () : unit Deferred.t =
  (* dirs with a [doc.odocl] file. *)
  let dirs = [
    "async";
    "readwrite";
    "tcp";
  ] in

  Deferred.List.iter dirs ~f:print_odocl

let () =
  Command.(run (async ~summary:"" Spec.empty main))
