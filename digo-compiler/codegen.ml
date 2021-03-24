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
    and string_t   = array_type (i8_type context) 100     (*assume each string is less than 100 character*)
    and void_t     = void_type   context in
    
    let ltype_of_typ = function
        IntegerType  -> i32_t
      | FloatType    -> float_t
      | BoolType     -> i1_t
      | StringType   -> string_t     
      (*| SliceType    -> void_t   needs work*)
      | FutureType   -> void_t   (*needs work*)
    in

  let printInt_t = 
    var_arg_function_type i32_t [| i32_t |] in
  let printInt = 
    declare_function "printInt" printInt_t the_module in 

  let printFloat_t =
    var_arg_function_type i32_t [| float_t |] in
  let printFloat = 
    declare_function "printFloat" printFloat_t the_module in

  let function_decls = 
    let function_delc m fdecl=    
      let name = fdecl.fname    
      and argument_types = 
        Array.of_list (List.map (fun (_,t) -> ltype_of_typ t) fdecl.formals) in          
          let ftype = 
            function_type (ltype_of_typ fdecl.typ) argument_types in 
          StringMap.add name_del (define_function name_del ftype the_module,fdecl) m in
        List.fold_left function_delc StringMap.empty functions in

  let build_function_body fdecl= 
      let (the_function,_) = 
        StringMap.find fdecl.name function_decls in
      let builder = 
        builder_at_end context (entry_block the_function) in

      let local_vars = 
        let add_parameter m (n,t) p = 
          set_value_name n p;
          let local = build_alloca (ltype_of_typ t) n builder in  
          ignore (build_store p local builder);
          StringMap.add n local m    

          (* need to add local variable here *)

        in
        List.fold_left2 add_parameter StringMap.empty fdecl.formals
          (Array.to_list (params the_function))  in

        let lookup n = StringMap.find n local_vars in

        let rec expr builder e = match e with
        EmptyExpr                   -> const_int i32_t 0
        | Await(s)                        ->  const_int i32_t 0              (*needs work*)
        | BinaryOp(ex1,op,ex2)              ->                        (*add float cases latter*)
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
        | UnaryOp(op,ex1)               ->
          let e_ = expr builder ex1 in
          (match op with
            LogicalNot  ->  build_neg               (*add float cases latter*)      
          | Negative    ->  build_not) e_ "tmp" builder
        | AssignOp(var,ex1)           ->
          let e_ = expr builder ex1 in
            ignore(build_store e_ (lookup var) builder); e_
        | FunctionCall("printInt",[e])            ->  
            build_call printInt [|(expr builder e) |] "printInt" builder 
        | FunctionCall("printFloat",[e])          ->
            build_call printFloat [|(expr builder e) |] "printFloat" builder
        | FunctionCall(var,ex_l)                  -> const_int i32_t 0             (*needs work latter*)
        | Literal(ex)                             ->  
          (match ex with
            Integer(x)          ->  const_int i32_t x
          | Float(x)            ->  const_float float_t x
          | String(x)           ->  const_stringz context x
          | Bool(x)             ->  const_int i1_t (if x then 1 else 0))

        | NamedVariable(n)              ->  const_stringz context n
        | SliceLiteral(built_typ,len,e1_l)      ->  const_int i32_t 0                (*needs work*)
        | SliceIndex(ex1,ex2)             ->  const_int i32_t 0
        | SliceSlice(ex1,ex2,ex3)           ->  const_int i32_t 0
      in

      let add_terminal builder instr  =
        match block_terminator (insertion_block builder) with 
          Some _ -> ()
        | None -> ignore (instr builder) in 

      let rec stmt builder = function  
        EmptyStatement                      ->  builder (*works latter*)
      | IfStatement(ex, stt, stf)         ->  builder
      | ForStatement(sst1, ex, sst3, stlist)  ->  builder
      | Break                               ->  builder
      | Continue                            ->  builder
      | Declare(typ, str, ex)               ->  builder
      | ShortDecl(str, ex)                  ->  builder
      | Return(ex)                          ->  
      ignore(match fdelc.typ with 
          (*Void -> build_ret_void builder*)
          | _-> build_ret (expr builder ex) builder);
          builder                     (*assume only return one type, needs work latter*)
      | Expr(ex)                            ->  ignore(expr builder ex); builder    
        in

        let builder = List.fold_left stmt builder fdelc.body in

        add_terminal builder (match fdelc.typ with
          (*works latter*)
        | _ -> build_ret_void)    in 

        List.iter build_function_body functions;
        the_module



	
	

	
