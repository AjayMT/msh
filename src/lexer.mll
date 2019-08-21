
(** lexer.mll
 * M shell lexer rules.
 *)

{
  open Parser
  open Defs
  exception Eof
  exception SyntaxError of string
}

let char = [^ '\\' ' ' '\t' '\n' '|' '=']
let key_char = ['a'-'z' 'A'-'Z' '0'-'9' '_']
let ws = [' ' '\t']

rule token = parse
  | ws { token lexbuf }
  | '\n' { EOL }
  | '|' { PIPE }
  | '=' { EQ }
  | key_char+ ws* '=' ws* char+ as kv { ENVPAIR(envpair kv) }
  | char+ as w { WORD (w) }
  | eof { raise Eof }
  | _ { raise (SyntaxError ("char " ^ (string_of_int lexbuf.lex_curr_pos))) }
