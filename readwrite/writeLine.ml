open Core.Std
open Async.Std

let main () : unit Deferred.t =
  let msg = "hello world!" in
  let file = "writeLine.txt" in
  Writer.open_file file >>= fun w ->
  Writer.write_line w msg;
  Writer.close w

let () =
  Command.(run (async ~summary:"" Spec.empty main))
