(* In this program, we'll explore ivars. Ivars are very low-level async
 * primitive that you seldom use. Often, you can solve all your async problems
 * with deferreds and bind, but at times ivars become useful or even necessary.
 *
 * Recall that I like to think of deferreds as cardboard boxes that are full
 * with some value when determined and empty otherwise. Up until now, whenever
 * we've gotten our hands on a deferred, we've never been the ones to determine
 * it and put the value in the box. For example, the deferred (after (sec 1.0))
 * is determined after 1 second, but not by us! We never write the code which
 * actually determines the value of the deferred. Well now we can with the
 * power of ivars.
 *
 * Dealing with ivars boils to down to a handful of functions.
 *
 *   1. Ivar.create creates a brand new ivar.
 *   2. Ivar.read i creates a deferred from an ivar.
 *   3. Ivar.fill i x fills in any deferreds produced by Ivar.read.
 *)
open Core.Std
open Async.Std

(* In this function, we create an ivar i. Then, we schedule the ivar to be
 * filled with the string "hello" after 1 second. We then take the deferred d
 * read from i and map it into print_endline. After 1 second, this function
 * will print "hello". *)
let basics () : unit Deferred.t =
  let i = Ivar.create () in
  don't_wait_for (after (sec 1.0) >>| fun () -> Ivar.fill i "hello");
  let d = Ivar.read i in
  d >>| print_endline

(* What happens if we try to fill an ivar twice? Uncomment the following code
 * and try for yourself. The code creates an ivar and schedules for it to be
 * filled with "ocaml" after 1 second and with "haskell" after 2 seconds. It
 * then maps the deferred read from the ivar into print_endline. After 1
 * second, the ivar is filled and the deferred becomes determined. At this
 * point, "ocaml" is printed to the screen. A second later though, we attempt
 * to fill the ivar with "haskell", but the ivar is already filled and our
 * program crashes.
 *
 * The moral of the story is to never fill an ivar more than once! *)
let choices_fill () : unit Deferred.t =
  (*
  let i = Ivar.create () in
  don't_wait_for (Deferred.all_unit [
    (after (sec 2.) >>| fun () -> Ivar.fill i "haskell");
    (after (sec 1.) >>| fun () -> Ivar.fill i "ocaml");
  ]);
  Ivar.read i >>= fun s ->
  print_endline s;
  *)
  return ()

(* Luckily, it's easy to avoid filling an ivar more than once. We simply have
 * to use Ivar.fill_if_empty instead of Ivar.fill. *)
let choices_fill_if_empty () : unit Deferred.t =
  let i = Ivar.create () in
  don't_wait_for (Deferred.all_unit [
    (after (sec 2.) >>| fun () -> Ivar.fill_if_empty i "idris");
    (after (sec 1.) >>| fun () -> Ivar.fill_if_empty i "coq");
  ]);
  Ivar.read i >>| print_endline

let main () : unit Deferred.t =
  basics () >>= fun () ->
  choices_fill () >>= fun () ->
  choices_fill_if_empty () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
