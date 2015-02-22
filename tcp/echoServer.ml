open Core.Std
open Async.Std

let printer _ r w =
  Reader.transfer r (Writer.pipe w)

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen printer in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
