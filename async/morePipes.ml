(* In this program, we'll use pipes in more advanced and more interesting ways.
 *)
open Core.Std
open Async.Std

(* Imagine we have two pipes: a and b. Someone is writing colors into pipe a
 * and fruits into pipe b. When we read from pipe a, we get the colors, and
 * when we read from pipe b, we get the fruits.
 *
 *   read a (* blue *)
 *   read a (* red *)
 *   read b (* bananas *)
 *   read b (* strawberries *)
 *
 * Now imagine we want to make a single pipe c. Whenever we read from c, we
 * want to get either a color from a or a fruit from b. That's exactly what the
 * interleave function does! It takes in a list of readers and returns a single
 * reader that yields values read from any of the input readers. So if we used
 * interleave to generate c, here's what the reads might look like.
 *
 *   let c = interleave [a; b]
 *   read c (* blue *)
 *   read c (* bananas *)
 *   read c (* strawberries *)
 *   read c (* red *)
 *
 * In terms of implementation, all we do is create a fresh pipe and then
 * transfer the input readers into it. We also have to make sure to close the
 * interleaved pipe when all the input pipes are closed.
 *)
let interleave (rs: 'a Pipe.Reader.t list) : 'a Pipe.Reader.t =
  let (r, w) = Pipe.create () in
  begin
    Deferred.List.iter ~how:`Parallel rs ~f:(fun r -> Pipe.transfer_id r w) >>> fun () ->
    Pipe.close w
  end;
  r

(* Here, we show off how to use interleave. We create 10 pipes and write into
 * each one. Then we interleave the pipes into a single reader and read all the
 * values from it. *)
let pipe_interleave () : unit Deferred.t =
  let (rs, ws) = List.(unzip (map (range 0 10) ~f:(fun _ -> Pipe.create ()))) in
  List.iteri ws ~f:(fun i w -> don't_wait_for (Pipe.write w i >>| fun () -> Pipe.close w));
  let r = interleave rs in
  Pipe.iter r ~f:(fun i -> return (printf "read %d\n" i))

(* With interleave, we took a set of pipes and interleaved them into a single
 * pipe. Here, we do the exact opposite. We take a single pipe and replicate
 * its output to a whole set of pipes. We simply iterate over the input pipe
 * and write the contents to every one of the output pipes. We also make sure
 * to close all the output pipes once the input pipe has closed. *)
let broadcast (r: 'a Pipe.Reader.t) (ws: 'a Pipe.Writer.t list) : unit Deferred.t =
  Pipe.iter r ~f:(fun x -> Deferred.all_unit (List.map ws ~f:(fun w -> Pipe.write w x)))
  >>| fun () -> List.iter ws ~f:Pipe.close

(* Here, we show off how to use broadcast. We create a pipe and write "fee",
 * "fi", "fo", and "fum" into it. Then, we broadcast it into 10 pipes. *)
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

(* Interleave let a bunch of pipes converge into a single pipe. If we imagine
 * data flowing through pipes from left to right, interleave looked like this:
 *   __
 *     \
 *      \
 *   ---->----
 *      /
 *   __/
 *
 * And broadcast let a single pipe replicate its output to a whole set of
 * pipes. It looked like this:
 *          __
 *         /
 *        /
 *   ----<----
 *        \
 *         \__
 *
 * Now, we'll implement code that let's a whole set of producers (which we'll
 * call publishers) broadcast data to a whole set of consumers (which we'll
 * call subscribers). It looks like this:
 *
 *   publisher a  __          __ subscriber a
 *                  \        /
 *                   \      /
 *   publisher b  ---->----<---- subscriber b
 *                   /      \
 *                __/        \__ subscriber c
 *   publisher c
 *
 * Our publisher/subscriber service will be encapsulate by an instance of type
 * PubSub.t. Any publisher can publish a value by calling pub. For example, if
 * I wanted to publish the string "foo" to a pub/sub instance ps, I would call
 * `PubSub.pub sp "foo"`. Whenever a message is published, it is broadcasted to
 * all the subscribers. In order to become a subscriber, you call `PubSub.sub`.
 * This returns the reader end of a pipe from which you can read published
 * values. There's also a function close which closes all the subscribers'
 * pipes. *)
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

(* Here's a demo of our pub/sub service! *)
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
