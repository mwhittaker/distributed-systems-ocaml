open Core.Std
open Async.Std

let stdin_to_diary (w: Writer.t) : unit Deferred.t =
  let stdin = Lazy.force Reader.stdin in
  Reader.transfer stdin (Writer.pipe w)

let main filename () : unit Deferred.t =
  Writer.with_file ~append:true filename ~f:stdin_to_diary

let () =
  Command.async
    ~summary:"Enter an entry in a diary."
    Command.Spec.(empty +> anon ("filename" %: string))
    main
  |> Command.run
