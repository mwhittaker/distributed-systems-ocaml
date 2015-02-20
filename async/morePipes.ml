open Core.Std
open Async.Std

let broadcast (inpipe: 'a Pipe.Reader.t) (outpipes: 'a Pipe.Writer.t list) : unit Deferred.t =
  let write_all pipes x =
    Deferred.List.all_unit (List.map pipes ~f:(fun p -> Pipe.write p x))
  in
  Pipe.iter inpipe ~f:(fun x -> write_all outpipes x)

let pipe_broadcast () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  let (rs, ws) = List.(unzip (map (range 0 10) ~f:(fun _ -> Pipe.create ()))) in
  don't_wait_for (broadcast r ws);
  don't_wait_for (Pipe.write w 1);
  Deferred.List.all (List.map rs ~f:Pipe.read) >>| fun ones ->
  List.iter ones ~f:(fun res ->
    match res with
    | `Eof -> printf "`Eof\n"
    | `Ok i -> printf "%d\n" i)

let main () : unit Deferred.t =
  pipe_broadcast () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
