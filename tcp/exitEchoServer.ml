(* So far, we've written servers to print and echo data read from a client, but
 * both these servers didn't inspect the data they received. They blindly
 * printed or echoed data without knowing or caring what it was. In this
 * program, we'll write an echo server with an extra feature: when the client
 * sends the string "exit", the server closes the connection. This server will
 * have to inspect the data it receives to know whether or not to terminate. *)
open Core.Std
open Async.Std

let rec printer s r w =
  (* We begin, as usual, by reading a line from the TCP connection. *)
  Reader.read_line r >>= function
  | `Eof  -> return ()
  (* Except this time, we inspect the data to see if it's the work "exit". If
   * it is, we terminate. *)
  | `Ok "exit" -> return ()
  (* Otherwise, we echo the data and recurse. *)
  | `Ok x -> (Writer.write_line w x; printer s r w)

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen printer in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
