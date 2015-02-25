open Core.Std
open Async.Std

(* Directories with a [doc.odocl] file. *)
let dirs = [
  "async";
  "readwrite";
  "tcp";
  "http";
]

(* Paths to the [doc.odocl] files. *)
let odocls = List.map dirs ~f:(sprintf "../%s/doc.odocl")

(* Template file *)
let template = "template.txt"

let cat (strings: string list) : string =
  String.concat ~sep:"\n" strings

(* [parse_odocl odocl] parses [odocl], a [doc.odocl] file into an ocamldoc
 * formatted list. For example, if [odocl] were the following:
 *
 *     HelloWorld
 *     GoodBye
 *     Foo
 *
 * then, [parse_odocl odocl] would return the following:
 *
 *     {ol
 *       {- {{:code_HelloWorld.html} [HelloWorld]}}
 *       {- {{:code_GoodBye.html} [GoodBye]}}
 *       {- {{:code_Foo.html} [Foo]}}
 *     }
 *)
let parse_odocl (odocl: string) : string Deferred.t =
  let format_line line =
    sprintf "  {- {{:code_%s.html} [%s]}}" line line
  in

  Reader.with_file odocl ~f:(fun r ->
    Reader.lines r
    |> Pipe.map ~f:format_line
    |> Pipe.to_list >>| fun lines ->
    sprintf "{ol\n%s\n}" (cat lines)
  )

(* [write_index] creates an [index.txt] file from a template file. The template
 * file is an ocamldoc formatted file with extra "%s" strings throughout. If
 * there are [n] "%s" strings [s_1], ..., [s_n], they are replaced with the
 * parsed contents of the first [n] entries in [odocls]. For example, if we
 * have the following template:
 *
 *     Hello!
 *     %s
 *     Bye!
 *     %s
 *
 * and [odocls = ["foo"; "bar"]] and the [foo] directory contains the following
 * [odocl]:
 *
 *     Foo
 *
 * and [bar] contains the following [odocl]:
 *
 *     Bar
 *
 * then [write_index w] writes the following to [w]:
 *
 *     Hello!
 *     {ol
 *       {- {{:code_Foo.html} [Foo]}}
 *     }
 *     Bye!
 *     {ol
 *       {- {{:code_Bar.html} [Bar]}}
 *     }
 *)
let write_index (w: Writer.t) : unit Deferred.t =
  Reader.with_file template ~f:(fun r ->
    Deferred.List.map odocls ~f:parse_odocl >>= fun odocls ->
    Pipe.fold (Reader.lines r) ~init:([], odocls)
      ~f:(fun (lines, odocls) line ->
            match line, odocls with
            | "%s", []        -> return (lines, odocls)
            | "%s", o::odocls -> return (o::lines, odocls)
            | l,    _         -> return (l::lines, odocls)
      ) >>| fun (lines, _) ->
    Writer.write w (cat (List.rev lines))
  )

(* [write_odocl w] concatenates the contents of [odocls] and writes it [w] *)
let write_odocl (w: Writer.t) : unit Deferred.t =
  Deferred.List.map odocls ~f:Reader.file_contents >>| fun modules ->
  Writer.write w (String.concat ~sep:"" modules)

let main () : unit Deferred.t =
  Writer.with_file "index.txt" ~f:write_index >>= fun () ->
  Writer.with_file "doc.odocl" ~f:write_odocl >>= fun () ->
  return ()

let () =
  Command.async
    ~summary:"Generate ocamldocs."
    Command.Spec.empty
    (fun () -> try_with (fun () -> main ()) >>| function
      | Ok () -> ()
      | Error e -> print_endline (Exn.to_string e))
  |> Command.run
