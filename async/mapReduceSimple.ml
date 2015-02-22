open Core.Std
open Async.Std

let combine (kvs: ('k * 'v) list) : ('k * 'v list) list =
  let t = Hashtbl.Poly.create () in
  List.iter kvs ~f:(fun (k, v) ->
    match Hashtbl.Poly.find t k with
    | None    -> Hashtbl.Poly.replace t ~key:k ~data:[v]
    | Some v' -> Hashtbl.Poly.replace t ~key:k ~data:(v::v')
  );
  Hashtbl.Poly.to_alist t

type ('k1, 'v1)           input  = ('k1 * 'v1) list
type ('k1, 'v1, 'k2, 'v2) map    = ('k1 * 'v1)      -> ('k2 * 'v2) list Deferred.t
type ('k2, 'v2, 'k3, 'v3) reduce = ('k2 * 'v2 list) -> ('k3 * 'v3) Deferred.t
type ('k3, 'v3)           output = ('k3 * 'v3 list) list Deferred.t

let mapreduce
    ~(kvs:    ('k1, 'v1)           input)
    ~(map:    ('k1, 'v1, 'k2, 'v2) map)
    ~(reduce: ('k2, 'v2, 'k3, 'v3) reduce)
    : ('k3, 'v3) output =
  Deferred.List.map ~how:`Parallel kvs ~f:(map) >>= fun kvs ->
  let kvs = combine (List.concat kvs) in
  Deferred.List.map ~how:`Parallel kvs ~f:(reduce) >>= fun kvs ->
  return (combine kvs)

module WordCount = struct
  let map (_, s) =
    return (List.map (String.split ~on:' ' s) ~f:(fun w -> (w, 1)))

  let reduce (w, counts) =
    return (w, List.fold_left counts ~init:0 ~f:(+))
end

let word_count () : unit Deferred.t =
  let open WordCount in
  let docs = [
    ("hello.txt", "hello hello hello");
    ("shake.txt", "to be or not to be that is the question");
  ] in
  mapreduce ~kvs:docs ~map ~reduce >>| fun kvs ->
  List.iter kvs ~f:(fun (w, c) ->
    match c with
    | [c] -> printf "%s: %d\n" w c
    | _   -> failwith "impossible")

module Grep = struct
  let map (pattern, s) =
    let words = String.split ~on:' ' s in
    return (if List.mem words pattern then [s, ()] else [])

  let reduce (s, _) =
    return (s, ())
end

let grep () : unit Deferred.t =
  let open Grep in
  let strings = [
    "";
    "hello there";
    "foo bar baz";
    "foo foo foo";
    "well hello there";
  ] in
  let pattern = "foo" in
  let kvs = List.map strings ~f:(fun s -> (pattern, s)) in
  mapreduce ~kvs ~map ~reduce >>| fun kvs ->
  List.iter kvs ~f:(fun (s, _) -> print_endline s)

let main () : unit Deferred.t =
  word_count () >>= fun () ->
  print_endline "";
  grep () >>= fun () ->
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
