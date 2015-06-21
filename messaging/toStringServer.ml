open Core.Std
open Async.Std

let to_string () i =
  return (Int.to_string i)

let main port () : unit Deferred.t =
  let implementations = [
    Rpc.Rpc.implement ToStringProtocol.to_string_rpc to_string
  ] in
  RpcUtil.start_server ~env:() ~implementations ~port

let () =
  Command.async
    ~summary:"ToString RPC"
    Command.Spec.(
      empty
      +> flag "-port" (required int) ~doc:"RPC server port"
    )
    main
  |> Command.run
