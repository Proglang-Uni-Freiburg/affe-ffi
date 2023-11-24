(* extern Foo
   type t  
   val bar
   val print
   type ('a) option = None | Some of 'a
*)
let dummy  = ( Foo.Some Foo.bar )
let main  =
(let () = match dummy with
            | Foo.None -> ()
            | Foo.Some (s) -> Foo.print s
 in ())

