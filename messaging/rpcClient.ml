open Core.Std
open Async.Std
open ArithRpc

let main host port () : unit Deferred.t =
  let f conn : unit Deferred.t =
    let eval req =
      Rpc.Rpc.dispatch_exn eval_rpc conn req
    in

    eval (Request.Succ   42)      >>= fun a ->
    eval (Request.Neg   (-42))    >>= fun b ->
    eval (Request.Plus  (40, 2))  >>= fun c ->
    eval (Request.Sub   (44, 2))  >>= fun d ->
    eval (Request.Times (6, 7))   >>= fun e ->
    eval (Request.Eq    (42, 42)) >>= fun f ->
    print_endline (Response.to_string a);
    print_endline (Response.to_string b);
    print_endline (Response.to_string c);
    print_endline (Response.to_string d);
    print_endline (Response.to_string e);
    print_endline (Response.to_string f);
    return ()
  in
  RpcUtil.with_rpc_connection f ~host ~port

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
