(* To start our journey of learning async, let's write a very simple hello
 * world program! Since we're going to use code from the Core and Async
 * libraries, we'll open Core.Std and Async.Std. This is a very typical thing
 * to do and will appear in most or all of the files we're going to see. *)
open Core.Std
open Async.Std

(* Next, we'll write a main function that prints "hello world!". Pretty simple,
 * right? Now in OCaml, we don't really *need* to write a function named main.
 * When we compile and run programs, all top-level code will be executed, so
 * there's nothing special about this function being named main. We could have
 * named it foo or bar and the code would act just the same. But for the sake
 * of clarity, we'll typically create a function named main anyway. *)
let main () : unit =
  print_endline "hello world!"

(* Now, we run main! If you run this code, though, you'll notice something
 * strange! Namely, it doesn't print "hello world!". Hm, why doesn't our hello
 * world program print "hello world"!? Well, the real reason is a bit
 * complicated. When we opened Async.Std, we shadowed the definition of
 * print_endline found in the standard library with the async definition of
 * print_endline. Whenever we deal with async code, we need to make sure to
 * start the scheduler! Otherwise, nothing runs like we expect. Long story
 * short, don't forget to start the async scheduler! *)
let () =
  main ()
