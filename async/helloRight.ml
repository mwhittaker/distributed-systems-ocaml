(* Let's try our hello world program again. *)
open Core.Std
open Async.Std

let main () : unit =
  print_endline "hello world!"

let () =
  main ();
  (* This time, we'll start the scheduler with the following code. Go ahead and
   * run this program and see what happens. You'll see that "hello world!" is
   * printed to the screen. Yay! Unfortunately, the program won't terminate
   * after it prints "hello world"; instead, it will just sit there running
   * forever. The fact that this code invokes a function called never_returns
   * tells us the whole story: Scheduler.go never returns! This is a little
   * inconvenient. Does this mean that all our async programs will never
   * terminate? Not quite. Head over to the next program to see how to solve
   * this problem. *)
  never_returns (Scheduler.go ())
