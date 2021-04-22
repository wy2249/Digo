open Llvm
open Ast
open Sast

module StringMap = Map.Make(String)

let translate(functions) =
  let context = global_context () in
  let the_module = create_module context "Digo" in
  let _ = set_data_layout "e-m:e-i64:64-f80:128-n8:16:32:64-S128" the_module in
  let _ = set_target_triple "x86_64-pc-linux-gnu" the_module in 

  let i64_t      = i64_type    context 
    and i8_t       = i8_type     context
    and i1_t       = i1_type     context
    and float_t    = double_type context
    (*and string_t   = array_type (i8_type context) 100     assume each string is less than 100 character*)
    and void_t     = void_type   context in
    
    let ltype_of_typ = function
        IntegerType  -> i64_t
      | FloatType    -> float_t
      | BoolType     -> i1_t
      | StringType   -> pointer_type i8_t     
      | SliceType(x)    -> pointer_type i8_t
      | FutureType   -> pointer_type i8_t   (*needs work*)
      | VoidType     -> void_t
    in

(* built-in function *)
  let printf_t = 
      var_arg_function_type void_t [|(pointer_type i8_t)|]  in 
  let printf =
      declare_function "print" printf_t the_module in 

  let printfln_t = 
      var_arg_function_type void_t [|(pointer_type i8_t)|]  in
  let printfln =
      declare_function "println" printfln_t the_module in

  let show_string (_,ex)= match ex with
    SString(ex)  -> ex
  | _           -> ""                    in    

  (*let printString_t= 
    function_type void_t [|(pointer_type i8_t)|] in
  let printString=
    declare_function "printString" (printString_t) the_module in  *)

    (* String related functions *)
  let createString_t= 
      function_type (pointer_type i8_t) [|pointer_type i8_t|] in
  let createString=
      declare_function "CreateString" (createString_t) the_module in
  
  let createEmptyString_t= 
        function_type (pointer_type i8_t) [|  |] in
  let createEmptyString=
        declare_function "CreateEmptyString" (createEmptyString_t) the_module in

  let addString_t= 
      function_type (pointer_type i8_t) [|pointer_type i8_t; pointer_type i8_t|] in
  let addString=
      declare_function "AddString" (addString_t) the_module in
  
  let compareString_t= 
        function_type (i64_t) [|pointer_type i8_t; pointer_type i8_t|] in
  let compareString=
        declare_function "CompareString" (compareString_t) the_module in
  
  let cloneString_t= 
        function_type (pointer_type i8_t) [|pointer_type i8_t|] in
  let cloneString=
        declare_function "CloneString" (cloneString_t) the_module in
  
  let lenString_t= 
      function_type (i64_t) [|pointer_type i8_t|] in
  let lenString=
      declare_function "GetStringSize" (lenString_t) the_module in
  
    let createSlice_t = 
        function_type (pointer_type i8_t) [|i64_t|] in
    let createSlice = 
        declare_function "CreateSlice" (createSlice_t) the_module in

    let sliceAppend_t =
        var_arg_function_type (pointer_type i8_t) [|(pointer_type i8_t)|] in
    let sliceAppend = 
        declare_function "SliceAppend" sliceAppend_t the_module in 

    let sliceSlice_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t);i64_t;i64_t|] in
    let sliceSlice = 
        declare_function "SliceSlice" (sliceSlice_t) the_module in
  
    let getSliceSize_t =
        function_type i64_t [|(pointer_type i8_t)|] in
    let getSliceSize = 
        declare_function "GetSliceSize" (getSliceSize_t) the_module in      
  
    let setSliceIndexDouble_t =
        function_type float_t [|(pointer_type i8_t);i64_t;float_t|] in
    let setSliceIndexDouble = 
        declare_function "SetSliceIndexDouble" (setSliceIndexDouble_t) the_module in
  
    let setSliceIndexFuture_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t);i64_t;(pointer_type i8_t)|] in
    let setSliceIndexFuture = 
        declare_function "SetSliceIndexFuture" (setSliceIndexFuture_t) the_module in
  
    let setSliceIndexString_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t);i64_t;(pointer_type i8_t)|] in
    let setSliceIndexString = 
        declare_function "SetSliceIndexString" (setSliceIndexString_t) the_module in
  
    let setSliceIndexInt_t =
        function_type i64_t [|(pointer_type i8_t);i64_t;i64_t|] in
    let setSliceIndexInt = 
        declare_function "SetSliceIndexInt" (setSliceIndexInt_t) the_module in
  
    let getSliceIndexDouble_t =
        function_type float_t [|(pointer_type i8_t);i64_t|] in
    let getSliceIndexDouble = 
        declare_function "GetSliceIndexDouble" (getSliceIndexDouble_t) the_module in
  
    let getSliceIndexFuture_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t);i64_t|] in
    let getSliceIndexFuture = 
        declare_function "GetSliceIndexFuture" (getSliceIndexFuture_t) the_module in
  
    let getSliceIndexString_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t);i64_t|] in
    let getSliceIndexString = 
        declare_function "GetSliceIndexString" (getSliceIndexString_t) the_module in
  
    let getSliceIndexInt_t =
        function_type i64_t [|(pointer_type i8_t);i64_t|] in
    let getSliceIndexInt = 
        declare_function "GetSliceIndexInt" (getSliceIndexInt_t) the_module in

    let cloneSlice_t =
        function_type (pointer_type i8_t) [|(pointer_type i8_t)|] in 
    let cloneSlice =
        declare_function "CloneSlice" (cloneSlice_t) the_module in 

    let readFile_t= 
          function_type (pointer_type i8_t) [|pointer_type i8_t|] in
    let readFile=
          declare_function "ReadFile" (readFile_t) the_module in
  
  
