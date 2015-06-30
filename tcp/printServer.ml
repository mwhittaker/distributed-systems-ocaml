(* In this program, we'll write a very simple TCP server. The server will read
 * a single line from a client, print it out, and then close the connection. *)
open Core.Std open Async.Std

(* Async's TCP library has a function Tcp.Server.create which allows us to very
 * easily create a TCP server. Tcp.Server.create takes in two arguments: the
 * internet address on which to listen and a function. When we call create, it
 * starts a TCP server. Whenever a client connects to the server, a Reader.t
 * and Writer.t are formed from the TCP connection and passed to the function
   * we gave to Tcp.Server.create. *)

(* Here, printer is the function we'll pass to Tcp.Server.create. The first
 * argument is the address of the client, which we'll rarely use. The second
 * and third are the Reader.t and Writer.t of the underlying TCP connection.
 * Since we're not going to use the address or writer, we bind them to _, and
 * since we are going to use the writer, we bind it to the variable r. *)
let printer _ r _ =
  (* In the previous chapter, we saw how to interact with readers and writers
   * using files and stdin. Now we're dealing with TCP conncetions, but
   * nothing's changed. We read a line from a TCP connection the same way we
   * read a line from a file or from stdin! This means we don't have to learn
   * anything new in order to be familiar with network programming in OCaml. *)
  Reader.read_line r >>| function
  | `Eof  -> print_endline "error"
  | `Ok s -> print_endline s

let main () : unit Deferred.t =
  (* In order to launch the server, we first choose the server's port. *)
  let port = 8080 in
  printf "listening on port %d\n" port;

  (* Then, we Tcp.on_port to create a description of the socket the TCP server
   * should listen on. *)
  let where_to_listen = Tcp.on_port port in

  (* Finally, we create the server with Tcp.Server.create. create returns an
   * object of type Tcp.Server.t, but we won't use the server, so we ignore it.
   *)
  ignore (Tcp.Server.create where_to_listen printer);

  (* We want our TCP server to run forever, so we return a deferred that never
   * becomes determined! *)
  never ()

(* Compile and run this program. It should print "listening on port 8080".
 * Then, run the following command to connect to the server: `telnet localhost
 * 8080`. This will open up an interactive telnet shell that's connected to our
 * server. Type in something and hit enter. The server will print out your
 * message and then end the connection, forcing your telnet session to
 * terminate. *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
