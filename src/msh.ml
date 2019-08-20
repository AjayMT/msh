
open Defs
open Printf

let eval_piped_exprs l =
  "Ok"
;;

let _ =
  while true do
    printf "$ "; flush stdout;
    begin
      try
        let lexbuf = Lexing.from_channel stdin in
        let result = Parser.main Lexer.token lexbuf in
        match result with
        | Ok piped_exprs -> print_string (eval_piped_exprs piped_exprs)
        | Error err      -> printf "msh: Parse error: %s" err
      with
      | Lexer.Eof           -> exit 0
      | Lexer.SyntaxError s -> printf "msh: Syntax error: %s" s
    end;
    print_newline (); flush stdout
  done
;;
