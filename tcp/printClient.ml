(* Now that we've familiarized ourselves with writing TCP servers, let's turn
 * our attention to writing TCP clients. Creating a TCP client and creating a
 * TCP server are very similar. Instead of calling Tcp.Server.create, we'll
 * call Tcp.with_connection, but other than that, our code will remain largely
 * unchanged.
 *
 * In this program, we'll write a very simple TCP client that sends a single
 * line to a server. This client is intended to be run against our printing
 * server (i.e. printServer.ml). *)
open Core.Std
open Async.Std

(* First, we define a function with the same form as the functions we wrote
 * when creating TCP servers. For example, contrast this function to the
 * function we wrote in printServer.ml:
 *
 *   let printer _ r _ =
 *     Reader.read_line r >>| function
 *     | `Eof  -> print_endline "error"
 *     | `Ok s -> print_endline s
 *
 * The code has almost identical form. The only difference is that our server
 * reads and our client writes. *)
let connect _ _ w =
  Writer.write_line w "hello, world!";
  return ()

(* Next, we call Tcp.with_connection passing in the address of our server and
 * our handling function: connect. *)
let main () : unit Deferred.t =
  Tcp.with_connection (Tcp.to_host_and_port "localhost" 8080) connect

(* Compile and run printServer.ml. Then, in a separate terminal, compile and
 * run this program. This client will send "hello, world!" to the server and
 * then terminate. The server will print "hello, world!" and then wait for more
 * connections. *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
