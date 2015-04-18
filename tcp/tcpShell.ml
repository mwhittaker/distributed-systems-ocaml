open Core.Std
open Async.Std

let sender _ r w =
  let stdin = Lazy.force Reader.stdin in
  don't_wait_for (Reader.transfer stdin (Writer.pipe w));
  don't_wait_for (Pipe.iter_without_pushback (Reader.pipe r) ~f:print_string);
  never ()

let main host port () : unit Deferred.t =
  ignore (Tcp.with_connection (Tcp.to_host_and_port host port) sender);
  never ()

let () =
  Command.async
    ~summary:"Redirect stdin over tcp"
    Command.Spec.(
      empty
      +> anon ("host" %: string)
      +> anon ("port" %: int)
    )
    main
  |> Command.run
