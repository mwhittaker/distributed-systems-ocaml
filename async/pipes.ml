(* In this program, we'll explore another core aysnc data structure: the pipe.
 * Pipes are essentially asynchronous queues. You can write to one end of the
 * pipe and read from the other end of the pipe. Pipes are great for performing
 * message passing concurrency and are very similar to channels from the
 * programming languages like go and rust. *)
open Core.Std
open Async.Std

(* The pipe interface is very simple. First, we create a pipe with Pipe.create.
 * This returns the reader and writer ends of the pipe. Then, we can write to
 * the writer end of the pipe with Pipe.write and read from the reader end of
 * the pipe with Pipe.read.
 *
 * Try uncommenting the following code and run this program. You'll find the
 * code never terminates! Turns out Pipe.write returns a deferred that isn't
 * determined until the pipe is ready to be written to again or until the pipe
 * is closed. Since, we've sequenced our read after our write, this code hangs
 * forever. *)
let write_then_read () : unit Deferred.t =
  (*
  let (r, w) = Pipe.create () in
  Pipe.write w 42 >>= fun () ->
  Pipe.read r >>= function
  | `Eof  -> failwith "impossible"
  | `Ok x -> printf "x = %d\n" x;
  *)
  return ()

(* To fix this problem, we simply don't sequence our read to happen strictly
 * after our write. We can do so by not waiting for the write using the
 * don't_wait_for function. Now when we run this code, it'll print "y = 42". *)
let write_and_read () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  don't_wait_for (Pipe.write w 42);
  Pipe.read r >>| function
  | `Eof  -> failwith "impossible"
  | `Ok y -> printf "y = %d\n" y

(* Alternatively, we can replace `don't_wait_for (Pipe.write w 42)` with
 * `Pipe.write_without_pushback w 42`*)
let write_without_pushback_then_read () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  Pipe.write_without_pushback w 42;
  Pipe.read r >>| function
  | `Eof  -> failwith "impossible"
  | `Ok z -> printf "z = %d\n" z

(* Pipes, like lists, can also be folded across. *)
let pipe_fold () : unit Deferred.t =
  let r = Pipe.of_list (List.range 0 10) in
  Pipe.fold r ~init:0 ~f:(fun a i -> return (a + i)) >>| fun sum ->
  printf "sum is %d\n" sum

(* Or, itered across. *)
let pipe_iter () : unit Deferred.t =
  let r = Pipe.of_list (List.range 0 10) in
  Pipe.iter r ~f:(fun i -> return (printf "read %d\n" i))

(* We can also connect the reader end of one pipe into the writer end of
 * another pipe using Pipe.transfer. Here, we create two reader/writer pairs
 * (r, w) and (r', w'). We hook up the first pipe into the second and increment
 * the values flowing from the first into the second. We then write 42 into the
 * first pipe and read it out of the second. *)
let pipe_transfer () : unit Deferred.t =
  let (r, w) = Pipe.create () in
  let (r', w') = Pipe.create () in
  don't_wait_for (Pipe.write w 42);
  don't_wait_for (Pipe.transfer r w' ~f:(succ));
  Pipe.read r' >>| function
  | `Eof  -> failwith "impossible"
  | `Ok a -> printf "a = %d\n" a

(* While we use Pipe.transfer to funnel one pipe into another, we can use
 * Pipe.interleave to funnel a whole list of pipes into a single pipe. Here, we
 * create 10 pipes. We write 0 into the zeroth pipe, 1 into the first pipe,
 * etc. Then we interleave the readers of all these pipes into a single reader
 * r. Finally, we iterate over `r` and print out the values we see. *)
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
