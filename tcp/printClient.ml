open Core.Std
open Async.Std

let connect _ r w =
  Writer.write_line w "hello, world!";
  Reader.read_line r >>| function
  | `Eof -> print_endline "Eof"
  | `Ok x -> print_endline x

let main () : unit Deferred.t =
  Tcp.with_connection (Tcp.to_host_and_port "localhost" 8080) connect

let () =
  Command.(run (async ~summary:"" Spec.empty main))
