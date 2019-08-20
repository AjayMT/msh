
{
  open Parser
  exception Eof
  exception SyntaxError of string
}

let char = [^ '\\' ' ' '\t' '\n' '|' '=']
let alpha = ['a'-'z' 'A'-'Z']
let keyChar = ['a'-'z' 'A'-'Z' '0'-'9' '_']

rule token = parse
  | [' ' '\t'] { token lexbuf }
  | '\n' { EOL }
  | '|' { PIPE }
  | '=' { EQ }
  | char+ as w { WORD (w) }
  | alpha keyChar* as w { KEY (w) }
  | eof { raise Eof }
  | _ { raise (SyntaxError ("char " ^ (string_of_int lexbuf.lex_curr_pos))) }
