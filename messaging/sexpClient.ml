open Core.Std
open Async.Std
open ArithSexp

let or_else res default =
  match res with
  | `Eof -> default
  | `Ok x -> Response.to_string (Response.t_of_sexp x)

let connect _ r w =
  let eval req =
    Writer.write_sexp w req
  in

  eval (Request.(sexp_of_t (Succ   42)));
  eval (Request.(sexp_of_t (Neg   (-42))));
  eval (Request.(sexp_of_t (Plus  (40, 2))));
  eval (Request.(sexp_of_t (Sub   (44, 2))));
  eval (Request.(sexp_of_t (Times (6, 7))));
  eval (Request.(sexp_of_t (Eq    (42, 42))));
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>| fun res -> print_endline (or_else res "Eof")

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
