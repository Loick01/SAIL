open Common
open Pass
open TypesCommon
open IrHir
open Error
open Monad
open AstHir

module E = MonadError

module V = (
  struct 
    type t = loc * bool * sailtype
    let string_of_var (_,_,t) = string_of_sailtype (Some t)

    let to_var (m:bool) (t:sailtype) = (dummy_pos),m,t

  end
)
module THIREnv = SailModule.SailEnv(V)

module ES = struct
  include MonadState.T(E)(THIREnv)
  (* todo : add get/set *)
end

module ER = struct
  include MonadReader.T(E)(THIREnv)
  (* todo : add get/set *)
end


open MonadSyntax(E)


type expression = (loc * sailtype) AstHir.expression

type statement = expression AstHir.statement

let extract_exp_loc_ty : 'a AstHir.expression -> 'a = function
| Variable (lt,_) | Deref (lt,_) | StructRead (lt,_,_)
| ArrayRead (lt,_,_) | Literal (lt,_) | UnOp (lt,_,_)
| BinOp (lt,_,_,_) | Ref  (lt,_,_) | ArrayStatic (lt,_)
| StructAlloc (lt,_,_) | EnumAlloc  (lt,_,_) -> lt

let extract_statements_loc : _ AstHir.statement -> loc  = function
| Watching(l, _, _) | Emit(l, _) | Await(l, _)
| When(l, _, _)  | Run(l, _, _) | Par(l, _, _)
| DeclSignal(l, _)  | Skip (l)  | Return (l,_)
| Invoke (l,_,_,_) | Block (l, _) | If (l,_,_,_)
| DeclVar (l,_,_,_,_) | Seq (l,_,_) | Assign (l,_,_)
| While (l,_,_) | Case (l,_,_) -> l

let degenerifyType (t: sailtype) (generics: sailtype dict) loc : sailtype E.t =
  let rec aux = function
  | Bool -> E.lift Bool
  | Int -> E.lift Int 
  | Float -> E.lift Float
  | Char -> E.lift Char
  | String -> E.lift String
  | ArrayType (t,s) -> let+ t = aux t in ArrayType (t, s)
  | CompoundType (_name, _tl)-> Result.error [ loc ,"todo compoundtype"]
  | Box t -> let+ t = aux t in Box t
  | RefType (t,m) -> let+ t = aux t in RefType (t,m)
  | GenericType t when generics = [] -> Result.error [loc,Printf.sprintf "generic type %s present but empty generics list" t]
  | GenericType n -> 
    begin
      match List.assoc_opt n generics with
      | Some GenericType t -> GenericType t |> E.lift
      | Some t -> aux t
      | None -> Result.error [loc,Printf.sprintf "generic type %s not present in the generics list" n]
    end
  in
  aux t

(*todo : generalize*)
let type_of_binOp (op:binOp) (operands_type:sailtype) : sailtype = match op with
  | Lt | Le | Gt | Ge | Eq | NEq | And | Or -> Bool
  | Plus | Mul | Div | Minus | Rem -> operands_type

