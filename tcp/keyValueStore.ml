open Core.Std
open Async.Std

let store = Hashtbl.create ~hashable:String.hashable ()

let serve _ r w =
  let rec loop r w =
    Reader.read_line r >>= function
    | `Eof -> return ()
    | `Ok s -> begin
      match String.split ~on:' ' s with
      | ["GET"; k] -> begin
        match Hashtbl.find store k with
        | None -> (Writer.write_line w ("Error: key " ^ k ^ " not found"); loop r w)
        | Some v -> (Writer.write_line w v; loop r w)
      end
      | ["SET"; k; v] -> begin
        Hashtbl.replace store ~key:k ~data:v;
        Writer.write_line w "OK";
        loop r w
      end
      | _ -> (Writer.write_line w ("Error: invalid request " ^ s); loop r w)
    end
  in

  loop r w

let main () : unit Deferred.t =
  let port = 8080 in
  printf "listening on port %d\n" port;
  let where_to_listen = Tcp.on_port port in
  let _ = Tcp.Server.create where_to_listen serve in
  never ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
