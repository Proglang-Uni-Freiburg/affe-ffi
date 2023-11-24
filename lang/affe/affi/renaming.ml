open Syntax

type mod_env = Name.t list

let mod_prefix mname (name : Name.t) : Name.t 
= match name.name with 
  | Some n -> {name=Some (mname ^ "." ^ n) ; id=name.id}
  | None -> {name=None ; id=name.id}

let mod_env_prefix mname (env : mod_env) (name : Name.t) : Name.t
= if List.mem name env then mod_prefix mname name else name

let rec mod_prefix_type mod_name (env : mod_env) typ 
= match typ with 
  | App (n, ts) -> App (mod_env_prefix mod_name env n, 
    List.map (mod_prefix_type mod_name env) ts)
  | Arrow (a, k, b) -> Arrow (mod_prefix_type mod_name env a, k, mod_prefix_type mod_name env b)
  | Tuple l -> Tuple (List.map (mod_prefix_type mod_name env) l)
  | Borrow (b, k, t) -> Borrow (b, k, mod_prefix_type mod_name env t)
  | Var n -> Var (mod_env_prefix mod_name env n)

let rec mod_prefix_constraints mod_name (env : mod_env) con 
= match con with
  | KindLEq (k1, k2) -> KindLEq (k1, k2)
  | HasKind (typ, k) -> HasKind (mod_prefix_type mod_name env typ, k)
  | And cs -> And (List.map (mod_prefix_constraints mod_name env) cs)

let mod_prefix_tscheme mod_name (env : mod_env)
  ({kvars ; tyvars ; constraints ; typ} : T.scheme) : T.scheme =
  { kvars ; tyvars ; 
  constraints=mod_prefix_constraints mod_name env constraints ; 
  typ=mod_prefix_type mod_name env typ}

let mod_prefix_params mod_name (env : mod_env) params =
  List.map (fun p -> (mod_env_prefix mod_name env (fst p)), snd p) params

let mod_prefix_constructor mod_name (env : mod_env)
  ({name ; constraints ; typ} : T.constructor) : T.constructor
  = let env = name :: env in
  {name=mod_env_prefix mod_name env name ; 
    constraints=mod_prefix_constraints mod_name env constraints ;
    typ=(
      match typ with
      | None -> None
      | Some t-> Some (mod_prefix_type mod_name env t)
    )}

let mod_prefix_constructors mod_name (env : mod_env) cons
= List.map (mod_prefix_constructor mod_name env) cons


let mod_prefix_cmd mod_name (env : mod_env) cmd 
= match cmd with
  | ValueDef {name ; typ} ->
    let env = name :: env in
    ValueDef {name=mod_prefix mod_name name ; 
      typ=(mod_prefix_tscheme mod_name env typ)}, env
  | TypeDecl {name ; params ; constructor ; constraints ; kind} ->
    let env = name :: env in
    TypeDecl {name=mod_prefix mod_name name ; 
      params=mod_prefix_params mod_name env params ; 
      kind ;
      constraints=mod_prefix_constraints mod_name env constraints;
      constructor=mod_prefix_constructors mod_name env constructor}, env
  | a -> a, env

let rec mod_prefix_cmds mod_name (env : mod_env) cmds
= match cmds with
  | [] -> []
  | cmd :: xs -> 
      let (cmd, env) = (mod_prefix_cmd mod_name env cmd) in
      cmd :: mod_prefix_cmds mod_name env xs
    