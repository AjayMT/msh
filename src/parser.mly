
%{ open Defs %}

%token <string> WORD
%token <string> KEY
%token PIPE
%token EQ
%token EOL

%start main
%type <(Defs.expr list, string) result> main

%%

main: pipedExprs EOL { Ok $1 }
  | error EOL        { Error "?" }
;

pipedExprs: _pipedExprs { List.rev $1 }
;

_pipedExprs: expr         { [$1] }
  | _pipedExprs PIPE expr { $3 :: $1 }
;

expr:              { Empty }
  | WORD           { Expr ([], $1, []) }
  | WORD args      { Expr ([], $1, $2) }
  | env WORD       { Expr ($1, $2, []) }
  | env WORD args  { Expr ($1, $2, $3) }
;

args: _args { List.rev $1 }
;

_args: WORD    { [$1] }
  | _args WORD { $2 :: $1 }
;

// I am assuming order of environment variables
// doesn't matter, which is probably not true.
env: var     { [$1] }
  | env var  { $2 :: $1 }
;

// TODO fix this
//var: KEY EQ WORD { {key=$1; value=$3} }
//;
var: WORD EQ WORD { {key=$1; value=$3} }
;
