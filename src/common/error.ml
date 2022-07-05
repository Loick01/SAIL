open Monad

module E = MenhirLib.ErrorReports

(* taken from http://rosettacode.org/wiki/Levenshtein_distance#A_recursive_functional_version *)
let levenshtein_distance s t =
  let m = String.length s
  and n = String.length t in
  let d = Array.make_matrix (m + 1) (n + 1) 0 in
  for i = 0 to m do d.(i).(0) <- i done;
  for j = 0 to n do  d.(0).(j) <- j done;
  for j = 1 to n do
    for i = 1 to m do
      if s.[i - 1] = t.[j - 1] then d.(i).(j) <- d.(i - 1).(j - 1)
      else
        d.(i).(j) <- min (d.(i - 1).(j) + 1) (min (d.(i).(j - 1) + 1) (d.(i - 1).(j - 1) + 1))
    done
  done;
  d.(m).(n)

let show_context text (p1,p2) =
  let open Lexing in
  let p1 = { p1 with pos_cnum=p1.pos_bol}
  and p2 = { p2 with pos_cnum= String.index_from text p2.pos_cnum '\n'}  in
  E.extract text (p1,p2) |> E.sanitize


type error = 
{
  where : TypesCommon.loc;
  what :   string;
  why : (TypesCommon.loc option * string) option;
  hint : string;
  label : string;
} 
type errors = error list
type 'a result = ('a, errors) Result.t



let x = fun fmt -> Format.pp_print_list fmt

let make ?(why=None) ?(hint="") ?(label="") where what : 'a result = 
  Result.error [{where;what;why;label;hint}]

let print_errors (file:string) (errs:error list) : unit =  
  let s fmt = List.iter (
    fun e ->
      let pf = (Fmt.styled `Red Fmt.pf  fmt) in
      pf "@[<v 5>wow@,";
      Fmt.pf fmt "%s@," (show_context file e.where);
      let start = String.make ((fst e.where).pos_cnum - (fst e.where).pos_bol )' ' in
      let ending = String.make ((snd e.where).pos_cnum - (fst e.where).pos_cnum )'^' in
      Fmt.pf fmt "@[<v>%s%s@,@]" start ending 
  )
  errs in
  Logs.err  (fun m -> m "@[<v 5>found %i error(s) :@." (List.length errs) );
  s Fmt.stderr


let partition_result f l  : 'a list * errors  = 
  let r,e = List.partition_map ( fun r -> match f r with Ok a -> Either.left a | Error e -> Either.right e) l 
  in r,List.flatten e


module MonadError : Monad with type 'a t = 'a result = struct
  type 'a t = ('a, error list) Result.t

  let fmap = Result.map

  let pure x = Result.ok x

  let ( <*> ) f x = match f with Ok f -> fmap f x | Error e -> Error e

  let ( >>= ) = Result.bind

  let ( >>| ) x f = x >>= fun x -> f x |> pure
end
