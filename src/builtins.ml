
(** builtins.ml
 * M shell builtins.
 *)

type builtin_func = (string * string) list ->
                    string list ->
                    Unix.file_descr ->
                    Unix.file_descr ->
                    (unit, string) result

let cd : builtin_func = fun _ args _ _ ->
  match args with
  | []   -> Ok (Sys.chdir (Sys.getenv "HOME"))
  | h::_ -> Ok (Sys.chdir h)


let echo : builtin_func = fun _ args _ out_fd ->
  let str = String.concat " " args in
  let written = Unix.write_substring out_fd str 0 (String.length str) in
  if written = (String.length str) then Ok () else Error "Write failed"


let exit_ : builtin_func = fun _ args _ _ ->
  match args with
  | []   -> Ok (exit 0)
  | h::_ -> match int_of_string_opt h with
            | Some i -> Ok (exit i)
            | None   -> Error "Bad argument"


let builtins_table =
  let l = [
      ("cd", cd);
      ("echo", echo);
      ("exit", exit_)
    ] in
  Hashtbl.of_seq (List.to_seq l)
