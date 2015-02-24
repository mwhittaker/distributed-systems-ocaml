open Core.Std
open Async.Std
open Cohttp_async

let serve ~body _ req =
  ignore (body);
  match Uri.path (Request.uri req) with
  | "/" -> Server.respond_with_file "helloHtmlServer.html"
  | _   -> Server.respond_with_string "try curling /\n"

let main port () : unit Deferred.t =
  printf "Listening on port %d.\n" port;
  Server.create (Tcp.on_port port) serve >>= fun _ ->
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
