let print i = ( print_int i ; print_endline "" )
(*
  type string  
  val print_int
  val print_endline
  type ('a) option = None | Some of 'a
*)
(*
  type ('a) option = None | Some of 'a
*)
(*
  val print_endline
*)
type ('a) option' = 'a option 
(* extern Foo
   val bar
   val print
   type ('a) option = None | Some of 'a
*)
let printbar  = (fun () -> Foo.print Foo.bar)
let main  = (let () = print 42;
                      printbar () in ())

