open Core.Std
open Async.Std
open Arith

let eval = function
  | Request.Succ   i     -> Response.Int  (i + 1)
  | Request.Neg    i     -> Response.Int  (-i)
  | Request.Plus  (i, j) -> Response.Int  (i + j)
  | Request.Sub   (i, j) -> Response.Int  (i - j)
  | Request.Times (i, j) -> Response.Int  (i * j)
  | Request.Eq    (i, j) -> Response.Bool (i = j)

let serve _ r w =
  let rec loop r w =
    Reader.read_marshal r >>= fun req ->
    (match req with
     | `Eof -> ()
     | `Ok req -> Writer.write_marshal w (eval req) ~flags:[]);
    loop r w
  in

  loop r w

let main () : unit Deferred.t =
  ignore (Tcp.(Server.create (Tcp.on_port 8080) serve));
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
