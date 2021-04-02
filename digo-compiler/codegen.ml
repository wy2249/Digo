open Llvm
open Ast

module StringMap = Map.Make(String)

let translate(functions) =
  let context = global_context () in
  let the_module = create_module context "Digo" in

  let i32_t      = i32_type    context 
    and i8_t       = i8_type     context
    and i1_t       = i1_type     context
    and float_t    = double_type context
    (*and string_t   = array_type (i8_type context) 100     assume each string is less than 100 character*)
    and void_t     = void_type   context in
    
    let ltype_of_typ = function
        IntegerType  -> i32_t
      | FloatType    -> float_t
      | BoolType     -> i1_t
      | StringType   -> pointer_type i8_t     
      (*| SliceType    -> void_t   needs work*)
      | FutureType   -> void_t   (*needs work*)
      | VoidType     -> void_t
    in

(*built-in function, needs add more*)
  let printInt_t = 
    var_arg_function_type i32_t [| i32_t |] in
  let printInt = 
    declare_function "printInt" printInt_t the_module in 

  let printFloat_t =
    var_arg_function_type i32_t [| float_t |] in
  let printFloat = 
    declare_function "printFloat" printFloat_t the_module in


  let show_string (_,ex)= match ex with
    String(ex)  -> ex
  | _           -> ""                    in    

  let printString_t= 
    var_arg_function_type i32_t [|(pointer_type i8_t)|] in
  let printString=
    declare_function "printString" (printString_t) the_module in  

