(**************************************************************************)
(*                                                                        *)
(*                                 SAIL                                   *)
(*                                                                        *)
(*             Frédéric Dabrowski, LMV, Orléans University                *)
(*                                                                        *)
(* Copyright (C) 2022 Frédéric Dabrowski                                  *)
(*                                                                        *)
(* This program is free software: you can redistribute it and/or modify   *)
(* it under the terms of the GNU General Public License as published by   *)
(* the Free Software Foundation, either version 3 of the License, or      *)
(* (at your option) any later version.                                    *)
(*                                                                        *)
(* This program is distributed in the hope that it will be useful,        *)
(* but WITHOUT ANY WARRANTY; without even the implied warranty of         *)
(* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *)
(* GNU General Public License for more details.                           *)
(*                                                                        *)
(* You should have received a copy of the GNU General Public License      *)
(* along with this program.  If not, see <https://www.gnu.org/licenses/>. *)
(**************************************************************************)

module type Type = sig 
  type t
end

module type Functor = sig 
  type 'a t 
  val fmap : ('a -> 'b) -> 'a t  -> 'b t
end

module type Applicative = sig
include Functor
  val pure : 'a -> 'a t  
  val apply : ('a -> 'b ) t -> 'a t -> 'b t
end 

module type Monad = sig
  include Applicative
  val bind : 'a t -> ('a -> 'b t) -> 'b t
end

module type MonadTransformer = sig
  include Monad
  type 'a old_t
  val lift : 'a old_t -> 'a t
end

module MonadIdentity : Monad with type 'a t = 'a = struct
  type 'a t = 'a
  let pure x = x

  let fmap f x = f x

  let apply = fmap

  let bind x f = f x
end

module MonadOperator (M : Monad) = struct
  let (<*>) = M.apply
  let (>>=) = M.bind
  let (>>|) x f = x >>= fun x -> f x |> M.pure
end

module MonadSyntax (M : Monad ) = struct 
  open M
  open MonadOperator(M)
  let return = pure

  let (let*) : 'a M.t -> ('a -> 'b M.t) -> 'b M.t = M.bind

  let (and*) x y = 
    let* x = x in let* y = y in return (x,y)

  let (let+) : 'a M.t -> ('a -> 'b) -> 'b M.t = (>>|)
  let (and+) x y =
    let+ x = x in let+ y = y in return (x,y)

end


module MonadFunctions (M : Monad) = struct 
  module FieldMap =  Map.Make(String)
  let mapMapM (f : 'a -> 'b M.t) (m : 'a FieldMap.t) : ('b FieldMap.t) M.t = 
  let open MonadSyntax (M) in
  let rec aux (l : (string * 'a) Seq.t) : (string * 'b) Seq.t M.t =
    match l () with
    | Seq.Nil -> return (fun () -> Seq.Nil)
    | Seq.Cons ((x, a), v) ->
        let* u = f a in 
        let* l' = aux v in
        return (fun () -> Seq.Cons ((x,u),l' ))
  in  
  let* l' = aux (FieldMap.to_seq m) in 
  return (FieldMap.of_seq l')


  let mapIterM (f : FieldMap.key -> 'a -> unit M.t) (m : 'a FieldMap.t) : unit M.t = 
    let open MonadSyntax (M) in
    let rec aux (l : (string * 'a) Seq.t) : unit M.t =
      match l () with
      | Seq.Nil -> return ()
      | Seq.Cons ((k, a), v) ->
          let* () = f k a in 
          aux v
    in  
    aux (FieldMap.to_seq m) 
  
  let rec listMapM (f : 'a -> 'b M.t) (l : 'a list) : ('b list) M.t = 
    let open M in
    let open MonadOperator(M) in
    match l with 
      | [] -> pure []
      | h::t -> (f h) >>= (fun h -> listMapM f t >>= fun t -> pure (h::t)) 
      
      
  let rec listIterM (f : 'a -> unit M.t)  (l : 'a list) : unit M.t = 
    let open M in 
    let open MonadOperator(M) in
      match l with 
      | [] -> pure ()
      | h::t ->  (f h) >>= fun () -> listIterM f t

  let rec foldLeftM (f : 'a -> 'b -> 'a M.t) (x : 'a) (l : 'b list) : 'a M.t = 
    let open M in
    let open MonadOperator(M) in
    match l with 
      | [] -> pure x 
      | h :: t -> foldLeftM f x t >>=  (Fun.flip f) h      

  
  let rec foldRightM (f : 'a -> 'b -> 'b M.t) (l : 'a list) (x : 'b) : 'b M.t = 
    let open M in
    let open MonadOperator(M) in
    match l with 
      | [] -> pure x
      | h :: t -> f h x >>= foldRightM f t

  let rec sequence (l : 'a M.t list) : 'a list M.t =
    let open MonadSyntax(M) in
    match l with
    | [] -> return []
    | h :: t -> 
      let* h = h and* t = sequence t in return (h::t)

  let pairMap1 (f : 'a -> 'b M.t) ((x,y) : 'a * 'c) :('b * 'c) M.t =
    let open M in
    let open MonadOperator(M) in
      f x >>= (fun x -> pure (x, y))


  let pairMap2 (f : 'c -> 'b M.t) ((x,y) : 'a * 'c) :('a * 'b) M.t =
    let open M in
    let open MonadOperator(M) in
      f y >>= (fun y -> pure (x, y))
end
  