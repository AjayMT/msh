
type env_var = string * string

type expr =
  | Empty
  | Expr of env_var list * string * string list
;;

let envpair kv =
  let spl = String.split_on_char '=' kv in
  let (k, v) = (List.hd spl, List.hd (List.tl spl)) in
  (String.trim k, String.trim v)
;;
