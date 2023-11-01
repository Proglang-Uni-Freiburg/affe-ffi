open Syntax

let rec any f lst = match lst with
  | [] -> false
  | x :: xs -> f x || any f xs

let rec expr_uses (name : Name.t) (expr : expr)
  = let lambda_uses (name : Name.t) (lam : lambda)
    = if (pattern_introduces name (fst lam)) then false else expr_uses name (snd lam) in
    let exprs_use (name : Name.t) (exprs : expr list)
    = any (expr_uses name) exprs in
  match expr with
  | App (f, args) -> expr_uses name f || exprs_use name args
  | Array exprs -> exprs_use name exprs
  | Constant _ -> false
  | Constructor _ -> false
  | Lambda (n, e) -> lambda_uses name (n, e)
  | Tuple exprs -> exprs_use name exprs
  | Var v -> v = name
  | Borrow (_, n) -> name = n
  | ReBorrow (_, n) -> name = n
  | Let (_, p, e1, e2) -> expr_uses name e1 || lambda_uses name (p, e2)
  | Match (_, e, l) -> expr_uses name e || any (lambda_uses name) l
  | Region (_, e) -> expr_uses name e
  | Sequence (e1, e2) -> expr_uses name e1 || expr_uses name e2

and pattern_introduces (name : Name.t) (pat : pattern)
  = match pat with
  | PUnit -> false
  | PAny -> false
  | PVar n -> (name = n)
  | PConstr (_, None) -> false
  | PConstr (_, Some p) -> pattern_introduces name p
  | PTuple ps -> any (pattern_introduces name) ps
