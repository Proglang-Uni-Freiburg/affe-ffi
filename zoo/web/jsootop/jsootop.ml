open Js_of_ocaml_toplevel
open Js_of_ocaml

let add_to_term i s : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "add_to_term")
    [|Js.Unsafe.inject i ;
      Js.Unsafe.inject @@ Js.string s|]
let flush_term i () : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "flush_term")
    [|Js.Unsafe.inject i|]

let () =
  JsooTop.initialize ();
  Sys_js.set_channel_flusher stdout 
    (fun s -> add_to_term 3 s; flush_term 3 ())

let builtins = [
  "Foo" ; "Intset"
]

let cache_builtin (m : string) : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "cacheBuiltin")
    [|Js.Unsafe.inject m|]

let load_builtin (m : string) : string =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "loadBuiltin")
    [|Js.Unsafe.inject m|]

let preview_builtin s : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "previewBuiltin")
    [|Js.Unsafe.inject @@ Js.string s|]

let load_files l =
  let open Js_of_ocaml_tyxml.Tyxml_js in
  let elem s =
    Html.(li [a ~a:[a_class ["file"]; a_href ("#"^s); a_title s;
                a_onclick (fun _ -> preview_builtin s; false);]
            [txt s]])
  in
  let l = Html.ul (List.map elem l) in
  Register.id ~keep:true "builtin" [l]


let execute code =
  JsooTop.initialize ();
  let code = Js.to_string code in
  let buffer = Buffer.create 100 in
  let formatter = Format.formatter_of_buffer buffer in
  List.iter (fun m -> 
    let _ = JsooTop.use formatter (load_builtin m) in ()
    ) builtins;
  let _ = JsooTop.use formatter code in
  Js.string (Buffer.contents buffer)

let () =
  Js.export "OCaml" (
    object%js
      val execute = execute
    end);
  load_files builtins;
  List.iter cache_builtin builtins