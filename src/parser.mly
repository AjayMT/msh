
%{ open Defs %}

%token <string> WORD
%token <string * string> ENVPAIR
%token PIPE
%token EQ
%token EOL

%start main
%type <(Defs.expr list, string) result> main

%%

main: piped_exprs EOL { Ok $1 }
  | error EOL         { Error "?" }
;

piped_exprs: _piped_exprs { List.rev $1 }
;

_piped_exprs: expr         { [$1] }
  | _piped_exprs PIPE expr { $3 :: $1 }
;

expr:              { Empty }
  | WORD           { Expr ([], $1, []) }
  | WORD args      { Expr ([], $1, $2) }
  | env WORD       { Expr ($1, $2, []) }
  | env WORD args  { Expr ($1, $2, $3) }
;

args: _args { List.rev $1 }
;

_args: word    { [$1] }
  | _args word { $2 :: $1 }
;

word: WORD  { $1 }
  | ENVPAIR { (fst $1) ^ "=" ^ (snd $1) }

// I am assuming order of environment variables
// doesn't matter, which is probably not true.
env: ENVPAIR    { [$1] }
  | env ENVPAIR { $2 :: $1 }
;
