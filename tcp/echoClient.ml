(* We wrote a print client to send a message to our printing server. Now, we'll
 * write an echoing client to communicate with our echo server. This client
 * will repeatedly read a line from stdin, send it to the echo server, read the
 * echoed string, and print it to the screen. *)
open Core.Std
open Async.Std

let sender _ r w =
  let stdin = Lazy.force Reader.stdin in

  let rec loop r w =
    printf "> ";
    (* Step one: read a line from the user. *)
    Reader.read_line stdin >>= function
    | `Eof -> (printf "Error reading stdin\n"; return ())
    | `Ok line -> begin
      (* Step two: send it to the server. *)
      Writer.write_line w line;
      (* Step three: read back the echoed string. *)
      Reader.read_line r >>= function
      (* Step four: print it out. *)
      | `Eof -> (printf "Error reading server\n"; return ())
      | `Ok line -> (print_endline line; loop r w)
    end
  in

  loop r w

let main () : unit Deferred.t =
  ignore (Tcp.with_connection (Tcp.to_host_and_port "localhost" 8080) sender);
  never ()

(* First run echoServer.ml, then run echoClient.ml. *)
let () =
  Command.(run (async ~summary:"" Spec.empty main))
