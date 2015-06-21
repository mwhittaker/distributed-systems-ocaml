(* sudo apt-get install g++ libleveldb-dev libsnappy-dev *)
open Core.Std
open Async.Std

let get db k =
  In_thread.run (fun () -> LevelDB.get db k)

let put db k v =
  In_thread.run (fun () -> LevelDB.put db k v)

let put_all db kvs =
  Deferred.List.iter kvs ~f:(fun (k, v) -> put db k v)

let main () : unit Deferred.t =
  let kvs = [
    ("one", "uno");
    ("two", "dos");
    ("three", "tres");
    ("four", "cuatro");
  ] in

  let db = LevelDB.open_db "/tmp/foo" in
  put_all db kvs >>= fun () ->
  get db "one" >>= fun v ->
  print_endline (Option.value v ~default:"not found");
  LevelDB.close db;
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
