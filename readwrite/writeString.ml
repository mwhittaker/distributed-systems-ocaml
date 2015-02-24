open Core.Std
open Async.Std

let main () : unit Deferred.t =
  let msg = "hello world!" in
  let file = "writeString.txt" in
  Writer.open_file file >>= fun w ->
  Writer.write w msg;
  Writer.close w

let () =
  Command.(run (async ~summary:"" Spec.empty main))
