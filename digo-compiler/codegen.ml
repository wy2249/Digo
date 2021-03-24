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

  let printInt_t = 
    var_arg_function_type i32_t [| i32_t |] in
  let printInt = 
    declare_function "printInt" printInt_t the_module in 

  let printFloat_t =
    var_arg_function_type i32_t [| float_t |] in
  let printFloat = 
    declare_function "printFloat" printFloat_t the_module in


  (*let find_length = function
    String(ex) -> (String.length ex) + 1
  | _ -> 0                           in*)
  let show_string = function
    String(ex) -> ex
  | _ -> ""                           in    

  (*let printString_type len= 
    array_type (i8_type context) len in
  let printString_t len= 
    var_arg_function_type i32_t [| (printString_type len) |] in
  let printString len=
    declare_function "printString" (printString_t len) the_module in*)
  let printString_t= 
    var_arg_function_type i32_t [|(pointer_type i8_t)|] in
  let printString=
    declare_function "printString" (printString_t) the_module in  

  let function_decls = 
    let function_delc m fdecl=    
      let name = fdecl.fname    
      and argument_types = 
        Array.of_list (List.map (fun (_,t) -> ltype_of_typ t) fdecl.formals) in          
          let ftype = 
            function_type (ltype_of_typ (List.hd fdecl.typ)) argument_types in                        (*assume only one return type, works latter*) 
          StringMap.add name (define_function name ftype the_module,fdecl) m in
        List.fold_left function_delc StringMap.empty functions in

  let build_function_body fdecl= 
      let (the_function,_) = 
        StringMap.find fdecl.fname function_decls in
      let builder = 
        builder_at_end context (entry_block the_function) in

      let str_format_str = build_global_stringptr "%s\n" "str" builder in

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
          let e_ = expr builder (List.hd ex1) in              (*assume only the list only contains 1 expr,works latter*)
            ignore(build_store e_ (lookup var) builder); e_
        | FunctionCall("printInt",[e])            ->  
            build_call printInt [|(expr builder e)|] "printInt" builder 
        | FunctionCall("printFloat",[e])          ->
            build_call printFloat [|(expr builder e) |] "printFloat" builder
        | FunctionCall("printString",[e])         ->
          (*let length = find_length e in
              build_call (printString length) [|(expr builder e)|] "printString" builder*)
              (*build_call printString [|str_format_str;(expr builder e)|] "printString" builder *)
            let string_in_printString = show_string e in 
              let current_ptr = build_global_stringptr string_in_printString "str" builder in
                build_call printString [|current_ptr|] "printString" builder
        | FunctionCall(var,ex_l)                  -> const_int i32_t 0             (*needs work latter*)

        | Integer(ex)          ->  const_int i32_t ex
        | Float(ex)            ->  const_float float_t ex
        | String(ex)           ->  const_stringz context ex
        | Bool(ex)             ->  const_int i1_t (if ex then 1 else 0)

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
      ignore(match fdecl.typ with 
          (*Void -> build_ret_void builder*)
          | _-> build_ret (expr builder (List.hd ex)) builder);                 
          builder                     (*assume only return one type, needs work latter*)
      | Expr(ex)                            ->  ignore(expr builder ex); builder    (*works latter*)
        in

        let builder = List.fold_left stmt builder fdecl.body in

        add_terminal builder (match fdecl.typ with
          (*works latter*)
        | _ -> build_ret_void)    in 

        List.iter build_function_body functions;
        the_module




	
	

	
