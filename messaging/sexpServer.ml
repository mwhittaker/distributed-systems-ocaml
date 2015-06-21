open Core.Std
open Async.Std
open ArithSexp

let eval = function
  | Request.Succ   i     -> Response.Int  (i + 1)
  | Request.Neg    i     -> Response.Int  (-i)
  | Request.Plus  (i, j) -> Response.Int  (i + j)
  | Request.Sub   (i, j) -> Response.Int  (i - j)
  | Request.Times (i, j) -> Response.Int  (i * j)
  | Request.Eq    (i, j) -> Response.Bool (i = j)

let serve _ r w =
  let rec loop r w =
    Reader.read_sexp r >>= fun req ->
    (match req with
     | `Eof -> ()
     | `Ok req ->
         let req = Request.t_of_sexp req in
         Writer.write_sexp w (Response.sexp_of_t (eval req)));
    loop r w
  in

  loop r w

let main port () : unit Deferred.t =
  ignore (Tcp.(Server.create (Tcp.on_port port) serve));
  never ()

let () =
  Command.async
    ~summary:"Arith RPC"
    Command.Spec.(
      empty
      +> flag "-port" (required int) ~doc:"RPC server port"
    )
    main
  |> Command.run
