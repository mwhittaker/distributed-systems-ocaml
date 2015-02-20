open Core.Std
open Async.Std

let write_then_read () : unit Deferred.t =
  (*
  let (r, w) = Pipe.create () in
  Pipe.write w 42 >>= fun () ->
  Pipe.read r >>= function
  | `Eof  -> failwith "impossible"
  | `Ok x -> printf "x = %d\n" x;
  *)
  return ()

let write_and_read () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  don't_wait_for (Pipe.write w 42);
  Pipe.read r >>| function
  | `Eof  -> failwith "impossible"
  | `Ok y -> printf "y = %d\n" y

let write_without_pushback_then_read () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  Pipe.write_without_pushback w 42;
  Pipe.read r >>| function
  | `Eof  -> failwith "impossible"
  | `Ok z -> printf "z = %d\n" z

let pipe_fold () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  List.iter (List.range 0 10) ~f:(fun i -> don't_wait_for (Pipe.write w i));
  Pipe.close w;
  Pipe.fold r ~init:0 ~f:(fun a i -> return (a + i)) >>| fun sum ->
  printf "sum is %d\n" sum

let pipe_iter () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  List.iter (List.range 0 10) ~f:(fun i -> don't_wait_for (Pipe.write w i));
  Pipe.close w;
  Pipe.iter r ~f:(fun i -> return (printf "read %d\n" i))

let pipe_transfer () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  let (r', w') = Pipe.create () in
  don't_wait_for (Pipe.write w 42);
  don't_wait_for (Pipe.transfer r w' ~f:(succ));
  Pipe.read r' >>| function
  | `Eof  -> failwith "impossible"
  | `Ok a -> printf "a = %d\n" a

let pipe_interleave () : unit Deferred.t =
  let (rs, ws) = List.(unzip (map (range 0 10) ~f:(fun _ -> Pipe.create ()))) in
  List.iteri ws ~f:(fun i w -> don't_wait_for (Pipe.write w i >>| fun () -> Pipe.close w));
  let r = Pipe.interleave rs in
  Pipe.iter r ~f:(fun i -> return (printf "read %d\n" i))

let main () : unit Deferred.t =
  write_then_read () >>= fun () ->
  write_and_read () >>= fun () ->
  write_without_pushback_then_read () >>= fun () ->
  pipe_fold () >>= fun () ->
  pipe_iter () >>= fun () ->
  pipe_transfer () >>= fun () ->
  pipe_interleave () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))