(*usr function*)

  let function_decls = Hashtbl.create 5000 in
  let function_delc fdecl=
      let name = fdecl.sfname
      and argument_types = 
        Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fdecl.sformals) in
      let stype =
        match fdecl.styp with
        [VoidType] -> void_t
        | _ -> 
        struct_type context (Array.of_list (List.map ltype_of_typ fdecl.styp)) 
      in
      let ftype = function_type stype argument_types 
      in
      Hashtbl.replace function_decls name (define_function name ftype the_module,fdecl) in
  let _ = List.iter function_delc functions in

  let find_func s = 
      if Hashtbl.mem function_decls s then Hashtbl.find function_decls s
      else raise (Failure ("unrecognized function " ^ s))
    in

  let build_function_body fdecl= 
      let (the_function,_) = find_func fdecl.sfname (*StringMap.find fdecl.sfname function_decls*)
      in
      let builder = 
        builder_at_end context (entry_block the_function) in
        
      let futures = Hashtbl.create 5000 in
      let func_of_future n = 
        let fname = if Hashtbl.mem futures n then Hashtbl.find futures n
        else raise (Failure("Err: undeclared future object " ^ n)) in
        find_func ("digo_linker_await_func_"^fname)
      in
      let local_vars = Hashtbl.create 5000 in
      let add_formal (t, n) p =
        set_value_name n p;
        let local = build_alloca (ltype_of_typ t) n builder in ignore (build_store p local builder); 
        Hashtbl.replace local_vars n local 
      in
      ignore (List.iter2 add_formal fdecl.sformals (Array.to_list (params the_function)));

      let add_var_decl id llvalue = Hashtbl.add local_vars id llvalue
      in

      let lookup n = if Hashtbl.mem local_vars n then Hashtbl.find local_vars n
        else raise (Failure("cannot find symbol in local_vars"))
      in
      let get_type_in_slicetype = function
            SliceType(StringType)      ->  StringType
          | SliceType(IntegerType)     ->  IntegerType
          | SliceType(FloatType)       ->  FloatType
          | SliceType(FutureType)      ->  FutureType
          | _                          ->  raise(Failure("invalide slice type"))
      in
      let get_slice_argument_number = function
        StringType  -> const_int i64_t 1
      | IntegerType -> const_int i64_t 3
      | FloatType   -> const_int i64_t 4
      | FutureType  -> const_int i64_t 6
      | _           -> raise(Failure("invalide slice type"))
      in

      let rec expr builder (e_typl,e) = match e with
          SEmptyExpr                                                          ->  const_int i1_t 1       (*cannot changed since for loop needs boolean value*)
        | SBinaryOp(ex1,op,ex2) when List.hd e_typl = FloatType               ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          (match op with
          Add       ->  build_fadd
          | Sub       ->  build_fsub
          | Mul       ->  build_fmul
          | Div       ->  build_fdiv
          | Mod       ->  build_frem 
          | _         ->  raise(Failure("binary operation is invalid and should be rejected in semant"))
          ) e1 e2 "tmp" builder        
        | SBinaryOp(ex1,op,ex2) when List.hd e_typl = IntegerType             ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          (match op with
          Add       ->  build_add
          | Sub       ->  build_sub
          | Mul       ->  build_mul
          | Div       ->  build_sdiv
          | Mod       ->  build_srem 
          | _         ->  raise(Failure("binary operation is invalid and should be rejected in semant"))          
          ) e1 e2 "tmp" builder               
        | SBinaryOp(ex1,op,ex2) when List.hd e_typl = BoolType                           ->     
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in         
          (match ex1 with
            ([FloatType],_)                                     ->
              let condition = (match op with
                LessThan    ->  build_fcmp Fcmp.Olt
              | LessEqual   ->  build_fcmp Fcmp.Ole
              | GreaterThan   ->  build_fcmp Fcmp.Ogt
              | GreaterEqual  ->  build_fcmp Fcmp.Oge
              | IsEqual     ->  build_fcmp Fcmp.Oeq
              | IsNotEqual  ->  build_fcmp Fcmp.One
              ) e1 e2 "tmp" builder in
              build_select condition (const_float float_t 1.0) (const_float float_t 0.0) "booleantofloat" builder
          | ([IntegerType],_)                                   ->
              let condition = (match op with
                LessThan    ->  build_icmp Icmp.Slt
              | LessEqual   ->  build_icmp Icmp.Sle
              | GreaterThan   ->  build_icmp Icmp.Sgt
              | GreaterEqual  ->  build_icmp Icmp.Sge
              | IsEqual     ->  build_icmp Icmp.Eq
              | IsNotEqual  ->  build_icmp Icmp.Ne
              ) e1 e2 "tmp" builder in
              build_select condition (const_int i64_t 1) (const_int i64_t 0) "booleantoint" builder
          | ([BoolType],_)                                      ->
              let condition = (match op with
              | LogicalAnd  ->  build_and
              | LogicalOr   ->  build_or
              ) e1 e2 "tmp" builder in
              build_select condition (const_int i64_t 1) (const_int i64_t 0) "booleantoint" builder
          | ([StringType],_)                                     ->
              let cmpllvm = build_call compareString [|e1; e2|] "cmpstr" builder in 
              let condition = (match op with
                IsEqual  ->  
                build_icmp Icmp.Eq 
              | LessThan  ->  
                build_icmp Icmp.Slt 
              | LessEqual ->
                build_icmp Icmp.Sle 
              | GreaterThan  ->  
                build_icmp Icmp.Sgt 
              | GreaterEqual  -> 
                build_icmp Icmp.Sge 
              | _         ->  raise(Failure("binary operation is invalid and should be rejected in semant"))
              ) cmpllvm (const_int i64_t 0) "cmpstr_bool" builder in
              build_select condition (const_int i64_t 1) (const_int i64_t 0) "booleantoint" builder
          )          
        | SBinaryOp(ex1,op,ex2) when (List.hd e_typl) = StringType                       ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          (match op with
            Add ->  build_call addString [|e1; e2|] "addstr" builder 
          | _   ->  raise(Failure("codegen error: semant should reject any operation between string except add"))
          )  
        | SUnaryOp(op,((ex1_typl,_) as ex1))                                                     ->
          let e_ = expr builder ex1 in
          (match op with
            LogicalNot                               ->  build_not                                              
          | Negative when ex1_typl = [IntegerType]   ->  build_neg
          | Negative when ex1_typl = [FloatType]     ->  build_fneg
          | _ -> raise (Failure("unary operation is invalid and should be rejected in semant"))
          ) e_ "tmp" builder
        | SAssignOp(var,ex1)                                                  ->    (*multi return values of function assignop works latter *)      
          let e_ = expr builder ex1 in
          (match var with
              ([IntegerType],SSliceIndex(e1,e2))  -> 
              (match e1 with
              | (_,SNamedVariable(s)) -> build_call setSliceIndexInt [|(expr builder e1);(expr builder e2);e_|] "setsliceidxn" builder
              | _ -> raise(Failure("SAssignOp error: should be rejected in semant"))
              )
            | ([FloatType],SSliceIndex(e1,e2))    -> 
              (match e1 with
              | (_,SNamedVariable(s)) -> build_call setSliceIndexDouble [|(expr builder e1);(expr builder e2);e_|] "setsliceidxf" builder
              | _ -> raise(Failure("SAssignOp error: should be rejected in semant")) 
              )
            | ([FutureType],SSliceIndex(e1,e2))   -> 
              (match e1 with
              | (_,SNamedVariable(s)) -> build_call setSliceIndexFuture [|(expr builder e1);(expr builder e2);e_|] "setsliceidxF" builder
              | _ -> raise(Failure("SAssignOp error: should be rejected in semant")) 
              )            
            | ([StringType],SSliceIndex(e1,e2))    -> 
              (match e1 with
              | (_,SNamedVariable(s)) ->  build_call setSliceIndexString [|(expr builder e1);(expr builder e2);e_|] "setsliceidxs" builder
              | _ -> raise(Failure("SAssignOp error: should be rejected in semant")) 
              )            
            | (_,SNamedVariable(s)) -> 
              let (typl, _) = ex1 in
              ( match List.hd typl with
                StringType ->
                  let clonellvm = build_call cloneString [|e_|] "clonestr" builder in
                  ignore(build_store clonellvm (lookup s) builder); clonellvm
                | FutureType ->
                  let (_,SFunctionCall(fname,_)) = ex1 in
                  Hashtbl.add futures s fname;
                  ignore(build_store e_ (lookup s) builder); e_
                | SliceType(x) -> 
                  let clonellvm = build_call cloneSlice [|e_|] "cloneslice" builder in
                  ignore(build_store clonellvm (lookup s) builder); e_ 
                | _ -> 
                  ignore(build_store e_ (lookup s) builder); e_
              )
            | _ -> raise(Failure("SAssignOp error: should be rejected in semant"))
          )
        | SLen (e) ->
            let (typl, _) = e in
            let e_ = expr builder e in
            (match typl with
            [FloatType] -> build_call getSliceSize [|e_|] "slicelen" builder
            | _ -> build_call lenString [| e_ |] "str_len" builder 
            )
        | SAwait(s)                                                  -> 
          let (await_llvm,fd) = func_of_future s in
          let future_arg = build_load (lookup s) s builder  in 
          let result = "await_"^fd.sfname^"_result" in
          build_call await_llvm (Array.of_list [future_arg]) result builder
     
        | SRead(e) ->
            let e_ = expr builder e in 
            build_call readFile [| e_ |] "read_file" builder
        | SFunctionCall("print",el)                                        -> 
            let exarr= Array.of_list (List.map (fun x -> expr builder x) el) in 
            build_call printf exarr "" builder
        | SFunctionCall("println",el)                                        -> 
            let exarr= Array.of_list (List.map (fun x -> expr builder x) el) in 
            build_call printfln exarr "" builder 
        | SAppend(args)                                    ->
            let e1 = expr builder (List.hd args) in 
            let e2 = expr builder (List.nth args 1) in 
            build_call sliceAppend [|e1;e2|] "initslice" builder
        | SFunctionCall(f_name,args)                                           ->             
          let (fdef,fd) = find_func f_name in
          let llargs = List.map (expr builder) args in 
          let result = (match fd.styp with [VoidType] -> "" | _ -> f_name ^ "_result") in 
          let build_func_call = match fd.sann with
            FuncNormal -> build_call fdef (Array.of_list llargs) result builder
            | _ ->
              let return_types = Array.of_list (List.map (fun t -> ltype_of_typ t) fd.styp) in
              let stype = struct_type context return_types in
              let await_ftyp_t = function_type stype [|(pointer_type i8_t)|] in
              let await_llvm = declare_function ("digo_linker_await_func_"^f_name) await_ftyp_t the_module in
              Hashtbl.add function_decls ("digo_linker_await_func_"^f_name) (await_llvm,fd);

              let argument_types = Array.of_list (List.map (fun (t,_) -> ltype_of_typ t) fd.sformals) in
              let new_ftyp_t = function_type (pointer_type i8_t) argument_types in
              let new_fdef = declare_function ("digo_linker_async_call_func_"^f_name) new_ftyp_t the_module in
                build_call new_fdef (Array.of_list llargs) result builder
          in build_func_call
        | SInteger(ex)                                                         ->  const_int i64_t ex
        | SFloat(ex)                                                           ->  const_float float_t ex
        | SString(ex)  ->  
        (* build_global_stringptr ex "str" builder *)
          let current_ptr = build_global_stringptr ex "createstr_ptr" builder in
          build_call createString [|current_ptr|] "createstr" builder
        | SBool(ex)                                                            ->  const_int i1_t (if ex then 1 else 0)
        | SNamedVariable(n)                                                    ->  build_load (lookup n) n builder  
        | SSliceLiteral(built_typ,len,e1_l)                                    ->  
        let tp = get_type_in_slicetype built_typ in 
        let arg_sn = get_slice_argument_number tp in 
        let empty_slice = build_call createSlice [|arg_sn|] "createslice" builder in
        (
        match tp  with 
          StringType  -> 
            let append_string slc e1 = 
            let e = expr builder e1 in
            build_call sliceAppend [|slc;e|] "initslices" builder 
            in
            List.fold_left append_string empty_slice e1_l 
        | IntegerType -> 
            let append_integer slc e1 = 
            let e = expr builder e1 in
            build_call sliceAppend [|slc;e|] "initslicen" builder 
            in
            List.fold_left append_integer empty_slice e1_l 
        | FloatType   -> 
            let append_float slc e1 = 
            let e = expr builder e1 in
            build_call sliceAppend [|slc;e|] "initslicef" builder 
            in
            List.fold_left append_float empty_slice e1_l 
        | FutureType  -> 
            let append_future slc e1 = 
            let e = expr builder e1 in
            build_call sliceAppend [|slc;e|] "initslicenF" builder 
            in
            List.fold_left append_future empty_slice e1_l           
        | _           -> raise(Failure("invalide slice type"))   
        )      
      | SSliceIndex(ex1,ex2)                                                 ->  
        let rt = List.hd e_typl in
        let ex1' = expr builder ex1 in 
        let ex2' = expr builder ex2 in 
        (match rt with
          StringType        ->  build_call getSliceIndexString [|ex1';ex2'|] "findsliceindexs" builder
        | IntegerType       ->  build_call getSliceIndexInt [|ex1';ex2'|] "findsliceindexn" builder
        | FloatType         ->  build_call getSliceIndexDouble [|ex1';ex2'|] "findsliceindexf" builder
        | FutureType        ->  build_call getSliceIndexFuture [|ex1';ex2'|] "findsliceindexF" builder
        | _                 ->  raise(Failure("sliceindex error: should be rejected in semant"))
        )
      | SSliceSlice(ex1,ex2,ex3)                                             ->  
        let ex1' = expr builder ex1 in
        let start_idx = match ex2 with
        | ([IntegerType],_)  -> expr builder ex2  
        | ([VoidType],_)     -> const_int i64_t 0
        | _ -> raise(Failure("sliceslice error: should be rejected in semant"))
        in
        let end_idx = match ex3 with
        | ([IntegerType],_)  -> expr builder ex3  
        | ([VoidType],_)     -> 
           let slen = build_call getSliceSize [|ex1'|] "totallen" builder in 
           build_sub slen (const_int i64_t 1) "getlastindex" builder
        | _ -> raise(Failure("sliceslice error: should be rejected in semant"))
        in          
        build_call sliceSlice [|ex1';start_idx;end_idx|] "SliceSlice"builder
    in

      let add_terminal builder instr  =
        match block_terminator (insertion_block builder) with 
          Some _ -> ()
        | None -> ignore (instr builder) in 

      let rec stmt builder = function  
        SEmptyStatement                                                        ->  builder
      | SBlock(sl)                                                             ->  
        List.fold_left stmt builder sl
      | SIfStatement(ex, s1, s2)                                               ->  
        let bool_val = 
        (match ex with
          ([BoolType],SBinaryOp(e1,op,e2)) -> 
           (match e1 with
             ([FloatType],_)   -> 
            let rt = expr builder ex in
            build_fcmp Fcmp.Oeq rt (const_float float_t 1.0) "judgeif" builder              
           | ([IntegerType],_) -> 
            let rt = expr builder ex in
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" builder           
           | ([BoolType],_)    -> 
            let rt = expr builder ex in
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" builder
           | ([StringType],_)  ->
            let rt = expr builder ex in 
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" builder
           ) 
        | ([BoolType],_) -> expr builder ex
        | _ -> raise(Failure("not boolean on if condition"))
        ) in
        let merge_bb = append_block context "merge" the_function in
        let build_br_merge = build_br merge_bb in

        let then_bb = append_block context "then" the_function in
        add_terminal (stmt (builder_at_end context then_bb) s1) build_br_merge;

        let else_bb = append_block context "else" the_function in
        add_terminal (stmt (builder_at_end context else_bb) s2) build_br_merge;

        ignore(build_cond_br bool_val then_bb else_bb builder);
        builder_at_end context merge_bb
      | SForStatement(e1, ex, e2, stl)                                          ->
        ignore(stmt builder (SExpr e1));

        let whole_body = SBlock[stl;SExpr(e2)] in 
        let pred_bb = append_block context "for" the_function in
        ignore(build_br pred_bb builder);

        let body_bb = append_block context "for_body" the_function in
        add_terminal (stmt (builder_at_end context body_bb) whole_body) (build_br pred_bb);

        let pred_builder = builder_at_end context pred_bb in
        let bool_val = 
        (match ex with
        | ([BoolType],SBinaryOp(e1,op,e2)) -> 
           (match e1 with
             ([FloatType],_)   -> 
            let rt = expr pred_builder ex in
            build_fcmp Fcmp.Oeq rt (const_float float_t 1.0) "judgeif" pred_builder              
           | ([IntegerType],_) -> 
            let rt = expr pred_builder ex in
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" pred_builder           
           | ([BoolType],_)    -> 
            let rt = expr pred_builder ex in
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" pred_builder
           | ([StringType],_)  ->
            let rt = expr builder ex in 
            build_icmp Icmp.Eq rt (const_int i64_t 1) "judgeif" builder
           ) 
        | ([BoolType],_) -> expr builder ex
        | _ -> raise(Failure("not boolean on for condition"))
        )
        in
        let merge_bb = append_block context "merge" the_function in
        ignore(build_cond_br bool_val body_bb merge_bb pred_builder);
        builder_at_end context merge_bb 
      | SDeclare(nl,ty,el) ->
        let add_decl n = ignore(add_var_decl n (build_alloca (ltype_of_typ ty) n builder))
        in List.iter add_decl nl;
        let ck = match (List.hd el) with
          ([VoidType],_) -> builder
          | _ ->
            let build_decll n e = expr builder ([ty],SAssignOp(([ty],SNamedVariable(n)),e))
            in List.map2 build_decll nl el;
            builder
        in ck

      | SShortDecl(nl,el) ->
        let (p,_) = (List.hd el) in
        (match el with
        [([FutureType],SFunctionCall(_,_))] ->
          let add_decl n = 
            ignore(add_var_decl n (build_alloca (ltype_of_typ FutureType) n builder))
            in List.iter add_decl nl
        | [(etl,SFunctionCall(_,_))] | [(etl,SAwait(_))] -> 
          let add_decl n et = 
          ignore(add_var_decl n (build_alloca (ltype_of_typ et) n builder))
          in List.iter2 add_decl nl etl 
        | _ -> 
          let add_decl n e = 
          let (et, _) = e in
          ignore(add_var_decl n (build_alloca (ltype_of_typ (List.hd et)) n builder))
          in List.iter2 add_decl nl el);
        let check_func_call = 
          let build_decll n e = 
            let (et, _) = e in
            expr builder (et,SAssignOp((et,SNamedVariable(n)),e)) 
          in
          match (List.hd el) with
          ([FutureType],SFunctionCall(_,_))  ->  List.map2 build_decll nl el; builder
          | (_,SFunctionCall(_,_)) | (_,SAwait(_)) -> 
            let e_ = expr builder (List.hd el) in 
            let rec apply_extractvaluef current_idx = function 
              []          ->  ()
              | a::tl       ->  ignore(build_store (build_extractvalue e_ current_idx "extracted_value" builder) (lookup a) builder);   
                                apply_extractvaluef (current_idx+1) tl  
            in  ignore(apply_extractvaluef 0 nl);  
            builder
          | _ -> List.map2 build_decll nl el; builder
        in check_func_call

      | SBreak                                                                ->  builder   (*more work on continue and break*)
      | SContinue                                                             ->  builder   
      | SReturn(el)                                                           ->  
        let agg = Array.of_list (List.map (expr builder) el) in 
        ignore(build_aggregate_ret agg builder);
        builder
      | SExpr(ex)                                                             ->  ignore(expr builder ex); builder    

      in

        let builder = stmt builder (SBlock fdecl.sbody) in
        let agg_ = [|const_int i64_t 0|] in
        match fdecl.styp with
        [VoidType] -> ignore(build_ret_void builder)
        | _ -> add_terminal builder (build_aggregate_ret agg_)  

      in

        List.iter build_function_body functions;
        the_module




	
	

	