module Pass = Pass.MakeFunctionPass(V)(
struct
  type in_body = Hir.Pass.out_body
  type out_body = statement

   
  let matchArgParam (l,arg: loc * sailtype) (m_param : sailtype) (generics : string list) (resolved_generics: sailtype dict) : (sailtype * sailtype dict) E.t =
    let rec aux (a:sailtype) (m:sailtype) (g: sailtype dict) = 
    match (a,m) with
    | Bool,Bool -> E.lift (Bool,g)
    | Int,Int -> E.lift (Int,g)
    | Float,Float -> E.lift (Float,g)
    | Char,Char -> E.lift (Char,g)
    | String,String -> E.lift (String,g)
    | ArrayType (at,s),ArrayType (mt,s') -> 
      if s = s' then
        let+ t,g = aux at mt g in ArrayType (t,s),g
      else
        Result.error [l,Printf.sprintf "array length mismatch : wants %i but %i provided" s' s]
    | CompoundType _, CompoundType _ -> Result.error [l, "todocompoundtype"]
    | Box _at, Box _mt -> Result.error [l,"todobox"]
    | RefType (at,am), RefType (mt,mm) -> if am <> mm then Result.error [l, "different mutability"] else aux at mt g
    | at,GenericType gt ->
     begin
        if List.mem gt generics then
          match List.assoc_opt gt g with
          | None -> E.lift (at,(gt,at)::g)
          | Some t -> if t = at then E.lift (at,g) else Result.error [l,"generic type mismatch"]
        else
          Result.error [l,Printf.sprintf "generic type %s not declared" gt]
      end
    | _ -> Result.error [l,Printf.sprintf "wants %s but %s provided" 
           (string_of_sailtype (Some m_param))
           (string_of_sailtype (Some arg))]
    in aux arg m_param resolved_generics  


  let check_call (name:string) (args: expression list) loc : sailtype option ER.t =
    let open MonadSyntax(ER) in
    let* env = ER.read in
    match THIREnv.get_method env name with
    | Some (_l,f) -> 
      begin
        (* if variadic, we just make sure there is at least minimum number of arguments needed *)
        let args = if f.variadic then List.filteri (fun i _ -> i < (List.length f.args)) args else args in
        let nb_args = List.length args and nb_params = List.length f.args in
        let* () = if nb_args <> nb_params 
          then 
            Result.error [loc, Printf.sprintf "unexpected number of arguments passed to %s : expected %i but got %i" name nb_params nb_args] |> ER.lift
          else ER.pure ()
        in
        let* resolved_generics = List.fold_left2 
        (
          fun g ca {ty=a;_} ->
            let* g in 
            let+ x = matchArgParam (extract_exp_loc_ty ca) a f.generics g |> ER.lift in
            snd x
        ) (ER.lift (Result.ok [])) args  f.args
        in
        (* List.iter (fun (s,r) -> Printf.fprintf stdout "generic %s resolved to %s\n" s (string_of_sailtype (Some r)) ) resolved_generics; *)
        begin
          match f.ret with
          | Some r ->  let+ r = degenerifyType r resolved_generics loc |> ER.lift in Some r
          | None -> None |> ER.pure
        end
      end

    | None -> Result.error [loc,"unknown method " ^ name] |> ER.lift

  let lower_expression (e : Hir.expression) (generics : string list): expression ES.t = 
  let open MonadSyntax(ES) in
  let rec aux (e:Hir.expression) : expression ES.t = 
    match e with
    | Variable (l,id) -> 
      let* v = ES.get in 
      begin
        match THIREnv.get_var v id with
        | Some (_,_,t) -> Variable((l,t),id) |> ES.pure
        | None -> Result.error [l, "unknown variable"] |> ES.lift
      end

      
    | Deref (l,e) -> let* e = aux e in
      begin
        match e with
        | Ref _ as t -> Deref((l,extract_exp_loc_ty t |> snd), e) |> ES.pure
        | _ -> Result.error [l,"can't deref a non-reference!"] |> ES.lift
      end

    | ArrayRead (l,array_exp,idx) -> let* array_exp = aux array_exp and* idx = aux idx in
      begin 
        match extract_exp_loc_ty array_exp |> snd with
        | ArrayType (t,_) -> 
          let* _ = matchArgParam (extract_exp_loc_ty idx) Int generics [] |> ES.lift in
          ArrayRead((l,t),array_exp,idx) |> ES.pure
        | _ -> Result.error [l,"not an array !"] |> ES.lift
      end

    | StructRead (l,_struct_exp,_field) -> Result.error [l,"todo: struct read"] |> ES.lift
    | Literal (l,li) -> let t = sailtype_of_literal li in Literal((l,t),li) |> ES.pure
    | UnOp (l,op,e) -> let+ e = aux e in UnOp ((l, extract_exp_loc_ty e |> snd),op,e)
    | BinOp (l,op,le,re) ->  
      let* le = aux le and* re = aux re in
      let lt = extract_exp_loc_ty le  and rt = extract_exp_loc_ty re |> snd in
      let+ t = matchArgParam lt rt generics [] |> ES.lift in
      let op_t = type_of_binOp op (fst t) in
      BinOp ((l,op_t),op,le,re)

    | Ref  (l,mut,e) -> let+ e = aux e in Ref((l,RefType(extract_exp_loc_ty e |> snd,mut)),mut, e)
    | ArrayStatic (l,el) -> 
      let* first_t = List.hd el |> aux  in
      let first_t = extract_exp_loc_ty first_t |> snd in
      let open MonadFunctions(ES) in
      let* el = listMapM (
        fun e -> let+ t = aux e in
        if extract_exp_loc_ty t |> snd = first_t then t |> E.lift else Result.error [l,"mixed type array"] 
      ) el in 
      let open MonadSyntax(E) in
      let open MonadFunctions(E) in
      (let+ el = sequence el in
      let t = ArrayType (first_t, List.length el) in ArrayStatic((l,t),el)) |> ES.lift


    | StructAlloc (l,_name,_fields) -> Result.error [l, "todo: struct alloc"] |> ES.lift
    | EnumAlloc (l,_name,_el) -> Result.error [l, "todo: enum alloc"] |> ES.lift

    in aux e


  let lower_function (decl:in_body function_type) (env:THIREnv.t) : out_body Error.result = 
    let open MonadSyntax(ES) in 

    let rec aux (s:in_body) : out_body ES.t = 
      let open MonadFunctions(ES) in
      let open MonadOperator(MonadOption.M) in
      match s with
      | DeclVar (l, mut, id, t, (optexp : Hir.expression option)) -> 
        let optexp = (optexp  >>| fun e -> lower_expression e decl.generics) in 
        begin
          let* var_type =             
            match (t,optexp) with
            | (Some t,Some e) -> let* e in let tv = extract_exp_loc_ty e in let+ a = matchArgParam tv t decl.generics [] |> ES.lift in fst a
            | (Some t, None) -> ES.pure t
            | (None,Some t) -> let+ t in extract_exp_loc_ty t |> snd
            | (None,None) -> Result.error [l,"can't infere type with no expression"] |> ES.lift
            
          in
          let* () = ES.update (fun st -> THIREnv.declare_var st id l (l,mut,var_type) ) in 
          match optexp with
          | None -> DeclVar (l,mut,id,Some var_type,None) |> ES.pure
          | Some e -> let+ e in DeclVar (l,mut,id,Some var_type,Some e)
        end
        
      | Assign(loc, e1, e2) -> 
        let* e1 = lower_expression e1 decl.generics
        and* e2 = lower_expression e2 decl.generics in
        let* _ = matchArgParam (extract_exp_loc_ty e1) (extract_exp_loc_ty e2 |> snd) [] [] |> ES.lift in
        Assign(loc, e1, e2) |> ES.pure

      | Seq(loc, c1, c2) -> 
        let* c1 = aux c1 in
        let+ c2 = aux c2 in
        Seq(loc, c1, c2) 


      | If(loc, cond_exp, then_s, else_s) -> 
        let* cond_exp = lower_expression cond_exp decl.generics in
        let* _ = matchArgParam (extract_exp_loc_ty cond_exp) Bool [] [] |> ES.lift in
        let* res = aux then_s in
        begin
        match else_s with
        | None -> If(loc, cond_exp, res, None) |> ES.pure
        | Some s -> let+ s = aux s in If(loc, cond_exp, res, Some s)
        end

      | While(loc,e,c) -> 
        let* e = lower_expression e decl.generics in
        let+ t = aux c in
        While(loc,e,t)

      | Case(loc, e, _cases) ->
        let+ e = lower_expression e decl.generics in
        Case (loc, e, [])


      | Invoke(loc, var, id, el) -> (* todo: handle var *) fun e ->
        let open MonadSyntax(E) in
        let* el,e' = listMapM (Fun.flip lower_expression decl.generics) el e in 
        let+ _ = check_call id el loc e' in
        Invoke(loc, var, id,el),e'

      | Return(l, None) as r -> 
        if decl.ret = None then r |> ES.pure else Result.error [l,"void return"] |> ES.lift

      | Return(l, Some e) ->
        if decl.bt <> Pass.BMethod then 
          Result.error [l, Printf.sprintf "process %s : processes can't return non-void type" decl.name] |> ES.lift
        else
          begin
          match decl.ret with 
          | None -> Result.error [l,"non-void return"] |> ES.lift
          | Some r ->
            let* e = lower_expression e decl.generics in
            let+ _ = matchArgParam (extract_exp_loc_ty e) r decl.generics [] |> ES.lift in
            Return(l, Some e)
          end

      | Block (loc, c) -> fun s ->
        let open MonadSyntax(E) in
           let+ res,te' = aux c (THIREnv.new_frame s) in Block(loc,res),te'
      | Skip (loc) -> Skip(loc) |> ES.pure

      | s when decl.bt = Pass.BMethod -> 
        Result.error [extract_statements_loc s, Printf.sprintf "method %s : methods can't contain reactive statements" decl.name] |> ES.lift


      | Watching(loc, s, c) -> let+ res = aux c in Watching(loc, s, res)
      | Emit(loc, s) -> Emit(loc,s) |> ES.pure
      | Await(loc, s) -> When(loc, s, Skip(loc)) |> ES.pure
      | When(loc, s, c) -> let+ res = aux c in When(loc, s, res)
      | Run(loc, id, el) -> fun e ->
        let open MonadSyntax(E) in
        let* el,e = listMapM (Fun.flip lower_expression decl.generics) el e in
        let+ _ = check_call id el loc e in
        Run(loc, id, el),e

      | Par(loc, c1, c2) -> 
        let* c1 = aux c1 in
        let+ c2 = aux c2 in
        Par(loc, c1, c2)

      | DeclSignal(loc, s) -> DeclSignal(loc, s) |> ES.pure


    in 
    let open MonadSyntax(E) in
    let+ res = aux decl.body env in fst res
  end
)