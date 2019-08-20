
type envVar = { key : string; value : string }

type expr =
  | Empty
  | Expr of envVar list * string * string list
