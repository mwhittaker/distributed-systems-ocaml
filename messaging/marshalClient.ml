open Core.Std
open Async.Std
open ArithMarshal

let or_else res default =
  match res with
  | `Eof -> default
  | `Ok x -> Response.to_string x

let connect _ r w =
  let eval req =
    Writer.write_marshal w req ~flags:[]
  in

  eval (Request.Succ   42);
  eval (Request.Neg   (-42));
  eval (Request.Plus  (40, 2));
  eval (Request.Sub   (44, 2));
  eval (Request.Times (6, 7));
  eval (Request.Eq    (42, 42));
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_marshal r >>| fun res -> print_endline (or_else res "Eof")

let main host port () : unit Deferred.t =
  Tcp.with_connection (Tcp.to_host_and_port host port) connect

let () =
  Command.async
    ~summary:"Arith Client"
    Command.Spec.(
      empty
      +> flag "-host" (required string) ~doc:"RPC server hostname"
      +> flag "-port" (required int)    ~doc:"RPC server port"
    )
    main
  |> Command.run
