open Core.Std
open Async.Std

let to_string_rpc : (int, string) Rpc.Rpc.t =
  Rpc.Rpc.create ~name:"to_string"
                 ~version:0
                 ~bin_query:Int.bin_t
                 ~bin_response:String.bin_t
