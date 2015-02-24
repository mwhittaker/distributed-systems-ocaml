open Core.Std
open Async.Std
open Cohttp_async

let root req =
  let uri = Request.uri req in
  let name = Uri.get_query_param uri "name" in
  let name = Option.value name ~default:"world" in
  Server.respond_with_string ("hello, " ^ name ^ "\n")

let serve ~body _ req =
  ignore (body);
  match Uri.path (Request.uri req) with
  | "/" -> root req
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
