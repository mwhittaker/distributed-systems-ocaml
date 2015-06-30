(* In this program, we write a server which receives data from clients and
 * echoes it back to them. *)
open Core.Std
open Async.Std

let echo _ r w =
  Reader.transfer r (Writer.pipe w)

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen echo in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
