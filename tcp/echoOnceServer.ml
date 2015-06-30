(* Previously, we wrote a server that established a TCP connection, read a line
 * from the connection, printed it, and closed the connection. This only
 * reading from the TCP connection. Now, we'll read a line from the connection
 * and write it back on the same connection. This will involve both reading and
 * writing over TCP. *)
open Core.Std
open Async.Std

(* We bind r to the Reader.t and w to the Writer.t formed from the underlying
 * TCP connection. Then, we read and write using the same functions from the
 * previous chapter. Hopefully you've noticed by now that network programming
 * in OCaml is pretty easy! *)
let echo _ r w =
  Reader.read_line r >>| function
  | `Eof  -> print_endline "error"
  | `Ok s -> Writer.write_line w s

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen echo in
  never ()

(* Run this program the same way you ran the printing server we just wrote.
 * This time when you type something into telnet and press enter, the line you
 * typed will be echoed back to you! *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
