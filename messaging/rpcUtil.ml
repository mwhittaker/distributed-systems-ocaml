open Core.Std
open Async.Std

(* Taken from Yaron Minsky's core-hello-world project on BitBucket. *)

let with_rpc_connection (dispatch_queries: Rpc.Connection.t -> 'a Deferred.t)
                        ~(host: string)
                        ~(port: int)
                        : 'a Deferred.t =
  let f = fun _ r w ->
    let connection_state = fun _ -> () in
    let on_handshake_error = `Raise in
    Rpc.Connection.with_close r w
      ~dispatch_queries ~connection_state ~on_handshake_error
  in

  Tcp.with_connection (Tcp.to_host_and_port host port) f

let start_server ~(env: 'a)
                 ~(implementations: 'a Rpc.Implementation.t list)
                 ~(port: int)
                 : unit Deferred.t =
  let implementations = Rpc.Implementations.create_exn
    ~implementations ~on_unknown_rpc:`Raise in
  let _ = Tcp.Server.create (Tcp.on_port port) (fun _ r w ->
    let connection_state = fun _ -> env in
    let on_handshake_error = `Raise in
    Rpc.Connection.server_with_close r w
      ~implementations ~connection_state ~on_handshake_error
  ) in
  never ()
