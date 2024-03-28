open Syntax
open Unused_vars

let open_modules = ref true

let ocaml_rec_flag fmt rec_flag = Fmt.pf fmt (if rec_flag = Rec then "rec " else "")

let ocaml_const fmt = function
  | Int i -> Fmt.pf fmt "%d" i
  | Primitive s -> Fmt.pf fmt "%s" s
  | Y -> Fmt.pf fmt "Y"

let ocaml_name fmt (name : Name.t) 
  = match name.name with
  | Some "True" -> Fmt.pf fmt "true"
  | Some "False" -> Fmt.pf fmt "false"
  | Some s -> Fmt.pf fmt "%s" s
  | None -> ()

let ocaml_name_unused (assigned : expr) fmt (name : Name.t)
  = match name.name with
  | Some s when not (String.starts_with ~prefix:"_" s) -> 
    if (expr_uses name assigned) then ocaml_name fmt name else Fmt.pf fmt "_%s" s
  | _ -> ocaml_name fmt name

let rec ocaml_pattern_unused (assigned : expr) fmt  = function
  | PAny -> Fmt.pf fmt "_"
  | PUnit -> Fmt.pf fmt "()"
  | PVar n -> ocaml_name_unused assigned fmt n
  | PConstr (constr, None) ->
    Format.fprintf fmt "%a" ocaml_name constr
  | PConstr (constr, Some pat) ->
    Format.fprintf fmt "%a (%a)" ocaml_name constr (ocaml_pattern_unused assigned) pat
  | PTuple l -> 
    Format.fprintf fmt "@[(@ %a@ )@]" Fmt.(list ~sep:(Fmt.any ",@ ") (ocaml_pattern_unused assigned)) l

let rec ocaml_pattern fmt  = function
  | PAny -> Fmt.pf fmt "_"
  | PUnit -> Fmt.pf fmt "()"
  | PVar n -> ocaml_name fmt n
  | PConstr (constr, None) ->
    Format.fprintf fmt "%a" ocaml_name constr
  | PConstr (constr, Some pat) ->
    Format.fprintf fmt "%a (%a)" ocaml_name constr ocaml_pattern pat
  | PTuple l -> 
    Format.fprintf fmt "@[(@ %a@ )@]" Fmt.(list ~sep:(Fmt.any ",@ ") ocaml_pattern) l

let rec ocaml_expr fmt (expr : expr)
  = match expr with
  | App (Constant (Primitive s), [e1; e2]) when List.mem s Printer.binop ->
    Format.fprintf fmt "@[<2>@[%a@]@ %s @[%a@]@]"
      ocaml_expr_with_paren e1
      s
      ocaml_expr_with_paren e2
  | App (f, args) -> Fmt.pf fmt "@[<2>@[%a@]@ %a@]"
      ocaml_expr_with_paren f
      Fmt.(list ~sep:(Fmt.any "@ ") ocaml_expr_with_paren) args
  | Array a -> Fmt.pf fmt "@[[|@ %a@ |]@]" Fmt.(list ~sep:(Fmt.any ";@ ") ocaml_expr) a
  | Constant c -> ocaml_const fmt c
  | Constructor c -> ocaml_name fmt c
  | Lambda (n, e) -> Fmt.pf fmt "@[fun %a ->@ %a@]"
      (ocaml_pattern_unused e) n
      ocaml_expr e
  | Tuple t -> Fmt.pf fmt "@[(@ %a@ )@]" Fmt.(list ~sep:(Fmt.any ",@ ") ocaml_expr) t
  | Var v -> ocaml_name fmt v
  | Borrow (_, v) -> ocaml_name fmt v
  | ReBorrow (_, v) -> ocaml_name fmt v
  | Let (b, p, e1, e2) -> Fmt.pf fmt "@[@[<2>let %a%a =@ %a@]@ in@ %a@]"
      ocaml_rec_flag b
      (ocaml_pattern_unused e2) p
      ocaml_expr e1
      ocaml_expr e2
  | Match (_, e, l) ->
      let sep = Fmt.cut in
      let case fmt (p, e) =
        Fmt.pf fmt "@[<2>| %a ->@ %a@]" 
          (ocaml_pattern_unused e) p ocaml_expr e
      in 
      Fmt.pf fmt "@[<v2>@[match@ %a@ with@]@ %a@]"
        ocaml_expr e
        (Fmt.list ~sep case) l
  | Region (ns, e) ->
    let pp fmt () =
      Fmt.pf fmt "@[<h>%a|@]@ %a"
        Fmt.(iter_bindings ~sep:sp Name.Map.iter (pair ocaml_name nop)) ns ocaml_expr e
    in
    Fmt.braces pp fmt ()
  | Sequence (e1, e2) -> Fmt.pf fmt "@[%a;@\n%a@]" 
      ocaml_expr e1
      ocaml_expr e2
and ocaml_expr_with_paren fmt (expr: expr)
  = let must_have_paren = match expr with
    | App _ | Let _ | Match _ | Lambda _ | Sequence _ -> true
    | Constant _ | Array _ | Tuple _ | Constructor _ | Var _
    | Borrow (_, _) | ReBorrow (_, _) | Region _ -> false
  in Format.fprintf fmt (if must_have_paren then "@[(%a@])" else "%a") ocaml_expr expr 

