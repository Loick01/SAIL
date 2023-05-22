open SailParser
open CliCommon
open Cmdliner
open Llvm
open Llvm_target
open Common
open IrThir
open IrHir
open IrMir
open Compiler
open TypesCommon
(* open CompilerCommon *)
open Codegen
open CompilerEnv
let error_handler err = "LLVM ERROR: " ^ err |> print_endline


let moduleToIR (m:Mir.Pass.out_body SailModule.t) (dump_decl:bool) : llmodule  = 
  let module FieldMap = Map.Make (String) in

  let llc = global_context () in
  let llm = create_module llc (m.name ^ ".sl") in

  let decls = get_declarations m llc llm in

  if dump_decl then failwith "not done yet";

  let env = SailEnv.empty decls in

  DeclEnv.iter_methods (fun name m -> methodToIR llc llm m env name |> Llvm_analysis.assert_valid_function ) decls;

  match Llvm_analysis.verify_module llm with
  | None -> llm
  | Some reason -> Logs.err (fun m -> m "LLVM : %s" reason); llm


let init_llvm (llm : llmodule) : (Target.t * TargetMachine.t) =
  Llvm_all_backends.initialize (); 
  let target_triple = Target.default_triple () in
  let target = Target.by_triple target_triple in 
  set_target_triple target_triple llm;
  let machine = TargetMachine.create ~triple:target_triple target ~reloc_mode:PIC in
  set_data_layout (TargetMachine.data_layout machine |> DataLayout.as_string) llm;
  (target,machine)


