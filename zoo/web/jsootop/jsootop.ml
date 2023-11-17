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

let execute code =
  let code = Js.to_string code in
  let buffer = Buffer.create 100 in
  let formatter = Format.formatter_of_buffer buffer in
  let _ = JsooTop.use formatter code in
  Js.string (Buffer.contents buffer)

let () =
  Js.export "OCaml" (
    object%js
      val execute = execute
    end)