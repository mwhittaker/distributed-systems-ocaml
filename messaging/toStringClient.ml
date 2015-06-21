open Core.Std
open Async.Std

let main host port () : unit Deferred.t =
  let f conn : unit Deferred.t =
    Rpc.Rpc.dispatch_exn ToStringProtocol.to_string_rpc conn 1 >>= fun one ->
    Rpc.Rpc.dispatch_exn ToStringProtocol.to_string_rpc conn 2 >>= fun two ->
    Rpc.Rpc.dispatch_exn ToStringProtocol.to_string_rpc conn 3 >>| fun three ->
    printf "%s, %s, %s!\n" one two three
  in
  RpcUtil.with_rpc_connection f ~host ~port

let () =
  Command.async
    ~summary:"ToString Client"
    Command.Spec.(
      empty
      +> flag "-host" (required string) ~doc:"RPC server hostname"
      +> flag "-port" (required int)    ~doc:"RPC server port"
    )
    main
  |> Command.run
