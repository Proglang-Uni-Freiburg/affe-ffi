open Js_of_ocaml
open Js_of_ocaml_tyxml.Tyxml_js

let set_lang_name name =
  Dom_html.document##.title := Js.string name;
  Register.id ~keep:false "lang" [Html.txt name]

let load_file s : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "loadfile")
    [|Js.Unsafe.inject @@ Js.string s|]

let clear_term i () : unit = 
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "clear_term")
    [|Js.Unsafe.inject i|]

let add_to_term i s : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "add_to_term")
    [|Js.Unsafe.inject i ;
      Js.Unsafe.inject @@ Js.string s|]
let flush_term i () : unit =
  Js.Unsafe.fun_call (Js.Unsafe.js_expr "flush_term")
    [|Js.Unsafe.inject i|]

let term i =
  let t = Format.make_formatter
    (fun s pos len ->
       let s = String.sub s pos len in
       add_to_term i s)
    (flush_term i)
  in
  Format.pp_set_max_boxes t 42 ;
  Format.pp_set_ellipsis_text t "..." ;
  Format.pp_set_margin t 60 ;
  Format.pp_set_max_indent t 30 ;
  t


let run_ocaml s =
    let code = Js.to_string s in
    let buffer = Buffer.create 100 in
    let formatter = Format.formatter_of_buffer buffer in
    let b = Js_of_ocaml_toplevel.JsooTop.use formatter code in
    let _ = Buffer.add_string buffer (string_of_bool b) in
    Js.string (Buffer.contents buffer)
