open Core.Std

module Request = struct
  type t =
    | Succ  of int
    | Neg   of int
    | Plus  of int * int
    | Sub   of int * int
    | Times of int * int
    | Eq    of int * int

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

  let to_string r =
    match r with
    | Bool b -> sprintf "Bool %B" b
    | Int i  -> sprintf "Int %d" i
end
