open Core.Std
open Async.Std

let sum123 () : unit Deferred.t =
  Deferred.bind (return 1) (fun x ->
  Deferred.bind (return 2) (fun y ->
  Deferred.bind (return 3) (fun z ->
  printf "1 + 2 + 3 = %d\n" (x + y + z);
  return ()
  )))

let sum456 () : unit Deferred.t =
  return 4 >>= (fun x ->
  return 5 >>= (fun y ->
  return 6 >>= (fun z ->
  printf "4 + 5 + 6 = %d\n" (x + y + z);
  return ())))

let sum789 () : unit Deferred.t =
  return 7 >>= fun x ->
  return 8 >>= fun y ->
  return 9 >>= fun z ->
  printf "7 + 8 + 9 = %d\n" (x + y + z);
  return ()

let sum111 () : unit Deferred.t =
  return 1 >>= fun x ->
  return 1 >>= fun y ->
  return 1 >>| fun z ->
  printf "1 + 1 + 1 = %d\n" (x + y + z)

let sum222 () : unit Deferred.t =
  (*
  return 2 >>| fun x ->
  return 2 >>| fun y ->
  return 2 >>| fun z ->
  printf "2 + 2 + 2 = %d\n" (x + y + z)
  *)
  return ()

let main () : unit Deferred.t =
  sum123 () >>= fun () ->
  sum456 () >>= fun () ->
  sum789 () >>= fun () ->
  sum111 () >>= fun () ->
  sum222 () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"basic async" Spec.empty main))
