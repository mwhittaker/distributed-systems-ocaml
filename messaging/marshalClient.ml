open Core.Std
open Async.Std
open Arith

let or_else res default =
  match res with
  | `Eof -> default
  | `Ok x -> Response.to_string x

let connect _ r w =
  Writer.write_marshal w (Request.Succ   42)      ~flags:[];
  Writer.write_marshal w (Request.Neg   (-42))    ~flags:[];
  Writer.write_marshal w (Request.Plus  (40, 2))  ~flags:[];
  Writer.write_marshal w (Request.Sub   (44, 2))  ~flags:[];
  Writer.write_marshal w (Request.Times (6, 7))   ~flags:[];
  Writer.write_marshal w (Request.Eq    (42, 42)) ~flags:[];
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>| fun res -> print_endline (or_else res "Eof")

let main () : unit Deferred.t =
  Tcp.with_connection (Tcp.to_host_and_port "localhost" 8080) connect

let () =
  Command.(run (async ~summary:"" Spec.empty main))
