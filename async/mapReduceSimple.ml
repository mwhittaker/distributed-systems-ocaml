open Core.Std
open Async.Std

let combine (kvs: ('k * 'v) list) : ('k * 'v list) list =
  let t = Hashtbl.Poly.create () in
  List.iter kvs ~f:(fun (k, v) ->
    match Hashtbl.Poly.find t k with
    | None -> Hashtbl.Poly.replace t ~key:k ~data:[v]
    | Some v' -> Hashtbl.Poly.replace t ~key:k ~data:(v::v')
  );
  Hashtbl.Poly.to_alist t

let map_reduce
    (kvs: ('k1 * 'v1) list)
    ~(map: 'k1 -> 'v1 -> ('k2 * 'v2) list)
    ~(reduce: 'k2 -> 'v2 list -> 'v2 list)
    : ('k2 * 'v2 list) list =
  List.map kvs ~f:(fun (k, v) -> map k v)
  |> List.concat
  |> combine
  |> List.map ~f:(fun (k, vs) -> (k, reduce k vs))

let main () : unit Deferred.t =
  let docs = [
    ("foo.ml", "hello my darling honey");
    ("bar.ml", "you are so nice too too too me");
  ] in

  let map _ s =
    List.map (String.split ~on:' ' s) ~f:(fun w -> (w, 1))
  in

  let reduce _ counts =
    [List.fold_left counts ~init:0 ~f:(+)]
  in

  let mr = map_reduce docs ~map ~reduce in
  List.iter mr ~f:(fun (w, counts) -> printf "%s: %d\n" w (List.fold_left counts ~init:0 ~f:(+)));
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
