open Core.Std
open Async.Std

let write_msg (w: Writer.t) : unit Deferred.t =
  let msg = "hello world!" in
  Writer.write_line w msg;
  return ()

let main () : unit Deferred.t =
  let file = "writeWith.txt" in
  Writer.with_file file ~f:write_msg

let () =
  Command.(run (async ~summary:"" Spec.empty main))
