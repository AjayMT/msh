
(** msh.ml
 * The M shell.
 *)

open Defs
open Printf

type exec = Builtin of Builtins.builtin_func | Exec of string

let find_exec_path : string -> exec option = fun name ->
  match (Sys.getenv_opt "PATH") with
  | None          -> None
  | Some env_path ->
     let env_paths = String.split_on_char ':' env_path in
     let test_path acc path = match (acc, path) with
       | (Some e, _) -> Some e
       | (None, p)   ->
          let file_path = Filename.concat p name in
          if Sys.file_exists file_path then Some (Exec file_path) else None
     in
     List.fold_left test_path None env_paths
;;

let find_exec : string -> exec option = fun name ->
  match Hashtbl.find_opt Builtins.builtins_table name with
  | Some b -> Some (Builtin b)
  | None   -> if Sys.file_exists name then
                Some (Exec name)
              else
                find_exec_path name
;;

let construct_env : (string * string) list -> string array = fun local_env ->
  let global_env = Unix.environment () in
  let local_env_normalized = List.map (fun (k, v) -> k ^ "=" ^ v) local_env in
  Array.concat [global_env; Array.of_list local_env_normalized]
;;

let eval_piped_exprs : expr list -> (string, string) result = fun l ->
  let spawn env name args = (
      "",
      Unix.create_process_env
        name
        (Array.of_list (name :: args))
        (construct_env env)
        Unix.stdin Unix.stdout Unix.stderr
    ) in
  let eval_expr : expr -> (string, string) result = function
    | Empty                  -> Ok ""
    | Expr (env, name, args) ->
       match find_exec name with
       | None             -> Error "Not found"
       | Some (Builtin f) -> Ok (fst (f args))
       | Some (Exec s)    -> Ok (fst (spawn env name args))
  in
  eval_expr (List.hd l)
;;

let _ =
  while true do
    printf "$ "; flush stdout;
    begin
      try
        let lexbuf = Lexing.from_channel stdin in
        let result = Parser.main Lexer.token lexbuf in
        match result with
        | Error err      -> print_string ("msh: Parse error: " ^ err)
        | Ok piped_exprs ->
           begin
             match eval_piped_exprs piped_exprs with
             | Ok s    -> flush stdout; print_string s
             | Error s -> flush stdout; print_string ("msh: Eval error: " ^ s)
           end;
      with
      | Lexer.Eof           -> exit 0
      | Lexer.SyntaxError s -> printf "msh: Syntax error: %s" s
    end;
    flush stdout
  done
;;
