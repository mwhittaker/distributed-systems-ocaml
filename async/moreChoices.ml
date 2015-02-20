open Core.Std
open Async.Std

module D = struct
  let both (a: 'a Deferred.t) (b: 'b Deferred.t) : ('a * 'b) Deferred.t =
   a >>= fun a ->
   b >>= fun b ->
   return (a, b)

  let all (ds: 'a Deferred.t list) : 'a list Deferred.t =
    List.fold_left (ds) ~init:(return []) ~f:(fun a d ->
      a >>= fun a ->
      d >>= fun x ->
      return (x::a)
    ) >>| List.rev

  let any (ds: 'a Deferred.t list) : 'a Deferred.t =
    let i = Ivar.create () in
    Deferred.List.iter ~how:`Parallel ds ~f:(fun d -> d >>| fun x -> Ivar.fill_if_empty i x)
    |> don't_wait_for;
    Ivar.read i
end

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
