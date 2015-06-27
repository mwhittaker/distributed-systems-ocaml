(* Previously in choices.ml, we introduced ourselves to a bunch of very useful
 * functions that let us choose from a set of deferreds. Now that we've had
 * more experience, we're going to implement some of these functions! *)
open Core.Std
open Async.Std

module D = struct
  (* First up, both. Recall from earlier that we can think of binds as let
   * expressions. If we make this mental substitution, we get the following
   * code:
   *
   *   let a = a in
   *   let b = b in
   *   (a, b)
   *
   * Pretty simple, huh? *)
  let both (a: 'a Deferred.t) (b: 'b Deferred.t) : ('a * 'b) Deferred.t =
   a >>= fun a ->
   b >>= fun b ->
   return (a, b)

  (* Next up, all. Like with both, we can generally ignore the fact that we're
   * dealing with deferreds and think of the code as if it were full of let
   * expressions instead of binds.
   *
   *   let all ds =
   *     List.fold_left ds ~init:[] ~f:(fun a d ->
   *       let a = a in
   *       let x = d in
   *       x::a
   *     ) |> List.rev
   *)
  let all (ds: 'a Deferred.t list) : 'a list Deferred.t =
    List.fold_left (ds) ~init:(return []) ~f:(fun a d ->
      a >>= fun a ->
      d >>= fun x ->
      return (x::a)
    ) >>| List.rev

  (* any is the trickiest of the bunch. If we limit ourselves to using only
   * binds, we get stuck. Instead, we have to use ivars. First, we read off an
   * empty deferred from a fresh ivar. Then, we iterate over the list of
   * deferreds and register them to fill the ivar whenever they become
   * determined. The deferreds are all racing to fill in the ivar, and the
   * first one to become determined gets to fill the ivar which in turn
   * determines the deferred read from it. *)
  let any (ds: 'a Deferred.t list) : 'a Deferred.t =
    let i = Ivar.create () in
    Deferred.List.iter ~how:`Parallel ds ~f:(fun d -> d >>| fun x -> Ivar.fill_if_empty i x)
    |> don't_wait_for;
    Ivar.read i
end

(* Here, we repeat the code from choice.ml, but we use our implementations
 * instead. *)
let delayed (t: float) (x: 'a) : 'a Deferred.t =
  after (sec t) >>= fun () ->
  return x

let def_both () : unit Deferred.t =
  D.both (delayed 1. "hello") (delayed 0.5 42) >>| fun (a, b) ->
  printf "%s, %d\n" a b

let def_all () : unit Deferred.t =
  D.all [delayed 0.5 "hello"; delayed 1. "world"; delayed 1.5 "!"] >>| fun l ->
  List.iter l ~f:(print_endline)

let def_any () : unit Deferred.t =
  D.any [delayed 1.0 "slow!"; delayed 0.5 "fast!"] >>| print_endline

let main () : unit Deferred.t =
  def_both () >>= fun () ->
  def_all () >>= fun () ->
  def_any () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
