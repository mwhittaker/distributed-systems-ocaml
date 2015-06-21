open Core.Std
open Async.Std
open ArithRpc

let eval () query =
  let response =
    match query with
    | Request.Succ   i     -> Response.Int  (i + 1)
    | Request.Neg    i     -> Response.Int  (-i)
    | Request.Plus  (i, j) -> Response.Int  (i + j)
    | Request.Sub   (i, j) -> Response.Int  (i - j)
    | Request.Times (i, j) -> Response.Int  (i * j)
    | Request.Eq    (i, j) -> Response.Bool (i = j)
  in
  return response

let main port () : unit Deferred.t =
  let implementations = [
    Rpc.Rpc.implement eval_rpc eval
  ] in
  RpcUtil.start_server ~env:() ~implementations ~port

let () =
  Command.async
    ~summary:"Arith RPC"
    Command.Spec.(
      empty
      +> flag "-port" (required int) ~doc:"RPC server port"
    )
    main
  |> Command.run
