(* Now that we've seen deferreds, return, bind, and map, let's dive into some
 * more advanced ways of interacting with deferreds. In particular, we'll see
 * how to wait for a set of deferreds to become determined or wait for one of
 * many deferreds to become determined. *)
open Core.Std
open Async.Std

(* Before we get into choosing from a set of deferreds, let's explore how to
 * create deferreds that don't become determined for a while. We've seen that
 * we can use return to create a deferred that is immediately determined. We
 * can use after and sec to create a deferred that becomes determined after a
 * while.
 *
 * The sec function creates a time span in seconds. For example, `sec 1.`
 * represents a 1 second time span. The after function takes in a timespan t
 * and evaluates to a unit deferred that is determined after t has ended.
 *
 * This function will print 1 after 1 second, 2 after 2 seconds, and 3 after 3
 * seconds.
 *)
let time () : unit Deferred.t =
  after (sec 1.) >>= fun () -> printf "%d\n" 1;
  after (sec 1.) >>= fun () -> printf "%d\n" 2;
  after (sec 1.) >>| fun () -> printf "%d\n" 3

(* We can use after and sec to create a helper function delayed that evaluates
 * to a deferred which becomes determined with some value after some time. For
 * example, `delayed 1.2 "hello"` evaluates a deferred that after 1.2 seconds
 * becomes determined with the string "hello". *)
let delayed (t: float) (x: 'a) : 'a Deferred.t =
  after (sec t) >>= fun () ->
  return x

(* Now that we can create delayed deferreds with our delayed function, we can
 * start choosing from a set of deferreds. First up, Deferred.all. Deferred.all
 * takes in a list of deferreds (i.e. 'a Deferred.t list), and returns a single
 * list that is deferred (i.e. 'a list Deferred.t). Once every deferred in the
 * input list becomes determined, the output list also becomes determined, and
 * it contains all the values of the input list.
 *
 * For example, this function creates a list with three deferreds. The first
 * becomes determined after 0.5 seconds. The second becomes determined after 1
 * second, and the last becomes determined after 1.5 seconds. After 1.5 seconds
 * of calling Deferred.all, all three deferreds will have been determined, and
 * the output list will become determined with the value ["hello"; "world";
 * "!"]. *)
let def_all () : unit Deferred.t =
  Deferred.all [delayed 0.5 "hello"; delayed 1. "world"; delayed 1.5 "!"] >>| fun l ->
  List.iter l ~f:(print_endline)

(* Deferred.all_unit is similar to Deferred.all, except it only accepts a list
 * of unit deferreds, and instead of returning a deferred list of units, it
 * simple returns a unit deferred. When we run this code, "hello" will print
 * after 0.5 seconds, "world" will print after 1 second, and "!" will print
 * after 1.5 seconds. *)
let def_all_unit () : unit Deferred.t =
  Deferred.all_unit [
    (after (sec 0.5) >>| fun () -> print_endline "hello");
    (after (sec 1.0) >>| fun () -> print_endline "world");
    (after (sec 1.5) >>| fun () -> print_endline "!");
  ]

(* Whereas Deferred.all returned a deferred that became determined with *every*
 * value in a list of deferreds, Deferred.any returns a deferred that is
 * determined with the *first* value in a list of deferreds that becomes
 * determined.
 *
 * In this code, we create a list of two deferreds. The "fast!" deferred
 * becomes determined after half a second, and the "slow!" deferred becomes
 * determined after one second. Since the "fast!" deferred becomes determined
 * first, the deferred returned by our call to Deferred.any will evaluate to
 * "fast!". *)
let def_any () : unit Deferred.t =
  Deferred.any [delayed 0.5 "fast!"; delayed 1.0 "slow!"] >>| print_endline

(* Deferred.all_unit is to Deferred.all as Deferred.any_unit is to
 * Deferred.any. Expectedly, this code will return a unit deferred that is
 * determined after 0.5 seconds when the "fast" deferred is determined. Perhaps
 * unexpectedly, "slow" and "slowest" may still be printed!
 *
 * Why is that?
 *
 * Here, it's good to remember that >>| and >>= register functions to be called
 * when certain deferreds become determined. When we evaluate this code, we
 * first evaluate the list, which contains three elements. Each element is the
 * evaluation of an invocation to >>|, so all three print_endlines are
 * registered. Even after 0.5 seconds when "fast" is printed and the deferred
 * returned by def_any_unit becomes determined, the print_endline "slow" and
 * print_endline "slowest" functions are still registered and waiting to go. So
 * depending on how much time remains after this function is called and when
 * the program terminates, "slow" and "slowest" may or may not be printed!
 *
 * You can try experimenting with this by removing the invocation of def_both
 * in the main function below and see how it affects whether or not "slow" and
 * "slowest" are printed. *)
let def_any_unit () =
  Deferred.any_unit [
    (after (sec 0.5) >>| fun () -> print_endline "fast");
    (after (sec 1.0) >>| fun () -> print_endline "slow");
    (after (sec 1.5) >>| fun () -> print_endline "slowest");
  ]

(* Deferred.both a b acts the same as Deferred.all [a; b] but returns a tuple
 * instead of a list. *)
let def_both () : unit Deferred.t =
  Deferred.both (delayed 1. "hello") (delayed 0.5 42) >>| fun (a, b) ->
  printf "%s, %d\n" a b

let main () : unit Deferred.t =
  time () >>= fun () ->
  def_all () >>= fun () ->
  def_all_unit () >>= fun () ->
  def_any () >>= fun () ->
  def_any_unit () >>= fun () ->
  def_both () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
