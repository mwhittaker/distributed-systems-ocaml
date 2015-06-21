open Core.Std
open Async.Std

module Lambda = struct
  type t =
    | Var    of string     (* x *)
    | Lambda of string * t (* lambda x. x + x *)
    | App    of t * t      (* (lambda x. x) (lambda x. x x) *)
  with sexp

  let rec to_string expr =
    match expr with
    | Var x -> x
    | Lambda (x, e) -> sprintf "(lambda %s. %s)" x (to_string e)
    | App (e1, e2) -> sprintf "%s %s" (to_string e1) (to_string e2)

  let get db k =
    let f s =
      t_of_sexp (Sexp.of_string s)
    in
    In_thread.run (fun () -> Option.map (LevelDB.get db k) ~f)

  let put db k v =
    In_thread.run (fun () -> LevelDB.put db k (Sexp.to_string (sexp_of_t v)))

  let put_all db kvs =
    Deferred.List.iter kvs ~f:(fun (k, v) -> put db k v)
end

let main () : unit Deferred.t =
  let open Lambda in

  let id = Lambda ("x", Var "x") in
  let small_omega = Lambda ("x", App (Var "x", Var "x")) in
  let big_omega = App (small_omega, small_omega) in

  let kvs = [
    ("id",    id);
    ("omega", small_omega);
    ("Omega", big_omega);
  ] in

  let db = LevelDB.open_db "/tmp/lambda" in
  put_all db kvs >>= fun () ->
  get db "id" >>= fun id ->
  get db "omega" >>= fun small_omega ->
  get db "Omega" >>= fun big_omega ->
  print_endline (Option.value (Option.map id ~f:to_string) ~default:"not found");
  print_endline (Option.value (Option.map small_omega ~f:to_string) ~default:"not found");
  print_endline (Option.value (Option.map big_omega ~f:to_string) ~default:"not found");
  LevelDB.close db;
  return ()

let () =
  Command.(run (async ~summary:"" Spec.empty main))
