open Core.Std
open Async.Std

let interleave (rs: 'a Pipe.Reader.t list) : 'a Pipe.Reader.t =
  let (r, w) = Pipe.create () in
  begin
    Deferred.List.iter ~how:`Parallel rs ~f:(fun r -> Pipe.transfer_id r w) >>> fun () ->
    Pipe.close w
  end;
  r

let pipe_interleave () : unit Deferred.t =
  let (rs, ws) = List.(unzip (map (range 0 10) ~f:(fun _ -> Pipe.create ()))) in
  List.iteri ws ~f:(fun i w -> don't_wait_for (Pipe.write w i >>| fun () -> Pipe.close w));
  let r = interleave rs in
  Pipe.iter r ~f:(fun i -> return (printf "read %d\n" i))

let rec iter_and_close
    (r: 'a Pipe.Reader.t)
    ~(f: 'a -> unit Deferred.t)
    ~(onclose: unit -> unit Deferred.t)
    : unit Deferred.t =
  Pipe.read r >>= function
  | `Eof  -> onclose ()
  | `Ok x -> f x >>= fun () -> iter_and_close r ~f ~onclose

let broadcast (r: 'a Pipe.Reader.t) (ws: 'a Pipe.Writer.t list) : unit Deferred.t =
  iter_and_close r
    ~f:(fun x -> Deferred.all_unit (List.map ws ~f:(fun w -> Pipe.write w x)))
    ~onclose:(fun () -> return (List.iter ws ~f:Pipe.close))

let pipe_broadcast () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  let (rs, ws) = List.(unzip (map (range 0 10) ~f:(fun _ -> Pipe.create ()))) in
  don't_wait_for (broadcast r ws);
  don't_wait_for (Pipe.write w "fee");
  don't_wait_for (Pipe.write w "fi");
  don't_wait_for (Pipe.write w "fo");
  don't_wait_for (Pipe.write w "fum");
  Pipe.close w;
  Deferred.List.iteri ~how:`Parallel rs ~f:(fun i r ->
    Pipe.iter r ~f:(fun s -> return (printf "%d: %s\n" i s)))

module PubSub = struct
  type 'a t = 'a Pipe.Writer.t list ref

  let create () : 'a t =
    ref []

  let pub (subs: 'a t) (x: 'a) : unit Deferred.t =
    Deferred.List.iter ~how:`Parallel !subs ~f:(fun w -> Pipe.write w x)

  let sub (subs: 'a t) : 'a Pipe.Reader.t =
    let (r, w) = Pipe.create () in
    subs := w::!subs;
    r

  let close (subs: 'a t) : unit =
    List.iter !subs ~f:(Pipe.close)
end

let pipe_pub_sub () : unit Deferred.t =
  let open PubSub in
  let ps = create () in
  don't_wait_for (pub ps "negative one");
  let r0 = sub ps in
  don't_wait_for (pub ps "zero");
  let r1 = sub ps in
  don't_wait_for (pub ps "one");
  let r2 = sub ps in
  don't_wait_for (pub ps "two");
  let r3 = sub ps in
  close ps;
  let subs = [r0; r1; r2; r3] in
  Deferred.List.iteri subs ~f:(fun i r -> Pipe.iter r ~f:(fun x -> return (printf "%d: %s\n" i x)))

let main () : unit Deferred.t =
  pipe_interleave () >>= fun () ->
  pipe_broadcast () >>= fun () ->
  pipe_pub_sub () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
