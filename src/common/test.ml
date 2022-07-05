
let levenshtein s t =
  let module M = Map.Make(struct type t = int * int let compare = Stdlib.compare end) in
  let rec dist i j mem = match (i,j) with
     | (i,0) as ot -> i,M.add ot i mem
     | (0,j) as ot -> j,M.add ot j mem
     | (i,j) as ot -> 
      begin
        match M.find_opt ot mem with
        | Some v -> v,mem
        | None ->
          if s.[i-1] = t.[j-1] then 
            dist (i-1) (j-1) mem
          else 
            let d1,mem = dist (i-1) j mem in
            let d2,mem = dist i (j-1) mem in
            let d3,mem = dist (i-1) (j-1) mem in
            let res = 1 + min d1 (min d2 d3) in
            res, M.add ot res mem
      end
  in
  dist (String.length s) (String.length t) M.empty |> fst

let test s t =
 Printf.printf " %s -> %s = %d\n" s t (levenshtein s t)

let () =
 test "kitten" "sitting";
 test "rosedddddddddddddddddttacode" "raisethdddddddddddddysword";
 