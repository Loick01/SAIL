open Common
open TypesCommon
open IrMir

module E = Common.Error
open Monad.MonadSyntax(E.Logger)
open Monad.MonadFunctions(E.Logger)


module Pass = Pass.Make( struct
  let name = "Resolve imports"
  type in_body = Mir.Pass.out_body
  type out_body  = in_body

  let read_imports (imports : ImportSet.t) : (string * in_body SailModule.t) list  = 
    List.map (fun i ->  
      Logs.debug (fun m -> m "reading mir for import '%s' (%s)" i.mname i.dir); 
      i.dir,In_channel.with_open_bin (i.dir ^ i.mname ^ Constants.mir_file_ext) Marshal.from_channel
    ) (ImportSet.elements imports)

  let set_fcall_source (m:in_body SailModule.t) : in_body SailModule.t E.Logger.t = 
    let imports = read_imports m.imports in

    let+ libs,methods = 
      ListM.fold_left_map (fun libs f -> 
      match f.m_body with
      | Right b -> 
        (libs,{m_proto={f.m_proto with name = "_" ^ m.md.name ^"_" ^ f.m_proto.name}; m_body=Either.Right b}) |> E.Logger.pure
      | Left (realname,lib) -> (* extern method, give it its realname for codegen *)
        let m_proto = {f.m_proto with name=realname} in
        let libs = FieldSet.add_seq (List.to_seq lib) libs in
        return (libs,{f with m_proto}) (* add lib required by ffi *)
      ) FieldSet.empty m.methods 
    in
    (* the imports of my imports are my imports and same goes for the libs *)
    let libs,imports =  List.fold_left (
      fun (libs,imports) (_,(i:'a SailModule.t)) -> 
        FieldSet.union libs i.md.libs , ImportSet.union i.imports imports
      ) (libs,ImportSet.empty) imports in

      (* we add our imports last *)
      (* 
        fixme : the way this works is not correct : it relies on recompiling every dependencies and giving them an order based on how deep the imports are from the original module
        if an other module requires the same dependency and does not recompile them, the compilation order from the previous one will still be there...
      *)

      let imports = ImportSet.(diff m.imports imports  |> union imports ) in 
    
    {m with methods ; imports; md={m.md with libs}}

  let transform (smdl : in_body SailModule.t)  : out_body SailModule.t E.Logger.t =
    Logs.debug (fun m -> m "imports : %s" (String.concat " " (List.map (fun i -> i.mname) (ImportSet.elements smdl.imports))));
    set_fcall_source smdl
end
)