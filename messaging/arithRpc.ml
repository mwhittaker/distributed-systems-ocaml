open Core.Std
open Async.Std

module Request = struct
  type t =
    | Succ  of int
    | Neg   of int
    | Plus  of int * int
    | Sub   of int * int
    | Times of int * int
    | Eq    of int * int
  with bin_io

  let to_string r =
    match r with
    | Succ   i     -> sprintf "Succ %d" i
    | Neg    i     -> sprintf "Neg %i" i
    | Plus  (i, j) -> sprintf "Plus (%d, %d)" i j
    | Sub   (i, j) -> sprintf "Sub (%d, %d)" i j
    | Times (i, j) -> sprintf "Times (%d, %d)" i j
    | Eq    (i, j) -> sprintf "Eq (%d, %d)" i j
end

module Response = struct
  type t =
    | Bool of bool
    | Int  of int
  with bin_io

  let to_string r =
    match r with
    | Bool b -> sprintf "Bool %B" b
    | Int i  -> sprintf "Int %d" i
end

let eval_rpc : (Request.t, Response.t) Rpc.Rpc.t =
  Rpc.Rpc.create ~name:"eval"
                 ~version:0
                 ~bin_query:Request.bin_t
                 ~bin_response:Response.bin_t
