
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

let resolve_command : string -> exec option = fun name ->
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

let rec fold_left_pairs :
          ('a -> 'b -> 'b option -> 'a) ->
          'a -> 'b list -> 'a = fun f acc l ->
  match l with
  | []       -> acc
  | [a]      -> f acc a None
  | a::b::tl -> fold_left_pairs f (f acc a (Some b)) (b::tl)
;;

let eval_piped_exprs :
      expr list ->
      ((int * Unix.process_status) option * (unit, string) result) =
  fun piped_exprs ->

  let spawn pid_opt in_fd env name args next_opt =
    let action = resolve_command name in
    match action with
    | None -> (pid_opt, in_fd, Error (name ^ " not found"))
    | Some (Builtin b) ->
       let (next_in, next_out) = match next_opt with
         | None   -> (Unix.stdin, Unix.stdout)
         | Some _ -> Unix.pipe ()
       in
       (pid_opt, next_in, b env args in_fd next_out)
    | Some (Exec e) ->
       let (next_in, next_out) = match next_opt with
         | None   -> (Unix.stdin, Unix.stdout)
         | Some _ -> Unix.pipe ()
       in
       let pid = Unix.create_process_env
                   name
                   (Array.of_list (name :: args))
                   (construct_env env)
                   in_fd next_out Unix.stderr
       in
       (Some pid, next_in, Ok ())
  in

  let eval_expr acc curr next_opt =
    let (pid_opt, in_fd, err) = acc in
    match err with
    | Error e -> acc
    | Ok ()   ->
       match curr with
       | Empty -> acc
       | Expr (env, name, args) -> spawn pid_opt in_fd env name args next_opt
  in

  let (pid, _, err) = fold_left_pairs
                        eval_expr
                        (None, Unix.stdin, Ok ())
                        piped_exprs
  in
  match pid with
  | Some p -> (Some (Unix.waitpid [] p), err)
  | None   -> (None, err)
;;

let _ =
  while true do
    if Unix.isatty Unix.stdin then print_string "$ ";
    flush stderr;
    flush stdout;
    begin
      try
        let lexbuf = Lexing.from_channel stdin in
        let result = Parser.main Lexer.token lexbuf in
        match result with
        | Error err      -> prerr_string ("msh: Parse error: " ^ err)
        | Ok piped_exprs ->
           let _, err = eval_piped_exprs piped_exprs in
           match err with
           | Ok ()   -> ()
           | Error s -> prerr_string ("msh: Eval Error: " ^ s)
      with
      | Lexer.Eof           -> exit 0
      | Lexer.SyntaxError s -> prerr_string ("msh: Syntax error: " ^ s)
    end;
  done
;;
