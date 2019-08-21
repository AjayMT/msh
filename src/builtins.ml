
(** builtins.ml
 * M shell builtins.
 *)

type builtin_func = string list -> string * unit

let cd : builtin_func = function
  | []   -> ("", Sys.chdir (Sys.getenv "HOME"))
  | h::_ -> ("", Sys.chdir h)
;;

let echo : builtin_func = fun args ->
  (String.concat " " args, ())
;;

let exit_ : builtin_func = function
  | []   -> ("", exit 0)
  | h::_ -> match int_of_string_opt h with
            | Some i -> ("", exit i)
            | None   -> ("Bad argument", ())
;;

let builtins_table =
  let l = [
      ("cd", cd);
      ("echo", echo);
      ("exit", exit_)
    ] in
  Hashtbl.of_seq (List.to_seq l)