let rec ocaml_val_decl fmt decl args
  = match decl.expr with
  | Lambda (PVar n, e) -> 
    ocaml_val_decl fmt ({rec_flag=decl.rec_flag ; name=decl.name ; expr=e}) (n :: args)
  | _ -> Fmt.pf fmt "@[<2>let %a%a %a%s=@ %a@]"
    ocaml_rec_flag decl.rec_flag
    ocaml_name decl.name
    Fmt.(list ~sep:(Fmt.any "@ ") (ocaml_name_unused decl.expr)) (List.rev args)
    (if List.compare_length_with args 0 = 0 then "" else " ")
    ocaml_expr_with_paren decl.expr

let ocaml_param fmt (param : Name.t)
  = Fmt.pf fmt "'%a" ocaml_name param

let rec ocaml_type fmt (ty : Syntax.typ)
  = match ty with
  | App (n, []) -> ocaml_name fmt n
  | App (n, [e]) -> Fmt.pf fmt "@[<2>%a@ %a@]" ocaml_type_with_paren e ocaml_name n
  | App (n, es) -> let pp_sep fmt () = Format.fprintf fmt ",@ " in
      Fmt.pf fmt "@[<2>(%a)@ %a@]"
        (Format.pp_print_list ~pp_sep @@ ocaml_type_with_paren) es  ocaml_name n
  | Tuple l -> let pp_sep fmt () = Fmt.pf fmt " *@ " in
    Fmt.pf fmt "@[<2>%a@]"
      (Format.pp_print_list ~pp_sep @@ ocaml_type_with_paren) l
  | Borrow (_, _, t) -> ocaml_type_with_paren fmt t
  | Arrow (a, _, b) -> Fmt.pf fmt "@[%a -> %a@]" ocaml_type_with_paren a ocaml_type_with_paren b
  | Var n -> ocaml_param fmt n

and ocaml_type_with_paren fmt x =
  let must_have_paren = match x with
    | T.Arrow _ -> true
    | _ -> false
  in Fmt.pf fmt (if must_have_paren then "@[(%a@])" else "%a") ocaml_type x

let ocaml_type_con fmt (con : T.constructor)
  = match con.typ with
  | None -> ocaml_name fmt con.name
  | Some t -> Fmt.pf fmt "%a of %a" 
    ocaml_name con.name 
    ocaml_type_with_paren t

let ocaml_type_cons fmt (cons : T.constructor list)
  = Fmt.pf fmt "%a" Fmt.(list ~sep:(Fmt.any " |@ ") ocaml_type_con) cons

let ocaml_params fmt params
  = match params with
  | [] -> ()
  | _ -> Fmt.pf fmt "(%a) " Fmt.(list ~sep:(Fmt.any ",@ ") ocaml_param) params

let ocaml_type_decl fmt (decl : T.decl)
  = Fmt.pf fmt "@[type %a%a %s@ %a@]"
    ocaml_params (List.map fst decl.params)
    ocaml_name decl.name
    (match decl.constructor with
    | [] -> ""
    | _ -> "=")
    ocaml_type_cons decl.constructor

let rec ocaml_cmd fmt cmd
  = match cmd with
  | ValueDecl decl -> ocaml_val_decl fmt decl []
  | Extern ({name = None ; _}, cmds) -> 
    let fmt_ex =
    if List.length cmds = 1 
      then Fmt.pf fmt "@[(* %a *)@]@\n" 
      else Fmt.pf fmt "(*@[@\n%a@]@\n*)"
    in fmt_ex Fmt.(list ~sep:(Fmt.any "@\n") uncomment_val) cmds
  | Extern (n, cmds) -> 
      Fmt.pf fmt "(*@\n@[<2>extern %a@\n%a@]@.*)"
      ocaml_name n
      Fmt.(list ~sep:(Fmt.any "@\n") uncomment_val) cmds
  | ValueDef d -> Fmt.pf fmt "@[(* val %a *)@]" ocaml_name d.name
  | TypeDecl d -> ocaml_type_decl fmt d
  | OCAML (ValueDef {name ; _}, args, code) -> Fmt.pf fmt "@[<2>let %a %a%s= (@[%s@])@]" 
    ocaml_name name
    Fmt.(list ~sep:(Fmt.any "@ ") ocaml_pattern) args
    (if List.compare_length_with args 0 = 0 then "" else " ")
    code
  | OCAML (TypeDecl ty, [], code) -> Fmt.pf fmt "@[type %a%a =%s@]"
    ocaml_params (List.map fst ty.params)
    ocaml_name ty.name
    code
  | _ -> ()
and uncomment_val fmt cmd
  = match cmd with
  | ValueDef d -> Fmt.pf fmt "@[val %a @]" ocaml_name d.name
  | _ -> ocaml_cmd fmt cmd

let ocaml_cmds fmt lst
  = match lst with
  | [] -> ()
  | _ -> Fmt.pf fmt "@[%a@]@." Fmt.(list ~sep:(Fmt.any "@.") ocaml_cmd) lst


let to_ocaml cmd_fmt cmds =
  if !Printer.debug then Format.printf "%a@.\n" ocaml_cmds cmds;
  Fmt.pf cmd_fmt "%a" ocaml_cmds cmds (* write to file *)