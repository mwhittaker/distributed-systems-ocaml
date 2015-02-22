open Core.Std
open Async.Std

let rec printer s r w =
  Reader.read_line r >>= function
  | `Eof  -> return ()
  | `Ok x -> if x = "exit" then return () else (Writer.write_line w x; printer s r w)

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen printer in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
