open Core.Std
open Async.Std

let sender _ r w =
  let stdin = Lazy.force Reader.stdin in

  let rec loop r w =
    printf "> ";
    Reader.read_line stdin >>= function
    | `Eof -> (printf "Error reading stdin\n"; return ())
    | `Ok line -> begin
      Writer.write_line w line;
      Reader.read_line r >>= function
      | `Eof -> (printf "Error reading server\n"; return ())
      | `Ok line -> (print_endline line; loop r w)
    end
  in

  loop r w

let main () : unit Deferred.t =
  let host = "localhost" in
  let port = 8080 in
  ignore (Tcp.with_connection (Tcp.to_host_and_port host port) sender);
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
