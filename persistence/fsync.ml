open Core.Std
open Async.Std

let main () : unit Deferred.t =
  Writer.open_file "fsync.txt" >>= fun w ->
  Writer.write w (String.make 10_000_000 '.');
  Writer.fsync w >>= fun () ->
  ignore (Pervasives.exit (-1));
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
