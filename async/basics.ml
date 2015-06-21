(* Now that we've written a hello world program, let's dive into some more
 * meaty async code. Hopefully, most of this should be familiar to you after reading
 * Chapter 18 of Real World OCaml. *)
open Core.Std
open Async.Std

(* First up, let's play with deferreds and bind. An 'a Deferred.t (or
 * colloquially, an 'a deferred) represents a value of type 'a that may or may
 * not yet be determined. For example, consider calling a function
 * read_line_from_stdin that reads a line from the user and returns a string
 * deferred. When you call read_line_from_stdin and get a string deferred, the
 * deferred may or may not yet be determined. If the user hasn't typed in
 * anything yet, then the string deferred hasn't yet been determined. Once the
 * user types something in, the string becomes determined.
 *
 * So how do we program with deferreds if they may not even be determined when
 * we get them? The answer is bind. bind takes in an 'a deferred and a function
 * f from 'a deferred to 'b deferred and returns a 'b deferred. bind will wait
 * for the 'a deferred to become determined, then unwrap the 'a and pass it to
 * f to get a 'b deferred.
 *
 * We can also chain together a sequence of binds, like with the code below.
 * This function calls bind with two arguments. The first is (return 1), which
 * is an int deferred. The second is the very big function (fun x -> ... return
 * ()))), which is a function from int deferred to unit deferred. When (return
 * 1) becomes determined, the 1 is unwrapped and the very big function is
 * called with x bound to 1. This very big function calls bind again with two
 * arguments. The first is return 2 and the second is another fairly big
 * function (fun y -> ... return ())). Again, when (return 2) becomes
 * determined, the 2 is unwrapped and passed into the fairly big function such
 * that y is bound to 2. This pattern continues a third time after which z is
 * bound to 3. And finally, we run the code which prints the sum of x, y, and z
 * and then return ().
 *
 * Phew! For summing up three numbers, that's quite a bit of code to think
 * about. Well, while it's nice to know that in reality bind is scheduling
 * functions to run when deferreds become determined, we can alternatively
 * ignore all this and consider a simpler way of thinking about bind and
 * deferreds. Whenever you see code of the form `Deferred.bind d (fun x -> e)`,
 * you can think about the code as the following: `let x = (unwrap d) in e`.
 * That is, whenever you see a deferred being bound to a function, just imagine
 * instead you unwrap the value of the deferred and bind it to argument of
 * function directly using a let expression. If we think of async code like
 * this, then the following function would look something like this:
 *
 *     let x = 1 in
 *     let y = 2 in
 *     let z = 3 in
 *     printf "1 + 2 + 3 = %d\n" (x + y + z);
 *
 * This code is pretty simple. A key to grokking with async code is knowing
 * when to think of binds as scheduling functions to be run deferreds become
 * determined, and when to ignore all that and just think of binds as let
 * expressions.
 *)
let sum123 () : unit Deferred.t =
  Deferred.bind (return 1) (fun x ->
  Deferred.bind (return 2) (fun y ->
  Deferred.bind (return 3) (fun z ->
  printf "1 + 2 + 3 = %d\n" (x + y + z);
  return ()
  )))

(* There's also an infix operator >>= that works exactly the same way as
 * Deferred.bind. The following function works exactly the same as the previous
 * one. *)
let sum456 () : unit Deferred.t =
  return 4 >>= (fun x ->
  return 5 >>= (fun y ->
  return 6 >>= (fun z ->
  printf "4 + 5 + 6 = %d\n" (x + y + z);
  return ())))

(* The benefit of using >>= over Deferred.bind is that we can remove a lot of
 * the parentheses we needed before! This function does exactly the same thing
 * that the previous two functions did! *)
let sum789 () : unit Deferred.t =
  return 7 >>= fun x ->
  return 8 >>= fun y ->
  return 9 >>= fun z ->
  printf "7 + 8 + 9 = %d\n" (x + y + z);
  return ()

(* Recall that the type of bind is 'a Deferred.t -> ('a -> 'b Deferred.t) -> 'b
 * Deferred.t. In the previous three functions, 'a was instantiated with int,
 * 'b was instantiated with unit. Thus, the functions were binding into had to
 * return a unit deferred. This is why we ended the functions with return ().
 * We can save some keystrokes by instead using >>| which has the type 'a
 * Deferred.t ('a -> 'b) -> 'b Deferred.t. >>| (pronounced map) acts pretty
 * much the same as bind except the function you map into returns a normal 'b
 * instead of a 'b deferred. You could easily implement >>| using >>= like this:
 *
 *     let (>>|) deferred f =
 *       deferred >>= (fun x -> return (f x))
 *
 * Since printf returns a unit, we can change our last bind to a map and avoid
 * having to return (). *)
let sum111 () : unit Deferred.t =
  return 1 >>= fun x ->
  return 1 >>= fun y ->
  return 1 >>| fun z ->
  printf "1 + 1 + 1 = %d\n" (x + y + z)

(* However, we can't always swap out >>= for >>|. For example, uncomment the
 * following code and try to build this program. You'll get an error that this
 * function returns something of type unit Deferred.t Deferred.t Deferred.t but
 * was expecting something of type unit Deferred.t! What happened? Well
 * remember that >>| takes in a function from 'a to 'b, and returns the output
 * to make a 'b deferred. printf returns a () and since we have three
 * occurrences of >>|, each one adds a layer of deferred to make a unit
 * Deferred.t Deferred.t Deferred.t!
 *
 * In general, avoid chaining together lambdas with >>| and instead stick with
 * >>=. *)
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
