let array_init n f = ( Array.init n f )
let array_free _arr = ( () )
let array_length arr = ( Array.length arr )
let array_get ( arr, idx ) = ( Array.get arr idx )
let array_set ( arr, idx, v ) = ( Array.set arr idx v )

let get  = (fun ( x, i ) -> array_get ( x, i ))
let copy a = (array_init (array_length a) (fun i -> array_get ( a, i )))
let set  =
(fun ( a, i, x ) -> let a2 = copy a in let _x = array_set ( a2, i, x ) in a2)
let set_mut  = (fun ( a, i, x ) -> array_set ( a, i, x ))

let and_f b1 b2 = (match b1 with
                     | true -> b2
                     | false -> false)
open Intset (*
    type intset  
    (* val empty *)
    (* val add *)
    (* val rm *)
    (* val iter_set *)
    (* val cardinal *)
    (* val print *)
    (* val easy_board *)
    (* val for_all *)
*)
let size  = 9
let full_cell  =
(let rec f =
   fun i ->
   fun xset ->
   match i < 0 with
     | true -> xset
     | false -> f (i - 1) (add xset i)
 in f (size - 1) empty)
let singleton n = (add empty n)
let get x = (fun ( i, j ) -> get ( x, (i * size) + j ))
let set_mut x = (fun ( i, j ) -> fun v -> set_mut ( x, (i * size) + j, v ))
let set x = (fun ( i, j ) -> fun v -> set ( x, (i * size) + j, v ))
let for_f  =
(let rec aux =
   fun i ->
   fun j ->
   fun f ->
   match i > j with
     | true -> ()
     | false -> let () = f i in aux (i + 1) j f
 in aux)
let remove_line i0 j0 g n =
(for_f (j0 + 1) (size - 1)
   (fun j -> let cell = rm (get g ( i0, j )) n in set_mut g ( i0, j ) cell))
let remove_column i0 j0 g n =
(for_f (i0 + 1) (size - 1)
   (fun i -> let cell = rm (get g ( i, j0 )) n in set_mut g ( i, j0 ) cell))
let remove_square i0 j0 g n =
(let pos_i = i0 / 3 in
 let pos_j = j0 / 3 in
 for_f (3 * pos_i) ((3 * (pos_i + 1)) - 1)
   (fun i ->
    for_f (3 * pos_j) ((3 * (pos_j + 1)) - 1)
      (fun j ->
       match and_f (i = i0) (j = j0) with
         | false ->
           let cell = rm (get g ( i, j )) n in set_mut g ( i, j ) cell
         | true -> ())))
let is_valid g = (for_all (fun x -> (cardinal x) > 0) g)
let is_solved g = (for_all (fun x -> (cardinal x) = 1) g)
let next_pos  =
(fun ( i, j ) ->
 match j < (size - 1) with
   | true -> ( i, j + 1 )
   | false -> ( i + 1, 0 ))
let remove i j g n =
(let () = remove_line i j g n in
 let () = remove_column i j g n in let () = remove_square i j g n in ())
let solve g =
(let rec solve =
   fun i ->
   fun j ->
   fun g ->
   match is_solved g with
     | true -> print g
     | false ->
       let s = get g ( i, j ) in
       let ( new_i, new_j ) = next_pos ( i, j ) in
       let try_solution =
         fun n ->
         let new_g = set g ( i, j ) (singleton n) in
         let () = remove i j new_g n in
         match is_valid new_g with
           | true -> solve new_i new_j new_g
           | false -> ()
       in iter_set try_solution s
 in solve 0 0 g)
let main  = (print easy_board;
             solve easy_board)

