open Core.Std
open Async.Std
open RedisParser
open RedisLexer
open RedisOp

let store = Hashtbl.create ~hashable:String.hashable ()

let parse (s: string) : op option =
  try Some (op token (Lexing.from_string s)) with _ -> None

let or_else (o: 'a option) (d: 'a) =
  match o with
  | None -> d
  | Some x -> x

let get k w =
  Writer.write_line w (or_else (Hashtbl.find store k) (k ^ " not found"))

let set k v w =
  Hashtbl.replace store ~key:k ~data:v;
  Writer.write_line w "OK"

let append k v' w =
  let v = or_else (Hashtbl.find store k) "" in
  Hashtbl.replace store ~key:k ~data:(v ^ v');
  Writer.write_line w "OK"

let strlen k w =
  match Hashtbl.find store k with
  | None -> Writer.write_line w "-1"
  | Some v -> Writer.write_line w (Int.to_string (String.length v))

let serve _ r w =
  let rec loop r w =
    Reader.read_line r >>= function
    | `Eof -> return ()
    | `Ok s ->
      (match (parse s) with
       | Some (Get k)         -> get k w
       | Some (Set (k, v))    -> set k v w
       | Some (Append (k, v)) -> append k v w
       | Some (Strlen k)      -> strlen k w
       | None                 -> Writer.write_line w ("Error: could not parse " ^ s));
      loop r w
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

