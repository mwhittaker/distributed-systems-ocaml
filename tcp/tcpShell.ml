(* In this program, we'll write a simple command line utility to relay input
 * from stdin over a TCP connection. Think of this program like a minimal
 * version of telnet. *)
open Core.Std
open Async.Std

let sender _ r w =
  let stdin = Lazy.force Reader.stdin in
  let stdout = Lazy.force Writer.stdout in
  (* We transfer stdin over our TCP connection. *)
  don't_wait_for (Reader.transfer stdin (Writer.pipe w));
  (* And, we simultaneously transfer the inbound TPC traffic to to stdout. *)
  don't_wait_for (Reader.transfer r (Writer.pipe stdout));
  never ()

let main host port () : unit Deferred.t =
  ignore (Tcp.with_connection (Tcp.to_host_and_port host port) sender);
  never ()

(* We'll also take the hostname and port of the server we connect to as command
 * line arguments. Compile this program, then run `./tcpShell.byte
 * www.google.com 80`. This will connect to a Google server on port 80. Then
 * type `GET /` to fetch the Google homepage. *)
let () =
  Command.async
    ~summary:"Redirect stdin over tcp"
    Command.Spec.(
      empty
      +> anon ("host" %: string)
      +> anon ("port" %: int)
    )
    main
  |> Command.run