(*usr function*)

  let function_decls = 
    let function_delc m fdecl=    
      let name = fdecl.sfname    
      and argument_types = 
        Array.of_list (List.map (fun (_,t) -> ltype_of_typ t) fdecl.sformals) in          
          (*let ftype = 
            function_type (ltype_of_typ (List.hd fdecl.styp)) argument_types in *)                       (*assume only one return type, works latter*) 
          let stype = 
            struct_type context (Array.of_list (List.map ltype_of_typ fdecl.styp)) in
          let ftype = 
            function_type styp argument_types in 
          StringMap.add name (define_function name ftype the_module,fdecl) m in
        List.fold_left function_delc StringMap.empty functions in

  let build_function_body fdecl= 
      let (the_function,_) = 
        StringMap.find fdecl.sfname function_decls in
      let builder = 
        builder_at_end context (entry_block the_function) in

      let local_vars = 
        let add_parameter m (n,t) p = 
          set_value_name n p;
          let local = build_alloca (ltype_of_typ t) n builder in  
          ignore (build_store p local builder);
          StringMap.add n local m    

          (* need to add local variable here *)
        and add_vlocal m (t,n) =
          let local_var = build_alloca (ltype_of_typ t) n builder in
          StringMap.add n local_var m
        in
        let arguments = List.fold_left2 add_parameter StringMap.empty fdecl.sformals
            (Array.to_list (params the_function))  in
            List.fold_left add_vlocal arguments fdecl.slocals

        let lookup n = StringMap.find n local_vars in

        let rec expr builder (e_typ,e) = match e with
          SEmptyExpr                                                          ->  ()
        | SAwait(s)                                                           ->  const_int i32_t 0      (*needs work*)
        | SBinaryOp(ex1,op,ex2) when e_typ = IntegerType || e_typ = BoolType  ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          (match op with
          Add       ->  build_add
          | Sub       ->  build_sub
          | Mul       ->  build_mul
          | Div       ->  build_sdiv
          | Mod       ->  build_srem 
          | LessThan    ->  build_icmp Icmp.Slt
          | LessEqual   ->  build_icmp Icmp.Sle
          | GreaterThan   ->  build_icmp Icmp.Sgt
          | GreaterEqual  ->  build_icmp Icmp.Sge
          | IsEqual     ->  build_icmp Icmp.Eq
          | IsNotEqual  ->  build_icmp Icmp.Ne
          | LogicalAnd  ->  build_and
          | LogicalOr   ->  build_or 
          ) e1 e2 "tmp" builder   
        | SBinaryOp(ex1,op,ex2) when e_typ = FloatType                        ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          (match op with
          Add       ->  build_fadd
          | Sub       ->  build_fsub
          | Mul       ->  build_fmul
          | Div       ->  build_fsdiv
          | Mod       ->  build_frem 
          | LessThan    ->  build_fcmp Fcmp.Olt
          | LessEqual   ->  build_fcmp Fcmp.Ole
          | GreaterThan   ->  build_fcmp Fcmp.Ogt
          | GreaterEqual  ->  build_fcmp Fcmp.Oge
          | IsEqual     ->  build_fcmp Fcmp.Oeq
          | IsNotEqual  ->  build_fcmp Fcmp.One
          | LogicalAnd  ->  raise(Failure("codegen error: semant should reject LogicalAnd between floating numbers"))
          | LogicalOr   ->  raise(Failure("codegen error: semant should reject LogicalOr between floating numbers")) 
          ) e1 e2 "tmp" builder             
        | SBinaryOp(ex1,op,ex2) when e_typ = StringType                       ->                        
          let e1 = expr builder ex1
          and e2 = expr builder ex2 in 
          let e1_string = show_string e1 
          and e2_string = show_string e2 in 
          (match op with
            Add ->  build_global_string (e1_string^e2_string) "var" builder     (*needs to modify symbol table structure to support indirect string concatenation*)
          | _   ->  raise(Failure("codegen error: semant should reject any operation between string except add"))
          )  
        | SUnaryOp(op,ex1)                                                     ->
          let e_ = expr builder ex1 in
          (match op with
            LogicalNot  ->  build_neg                                          (*add float cases latter*)      
          | Negative    ->  build_not) e_ "tmp" builder
        | SAssignOp(var,ex1)                                                   ->
          let e_ = expr builder ex1 in              
            ignore(build_store e_ (lookup var) builder); e_
        | SFunctionCall("printInt",[e])                                        ->  
            build_call printInt [|(expr builder e)|] "printInt" builder 
        | SFunctionCall("printFloat",[e])                                      ->
            build_call printFloat [|(expr builder e) |] "printFloat" builder
        | SFunctionCall("printString",[e])                                     ->
            let string_in_printString = show_string e in 
              let current_ptr = build_global_stringptr string_in_printString "printstr" builder in
                build_call printString [|current_ptr|] "printString" builder
        | SFunctionCall(f_name,args)                                           ->              
          let (fdef,_) = StringMap.find f_name function_decls in
          let llargs = List.map (expr builder) args in 
          let result = f_name^"_result" in 
          build_call fdef (Array.of_list llargs) result builder
        | SInteger(ex)                                                         ->  const_int i32_t ex
        | SFloat(ex)                                                           ->  const_float float_t ex
        | SString(ex)                                                          ->  const_string context ex
        | SBool(ex)                                                            ->  const_int i1_t (if ex then 1 else 0)
        | SNamedVariable(n)                                                    ->  build_load (lookup n) n builder  

        | SSliceLiteral(built_typ,len,e1_l)                                    ->  const_int i32_t 0      (*needs work*)
        | SSliceIndex(ex1,ex2)                                                 ->  const_int i32_t 0
        | SSliceSlice(ex1,ex2,ex3)                                             ->  const_int i32_t 0
      in

      let add_terminal builder instr  =
        match block_terminator (insertion_block builder) with 
          Some _ -> ()
        | None -> ignore (instr builder) in 

      let rec stmt builder = function  
        SEmptyStatement                                                        ->  builder
      | SBlock(sl)                                                             ->  List.fold stmt builder sl 
      | SIfStatement(ex, s1, s2)                                               ->  
        let bool_val = expr builder ex in 
        let merge_bb = append_block context "merge" the_function in
        let build_br_merge = builder_br merge_bb in

        let then_bb = append_block context "then" the_function in
        add_terminal (stmt (builder_at_end context then_bb) s1) build_br_merge;

        let else_bb = append_block context "else" the_function in
        add_terminal (stmt (builder_at_end context else_bb) s2) build_br_merge;

        ignore(build_cond_br bool_val then_bb else_bb builder);
        builder_at_end context merge_bb
      | ForStatement(s1, ex, s2, stl)                                          ->
        ignore(stmt builder s1);

        let whole_body = SBlock[stl::s2] in 
        let pred_bb = append_block context "for" the_function in
        ignore(build_br pred_bb builder);

        let body_bb = append_block context "for_body" the_function in
        add_terminal (stmt (builder_at_end context body_bb) whole_body) (build_br pred_bb);

        let pred_builder = builder_at_end context pred_bb in
        let bool_val = expr pred_builder ex in
        let merge_bb = append_block context "merge" the_function in
        ignore(build_cond_br bool_val body_bb merge_bb pred_builder);
        builder_at_end context merge_bb 

      | SBreak                                                                ->  builder   (*more work on continue and break*)
      | SContinue                                                             ->  builder   
      | SReturn(el)                                                           ->  
        let agg = Array.of_list (List.map (expr builder) el) in 
        ignore(build_aggregate_ret agg builder);
        builder
      | SExpr(ex)                                                             ->  ignore(expr builder ex); builder    (*works latter*)

      in

        let builder = stmt builder (SBlock(fdecl.sbody)) in
        add_terminal builder build_ret_void  

      in 

        List.iter build_function_body functions;
        the_module




	
	

	
