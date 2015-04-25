open Core.Std
open Async.Std
open ArithSexp

let or_else res default =
  match res with
  | `Eof -> default
  | `Ok x -> Response.to_string (Response.t_of_sexp x)

let connect _ r w =
  Writer.write_sexp w (Request.(sexp_of_t (Succ   42)));
  Writer.write_sexp w (Request.(sexp_of_t (Neg   (-42))));
  Writer.write_sexp w (Request.(sexp_of_t (Plus  (40, 2))));
  Writer.write_sexp w (Request.(sexp_of_t (Sub   (44, 2))));
  Writer.write_sexp w (Request.(sexp_of_t (Times (6, 7))));
  Writer.write_sexp w (Request.(sexp_of_t (Eq    (42, 42))));
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>= fun res -> print_endline (or_else res "Eof");
  Reader.read_sexp r >>| fun res -> print_endline (or_else res "Eof")

let main () : unit Deferred.t =
  Tcp.with_connection (Tcp.to_host_and_port "localhost" 8080) connect

let () =
  Command.(run (async ~summary:"" Spec.empty main))