let add_passes (pm : [`Module] PassManager.t) : unit  = 
  (* seems to be deprecated
    TargetMachine.add_analysis_passes pm machine; *)

  (* base needed for other passes *)
  Llvm_scalar_opts.add_memory_to_register_promotion pm;
  (* eleminates redundant values and loads *)
  Llvm_scalar_opts.add_gvn pm;
  (* reassociate binary expressions *)
  Llvm_scalar_opts.add_reassociation pm;
  (* dead code elimination, basic block merging and more *)
  Llvm_scalar_opts.add_cfg_simplification pm;
  
  Llvm_ipo.add_global_optimizer pm;
  Llvm_ipo.add_constant_merge pm;
  Llvm_ipo.add_function_inlining pm


let compile ?(is_lib = false) (llm:llmodule) (module_name : string) (target, machine) : int =
  let objfile = module_name ^ ".o" in 
  if Target.has_asm_backend target then
    begin
      TargetMachine.emit_to_file llm ObjectFile objfile machine;
      if not is_lib then 
        begin
        if (Option.is_none (lookup_function "main" llm)) then failwith ("no Main process found, can't compile as executable");
        "clang " ^ objfile ^ " -o " ^ module_name |> Sys.command |> ignore;
        "rm " ^ objfile |>  Sys.command
        end
      else 0
    end
  else
    failwith ("target " ^ target_triple  llm ^ "doesn't have an asm backend, can't generate object file!")


let execute (llm:llmodule) = 
  let _ = match lookup_function "main" llm with
  | Some m -> m
  | None -> failwith "can't execute : no main process found" 
  in
  match Llvm_executionengine.initialize () with
  | false -> failwith "unable to start the execution engine"
  | _ -> ();
  let ee = Llvm_executionengine.create llm in
  let open Ctypes in 
  let main_addr = Llvm_executionengine.get_function_address "main" (static_funptr (void @-> returning void)) ee in 
  let m_t =  (void @-> returning void) in
  let main  = coerce (static_funptr m_t) (Foreign.funptr m_t) main_addr
  in 
  main ();
  Llvm_executionengine.dispose ee (* implicitely disposes the module *)


let _check_imports imports : unit Error.Logger.t = 
  let open Monad.MonadSyntax(Error.Logger) in 
  let open TypesCommon in 
  List.iter (fun s -> print_newline () ; print_string s.mname ; print_newline ()) imports;
  return ()


let find_file_opt ?(maxdepth = 10) (f:string)  : string option = (* recursively find the file *)
  let open Sys in 
  let open Filename in
  let rec aux dir depth = 
    if depth > maxdepth then None else
      let dirs,files = readdir dir |> Array.to_list |> List.map (concat dir) |> List.partition is_directory 
      in
      match List.find_opt (fun f' -> String.equal f (basename f')) files with
      | Some f -> Some f
      | None -> List.fold_left (
          fun r d -> match r with 
          | Some f -> Some f 
          | None -> aux d (depth+1)
        ) None dirs
  in aux (getcwd ()) 0 


let apply_passes = fun m ->
  m
  |> Hir.Pass.transform 
  |> Thir.Pass.transform 
  |> Mir.Pass.transform 
  |> CompilerCommon.MainTransformPass.transform 


  let merge_envs (e1:SailModule.DeclEnv.t) (e2:SailModule.DeclEnv.t) : SailModule.DeclEnv.t = 
    let merge =TypesCommon.FieldMap.union
    in
    {
      methods = merge (fun m _ _ -> failwith @@ "declaration clash " ^ m) e1.methods e2.methods;
      processes = merge (fun m _ _ -> failwith @@ "declaration clash "  ^ m ) e1.processes e2.processes;
      structs = merge  (fun _ _ _ -> failwith "declaration clash") e1.structs e2.structs;
      enums = merge  (fun _ _ _ -> failwith "declaration clash")  e1.enums e2.enums;
    }

  let merge_modules sm1 sm2 =
    let open SailModule in
    let open Monad.MonadSyntax(Error.Logger) in
    let name = sm2.name 
    and declEnv = merge_envs sm1.declEnv sm2.declEnv
    and methods = sm1.methods @ sm2.methods
    and processes=sm1.processes @ sm2.processes
    and builtins = sm1.builtins in 
   {name; declEnv; methods; processes;builtins}


let sailor (files: string list) (intermediate:bool) (jit:bool) (noopt:bool) (dump_decl:bool) () = 
  let open Monad.MonadSyntax(Error.Logger) in
  let open Monad.MonadFunctions(Error.Logger) in

  enable_pretty_stacktrace ();
  install_fatal_error_handler error_handler;

  let process_mir sail_module fcontent is_lib : AstMir.mir_function SailModule.t Error.Logger.t =
    let+ m = Error.Logger.iter_warnings (apply_passes sail_module) (Error.print_errors fcontent) in  
    (* let mir_debug = m.name ^ "_mir.debug" |> open_out in *)
    let mir_out = m.name ^ "_mir" |> open_out  in
    Marshal.to_channel mir_out m [];
    (* Format.fprintf (Format.formatter_of_out_channel mir_debug) "%a" Pp_mir.ppPrintModule m; *)
    (* close_out mir_debug; *)
    close_out mir_out;

    let llm = moduleToIR m dump_decl in
    let tm = init_llvm llm in

    if not noopt then 
      begin
        let open PassManager in
        let pm = create () in add_passes pm;
        let res = run_module llm pm in
        Logs.debug (fun m -> m "pass manager executed, module modified : %b" res);
        dispose pm
      end
    ;

    if intermediate then print_module (m.name ^ ".ll") llm;

    if not (intermediate || jit) then
      begin
        let ret = compile llm m.name tm ~is_lib in
        if ret <> 0 then
          (Fmt.str "clang couldn't execute properly (error %i)" ret |> failwith);
      end;
    if jit then execute llm else dispose_module llm;
    m
  in

  let rec process_file f (closed: (string*loc) list) ~is_lib = 
    let module_name = Filename.chop_extension (Filename.basename f) in
    let fcontent,imports,sail_module = Parsing.parse_program f in
    Logs.debug (fun m -> m "compiling module '%s'" module_name);
    let* m  = sail_module in 

    (* for each import,  we check if a corresponding mir file exists.
      - if it exists, we get its corresponding sail_module 
      - if not, we look for a source file and compile it *)

        let* imports = listMapM (
        fun (i : import ) : AstMir.mir_function SailModule.t Error.Logger.t -> 
          let* () = 
            let import_loc = List.assoc_opt i.mname closed in
            match import_loc with
            | Some loc ->  Error.Logger.throw @@
              if i.mname = module_name then 
                Error.make i.loc "a module cannot import itself" 
              else 
                Error.make i.loc "dependency cycle !" 
                ~hint:(Some (Some loc, "other import"))
            | None -> return ()
          in
          match find_file_opt @@ i.mname ^ "_mir" with
          | Some f -> 
            let mir_in = open_in f in
             return (Marshal.from_channel mir_in)
          | None -> 
            let source = i.mname ^ ".sl" in
            begin
              match find_file_opt source with
              | Some d -> process_file d ((module_name,i.loc)::closed) ~is_lib:true
              | None ->  Error.Logger.throw @@ Error.make i.loc "import not found"
            end
        ) imports in 
        let x = List.fold_left merge_modules SailModule.emptyModule imports in (* fixme *)
        let declEnv = merge_envs m.declEnv x.declEnv in
        SailModule.DeclEnv.print_declarations declEnv;
        process_mir (return {m with declEnv}) fcontent is_lib


  in 

  try 
  match listIterM (fun f -> let+ _mir = process_file f [] ~is_lib:false  in ()) files with
  | Ok _,_ -> `Ok ()
  | Error e,errs -> 
    Error.print_errors (open_in (fst e.where).pos_fname |> In_channel.input_all ) @@ e::errs;
    `Error(false, "compilation aborted") 
    
  with
  | e -> `Error (false,Printexc.to_string e)

let jit_arg =
  let doc = "execute using the LLVM JIT compiler" in 
   Arg.(value & flag & info ["run"] ~doc)

let intermediate_arg = intermediate_arg "save the LLVM IR"

let noopt_arg = 
  let doc = "do not use any optimisation pass" in
  Arg.(value & flag & info ["no-opt"] ~doc)


let dump_decl_arg =
  let doc = "dump the declarations" in 
  let info = Arg.info ["D"; "dump_decl"] ~doc in
  Arg.flag info |> Arg.value
  
  
let cmd =
  let doc = "SaiLOR, the SaIL cOmpileR" in
  let info = Cmd.info "sailor" ~doc in
  Cmd.v info Term.(ret (const sailor $ sailfiles_arg $ intermediate_arg $ jit_arg $ noopt_arg $ dump_decl_arg $ setup_log_term))

let () = Cmd.eval cmd |> exit
