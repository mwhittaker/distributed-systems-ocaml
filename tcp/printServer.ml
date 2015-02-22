open Core.Std
open Async.Std

let printer _ r _ =
  Reader.read_line r >>| function
  | `Eof  -> print_endline "error"
  | `Ok s -> print_endline s

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen printer in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
