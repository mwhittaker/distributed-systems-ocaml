open Core.Std
open Async.Std

let serve ~body _ req =
  ignore (body);
  match Uri.path (Cohttp_async.Request.uri req) with
  | "/" -> Cohttp_async.Server.respond_with_string "hello, world!\n"
  | _   -> Cohttp_async.Server.respond_with_string "try curling /\n"

let main port () : unit Deferred.t =
  printf "Listening on port %d.\n" port;
  Cohttp_async.Server.create (Tcp.on_port port) serve >>= fun _ ->
  never ()

let () =
  Command.async
    ~summary:"Serves 'hello, world' over http"
    Command.Spec.(
      empty
      +> flag "-p" (optional_with_default 8080 int) ~doc:"port"
    )
    main
  |> Command.run
