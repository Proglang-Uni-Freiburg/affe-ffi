module Ints = Set.Make(Int)

type intset = Ints.t

let empty = Ints.empty
let add set i = Ints.add i set
let rm set i = Ints.remove i set
let iter_set = Ints.iter
let cardinal = Ints.cardinal

let for_all f arr = Array.for_all f arr

let size = 9

let simple_print_set (set : intset) =
  let card = cardinal set in
  if card > 1 then
    Printf.printf "|%d|" card
  else match Ints.choose_opt set with
  | None -> Printf.printf "{ }"
  | Some i -> Printf.printf " %d " i

let print (sets : intset array) =
  print_endline "---------------------------";
  for i = 1 to size * size do
    simple_print_set (Array.get sets (i-1));
    if (i mod size) = 0 then
      Printf.printf "\n"
  done

let singleton = add empty

let parse_int_board b = Array.init (size * size)
  (fun i -> match b.(i) with 
    | 0 -> List.fold_left add empty [ 1 ; 2 ; 3 ; 4 ; 5 ; 6 ; 7 ; 8 ; 9 ]
    | i -> singleton i)
  
let easy_board = parse_int_board [| 
  0;0;0;4;6;7;3;0;9;
  9;0;3;8;1;0;4;2;7;
  1;7;4;2;0;3;0;0;0;
  2;3;1;9;7;6;8;5;4;
  8;5;7;1;2;4;0;9;0;
  4;9;6;3;0;8;1;7;2;
  0;0;0;0;8;9;2;6;0;
  7;8;2;6;4;1;0;0;5;
  0;1;0;0;0;0;7;0;8
|]