let doc =
  let open Js_of_ocaml_tyxml.Tyxml_js in
  [%html{|
<p>
  Welcome to the online demo of the Affe language!
</p>
<p>
 This language aims to prevent linearity violations, notably bugs such as 
 use-after-free. Affe is an ML-like language similar to OCaml. 
 In particular, Affe is functional with arbitrary side effects and
 complete type inference (i.e., users never need to write type annotations).
</p>
<p>
  The implementation is available
  <a href="https://github.com/lukaskleinert/affe-ffi">https://github.com/lukaskleinert/affe-ffi</a>.
</p>
<p>
  The original implementation of the affe language was taken from
  <a href="https://github.com/Drup/pl-experiments">https://github.com/Drup/pl-experiments</a>.
</p>
<p>
You can find a list of examples below. "Run" runs the typing and
translation to OCaml.
The result of the typing (or the appropriate type error) is displayed
in the top right. The OCaml code is displayed on the bottom left.
"Run OCaml" runs the currently displayed OCaml code and displays the output of that on the bottom right.
Beware, this is a prototype: error messages
(and the UI in general) are research-quality.
</p>
<p>
  <em>Have fun!</em>
</p>
|}]



let l = [
  "intro.affe";
  "arraydef.affe";
  "basics.affe";
  "constraints.affe";
  "cow.affe";
  "example.affe";
  "example2.affe";
  "fail.affe";
  "linstr.affe";
  "moduleimport.affe";
  "nonlexical.affe";
  "optstrlist.affe";
  "patmatch.affe";
  "pool.affe";
  "queuedef.affe";
  "region.affe";
  "sessions.affe";
  "sudoku.affe";
  "test_un.affe"
]

let () =
  Js_of_ocaml_tyxml.Tyxml_js.Register.id "content" doc;
  Printer.debug := false ;
  Affe_lang.load_files l ;
  Affe_lang.main ()
