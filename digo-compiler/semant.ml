(* Semantic checking for the Digo compiler *)

open Ast
open Sast
open Llvm
open Llvm_analysis

module StringMap = Map.Make(String)


let check (functions) =

  (* Verify a list of bindings has no void types or duplicate names *)

  (* Collect function declarations for built-in functions: no bodies. *)
  let built_in_decls = 
    let builtins = 
      [
        (* print functions*)
        (*("printString", {ann = FuncNormal; fname = "printString"; typ = [VoidType]; 
        formals = [(StringType,"string")] ; body=[]});*)
  
        (* string related*)
        (* Accepts a C-layout string and returns a wrapped Digo String object *)
        ("CreateString", {ann = FuncNormal; fname = "CreateString"; typ = [StringType]; 
        formals = [(StringType,"string")] ; body=[]});
        (* Returns an empty Digo String object *)
        ("CreateEmptyString", {ann = FuncNormal; fname = "CreateEmptyString"; typ = [StringType]; 
        formals = [] ; body=[]});
        (* concat(Digo String A + Digo String B) *)
        ("AddString", {ann = FuncNormal; fname = "AddString"; typ = [StringType]; 
        formals = [(StringType,"string"); (StringType,"string")] ; body=[]});
        (* the second parameter is a C-style string *)
        ("AddCString", {ann = FuncNormal; fname = "AddCString"; typ = [StringType]; 
        formals = [(StringType,"string"); (StringType,"string")] ; body=[]});
        (* Get a copy of Digo String *)
        ("CloneString", {ann = FuncNormal; fname = "CloneString"; typ = [StringType]; 
        formals = [(StringType,"string")] ; body=[]});
        (* Returns strcmp(strA, strB) *)
        ("CompareString", {ann = FuncNormal; fname = "CompareString"; typ = [IntegerType]; 
        formals = [(StringType,"string"); (StringType,"string")] ; body=[]});
        (* Returns strlen *)
        ("GetStringSize", {ann = FuncNormal; fname = "GetStringSize"; typ = [IntegerType]; 
        formals = [(StringType,"string")] ; body=[]});
        (* Get C-style string *)
        ("GetCStr", {ann = FuncNormal; fname = "GetCStr"; typ = [StringType]; 
        formals = [(StringType,"string")] ; body=[]});

        (*could be any type at this point*)
        ("CreateSlice",{ann = FuncNormal; fname = "CreateSlice"; typ = [];
        formals = [] ; body = [] });  
        ("SliceSlice",{ann = FuncNormal; fname = "SliceSlice"; typ = [];
        formals = [] ; body = [] });  
        ("SliceAppends",{ann = FuncNormal; fname = "SliceAppend"; typ = [];
        formals = [] ; body = [] });  
        ("SliceAppendn",{ann = FuncNormal; fname = "SliceAppend"; typ = [];
        formals = [] ; body = [] });
        ("SliceAppendf",{ann = FuncNormal; fname = "SliceAppend"; typ = [];
        formals = [] ; body = [] });
        ("SliceAppendF",{ann = FuncNormal; fname = "SliceAppend"; typ = [];
        formals = [] ; body = [] });      
        ("CloneSlice",{ann = FuncNormal; fname = "CloneSlice"; typ = [];
        formals = [] ; body = [] });         
        ("GetSliceSize",{ann = FuncNormal; fname = "CreateSliceSize"; typ = [];
        formals = [] ; body = [] });

        ("SetSliceIndexDouble",{ann = FuncNormal; fname = "SetSliceIndexDouble"; typ = [];
        formals = [] ; body = [] });   
        ("SetSliceIndexFuture",{ann = FuncNormal; fname = "SetSliceIndexFuture"; typ = [];
        formals = [] ; body = [] });    
        ("SetSliceIndexString",{ann = FuncNormal; fname = "SetSliceIndexString"; typ = [];
        formals = [] ; body = [] });
        ("SetSliceIndexInt",{ann = FuncNormal; fname = "SetSliceIndexInt"; typ = [];
        formals = [] ; body = [] });
        ("GetSliceIndexString",{ann = FuncNormal; fname = "GetSliceIndexString"; typ = [];
        formals = [] ; body = [] }); 
        ("GetSliceIndexInt",{ann = FuncNormal; fname = "GetSliceIndexInt"; typ = [];
        formals = [] ; body = [] });
        ("GetSliceIndexDouble",{ann = FuncNormal; fname = "GetSliceIndexDouble"; typ = [];
        formals = [] ; body = [] });
        ("GetSliceIndexFuture",{ann = FuncNormal; fname = "GetSliceIndexFuture"; typ = [];
        formals = [] ; body = [] })

      ]
    in
    let add_bind map (name, ty) = StringMap.add name ty map
    in 
      List.fold_left add_bind StringMap.empty builtins
    in
    

  (* 
    This part is 
    1. Add function name to symbol table 
    2. Check for duplciate function naming and naming same with built-in functions. 
  *)
  let add_func map fd = 
    let built_in_err = "Semant Err: function " ^ fd.fname ^ " may not be defined"
    and dup_err = "Semant Err: duplicate function " ^ fd.fname
    and make_err er = raise (Failure er)
    and n = fd.fname (* Name of the function *)
    
    in match fd with (* No duplicate functions or redefinitions of built-ins *)
          _ when StringMap.mem n built_in_decls -> make_err built_in_err
        | _ when StringMap.mem n map -> make_err dup_err  
        | _ ->  StringMap.add n fd map 
  in
  
  (* This part is
    1. Collect all function names into one symbol table
  *)
  let function_decls = List.fold_left add_func built_in_decls functions
  (* pass here *)
  in

  (* Find_func finds a function from our symbol table. It can be used:
    1. check if every program main/master function
    2. check if function existed for function call
  *)
  let find_func s = 
    try StringMap.find s function_decls
    with Not_found -> raise (Failure ("unrecognized function " ^ s))
  in
  
  (* Ensure "main" is defined *)
  let _ = find_func "digo_main" in 
  
  (* Check semantic in function *)
  let check_function func =

    (* check_duplicate is a helper function to check duplicate in a list*)
    (*let check_duplicate exceptf list =
      let rec helper = function
          n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
        | _ :: t -> helper t
        | [] -> ()
      in helper (List.sort compare list)

    (* check duplicate in parameters with check_duplicate*)
    in check_duplicate (fun n -> "duplicate formal " ^ n ^ " in function " ^ func.fname)
    (List.map fst func.formals);*)
    let _ =
      match func.fname with 
      "digo_main" -> if (List.length func.formals) > 0 then raise(Failure "Semant Err: digo_main should be no-arugment.");
        (match func.typ with
        [VoidType] -> ignore()
        | _ -> raise(Failure "Semant Err: digo_main should be void type."))
      | _ -> ignore()
    in

    let check_binds kind binds =              
      List.iter(function
        (VoidType, b) -> raise(Failure("illegal VoidType in " ^ kind ^" : "^b))
        | _-> () 
      ) binds;
      let rec dup_check = function 
        [] -> []
      | ((_,n1)::(_,n2)::_) when n1 = n2 -> raise(Failure("duplicate in "^ kind ^ " : " ^ n1))
      | _::vdecls -> dup_check vdecls
      in 
        dup_check (List.sort (fun (_,n1)(_,n2)-> compare n1 n2) binds)
    in  

    ignore(check_binds "argument" func.formals);

    (* Type of each variable (global, formal, or local *)
    let symbols = Hashtbl.create 500 in
    let futures = Hashtbl.create 500 in                                          
    let _ = List.iter (fun (t, n) -> Hashtbl.add symbols n t) func.formals in 
    let type_of_identifier n =
      if Hashtbl.mem symbols n then Hashtbl.find symbols n
      else raise (Failure("Sement Err: undeclared identifier " ^ n))
    in
    let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in
    let func_of_future n = 
      let fname = if Hashtbl.mem futures n then Hashtbl.find futures n
      else raise (Failure("Semant Err: undeclared future object " ^ n)) in
      find_func fname
    in
    let get_type_in_slicetype stp = match stp with
          SliceType(StringType)      ->  StringType
        | SliceType(IntegerType)     ->  IntegerType
        | SliceType(FloatType)       ->  FloatType
        | SliceType(FutureType)      ->  FutureType
        | _                          ->  raise(Failure("invalide slice type"))
    in
    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr e = match e with
        Integer(x)  -> ([IntegerType], SInteger(x))
      | Float(x) -> ([FloatType], SFloat(x))
      | Bool(x)  -> ([BoolType], SBool(x))
      | String (x)   -> 
        ([StringType],SString(x))
      | EmptyExpr -> ([VoidType],SEmptyExpr) 
      | NamedVariable s  -> 
        ([type_of_identifier s], SNamedVariable(s))
      | AssignOp(var, e) ->
        (* this part check left side is valid: only accept nameddvariable/slice index *)
        (match var with
        | SliceIndex(e1,e2)  -> 
          (match e1 with
          | NamedVariable(s) -> 
            let (var_typ,_) = expr var 
            and (ret_typ,e') = expr e in
            let err = "illegal assignment" in
            ([check_assign (List.hd var_typ) (List.hd ret_typ) err], SAssignOp((expr var),(ret_typ, e')))   
          | _  -> raise(Failure("AssignOp error: left hand side is invalide"))
          )
        | NamedVariable(x)   -> 
          (* check named variable type macth with expression type *)
          let var_typ = type_of_identifier x
          and (ret_typ,e') = expr e in
          let err = "illegal assignment " (*^ stringify_builtin_type var_type ^ " to expression type "
            ^ stringify_builtin_type ret_typ*) in
          let _ = match var_typ with
            FutureType -> 
            let SFunctionCall(fname,_) = e' in
            Hashtbl.add futures x fname
            | _ -> ignore()
          in
            ([check_assign var_typ (List.hd ret_typ) err], SAssignOp(expr var,(ret_typ, e')))  
        | _ ->
          raise(Failure("AssignOp error: left hand side is invalide")) 
        )  
      | UnaryOp(op, e)   -> 
        let (ret_typl,e') = expr e in
        let op_typ = match op with
              Negative when (List.hd ret_typl) = IntegerType || (List.hd ret_typl) = FloatType -> ret_typl
            | LogicalNot when (List.hd ret_typl) = BoolType -> ret_typl
            | _ -> raise (Failure ("Semant Err: illegal unary operator " (*^ stringify_unary_operator op e ^ 
              " expression type "^stringify_builtin_type ret_typ*)  )) in
        (op_typ,SUnaryOp(op,(ret_typl,e')))
            
      | BinaryOp(e1, op, e2)  -> 
        let (ret_typl1,e1') = expr e1 and (ret_typl2,e2') = expr e2 in
          (* All binary operators require operands of the same type *)
        let same = ret_typl1 = ret_typl2 in
          (* Determine expression type based on operator and operand types *)
        let op_typ = match op with
            Add | Sub | Mul | Div | Mod when same && ((List.hd ret_typl1) = IntegerType) -> IntegerType
          | Add | Sub | Mul | Div | Mod when same && ((List.hd ret_typl1) = FloatType) -> FloatType
          | IsEqual | IsNotEqual  when same -> BoolType
          | LessThan | LessEqual | GreaterThan | GreaterEqual
            when same && ((List.hd ret_typl1) = IntegerType || (List.hd ret_typl1) = FloatType || (List.hd ret_typl1) = StringType) -> BoolType
          | LogicalAnd | LogicalOr when same && ((List.hd ret_typl1) = BoolType) -> BoolType
          | Add when same && (List.hd ret_typl1) == StringType -> StringType
          | _ -> raise ( Failure ("Semant Err: illegal binary operator " (*^ stringify_binary_operator e1 op e2^" e1 type "^ 
            stringify_builtin_type ret_typ1^ " e2 type "^stringify_builtin_type ret_typ2*)  )) in 
        ([op_typ],SBinaryOp((ret_typl1,e1'),op,(ret_typl2,e2')))
      | FunctionCall(fname, args) ->
      (match fname with
      | "print" -> ([VoidType],SFunctionCall(fname,(List.map expr args)))
      | "println" -> ([VoidType],SFunctionCall(fname,(List.map expr args)))
      | _ -> 
        let fd = find_func fname in 
        let param_length = List.length fd.formals in
        if List.length args != param_length then
          raise (Failure ("Semant Err: different number of aruguments passed. Expected " ^ string_of_int param_length ^ " aruguments but "
                          ^ string_of_int (List.length args) ^" aruguments provided in function " ^ fname))
        else 
          let check_call (ft, _) e = 
            let (ret_typl,e') = expr e in 
            let err = "Semant Err: illegal argument found" in
          ([check_assign ft (List.hd ret_typl) err],e')
          in 
          let args' = List.map2 check_call fd.formals args in 
          let tpy' = match fd.ann with
            FuncNormal -> fd.typ
          | _ -> 
            [FutureType]
          in
          (tpy',SFunctionCall(fname,args'))
      )
      | Append(exl) ->
        let exlen = List.length exl in 
        if exlen = 2 
        then 
          let (ret_typl1,e1') = expr (List.hd exl) in
          let (ret_typl2,e2') = expr (List.nth exl 1) in
          ( match ret_typl1 with
          | [SliceType(x)] -> 
            if x = (List.hd ret_typl2)
            then (ret_typl1,SAppend([(ret_typl1,e1');(ret_typl2,e2')]))
            else raise(Failure("Built-in Append object and element are not compatible due to different type"))
          | _  -> raise(Failure("Built-in Append being called on non-slice object"))  
          )
        else raise(Failure("Append needs two objects"))
      | Len(ex)              ->  
            let (ret_typl,e') = expr ex in
            ( match ret_typl with
            | [SliceType(_)] -> ([IntegerType],SLen((ret_typl,e')))
            | [StringType] -> ([IntegerType],SLen((ret_typl,e')))
            | _  -> raise(Failure("Built-in Len being called on non-slice object"))  
            )
    | Read(e) ->
            (* only string type*)
          let (ret_typ,e') = expr e in
          let ck = match (List.hd ret_typ) with
            StringType -> ([SliceType(StringType)],SRead((ret_typ,e')))
            |_ -> raise (Failure ("error: read is not supported for "^ string_of_typ (List.hd ret_typ)))
          in ck
    | SliceLiteral(btyp, slice_len , expl)  ->
      let rt_typ = get_type_in_slicetype btyp in
      let check_type e_ =
      let (ret_typl,e') = expr e_ in
      let err = "illegal slice type found" in
      ([check_assign rt_typ (List.hd ret_typl) err],e')
      in
      let sexpl = List.map check_type expl in 
      ([btyp],SSliceLiteral(btyp, slice_len , sexpl))
    | SliceIndex(e1,e2)                     -> 
      let (ret_typl1,e1') = expr e1 and (ret_typl2,e2') = expr e2 in
      let check_e1typ = match ret_typl1 with
        [SliceType(_)]  -> ()
      | _             -> raise(Failure("illgal slice indexing on non-slice object"))
      in 
      let check_e2typ = match ret_typl2 with
      | [IntegerType] -> ()
      | _ -> raise(Failure("illgal slice index: non-integer index"))
      in 
      let rt_typ = get_type_in_slicetype (List.hd ret_typl1) in 
      ([rt_typ],SSliceIndex((ret_typl1,e1'),(ret_typl2,e2')))
    | SliceSlice(e1,e2,e3)                  ->
      let (ret_typl1,e1') = expr e1 and (ret_typl2,e2') = expr e2 and (ret_typl3,e3') = expr e3 in
      let check_e1typ = match ret_typl1 with
        [SliceType(_)]  -> ()
      | _             -> raise(Failure("illgal slice slicing on non-slice object"))
      in 
      let check_e2typ = match ret_typl2 with
      | [IntegerType] -> ()
      | [VoidType]    -> ()
      | _ -> raise(Failure("illgal slice slice: non-integer index"))
      in  
      let check_e3typ = match ret_typl3 with
      | [IntegerType] -> ()
      | [VoidType]    -> ()
      | _ -> raise(Failure("illgal slice slice: non-integer index"))
      in                
      (ret_typl1,SSliceSlice((ret_typl1,e1'),(ret_typl2,e2'),(ret_typl3,e3')))
      (*| Len(e) ->
        (* only string and slice type*)
        let (ret_typ,e') = expr e in
        let ck = match (List.hd ret_typ) with
          StringType -> ([IntegerType],SLen((ret_typ,e')))
          |_ -> raise (Failure ("error: len is not supported for "^ string_of_typ (List.hd ret_typ)))
        in ck
      *)
      | Await(n) ->
            (* await futureVar *)
            (* return [list of returned aysn val types, SAwait(n)]*)
          let fd = func_of_future n in
          (fd.typ, SAwait(n))

    in 
    
    let check_bool_expr e = 
      let (ret_typl,e') = expr e in 
      if ((List.hd ret_typl) != BoolType && e != EmptyExpr) 
      then raise (Failure ("expected Boolean expression"))
      else ([List.hd ret_typl],e')
    in

    let rec check_stmt = function 
        EmptyStatement                    ->  SEmptyStatement
      | IfStatement(e,st1,st2)            ->  SIfStatement(check_bool_expr e, check_stmt st1, check_stmt st2)                         
      | ForStatement(e1,e,e2,st3)         ->  SForStatement(expr e1, check_bool_expr e, expr e2, check_stmt st3)
      | Break                             ->  SBreak                                (*more on sbreak*)
      | Continue                          ->  SContinue                            (*more on scontinune*)
      | Declare(nl,t,el) ->
        let check_dup_var n =
          if Hashtbl.mem symbols n then raise (Failure ("Semant Err: duplicate local variable declarations ( " ^ n ^ " )")) else  ignore(Hashtbl.add symbols n t)
        in List.iter check_dup_var nl;
        let ck = match el with
          [] -> SDeclare(nl, t, [([VoidType],SEmptyExpr)])
          | _ ->
            if List.length nl != List.length el then raise (Failure ("assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length el) ^ " values"));
            let ret_list = List.map (fun e -> expr e) el in 
            let _ = List.iter (fun (rt,_) -> ignore(check_assign t (List.hd rt) "illegal assignment type")) ret_list
            in SDeclare(nl, t, ret_list)
        in ck
      | ShortDecl(nl,el) -> 
        let ret_list = List.map (fun e -> expr e) el in
        let _ = match (List.hd ret_list) with
            (tyl,SFunctionCall(_,_)) | (tyl, SAwait(_)) -> 
            if List.length nl != List.length tyl then raise (Failure ("short decl assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length tyl) ^ " values"));
          | _ ->
            if List.length nl != List.length el then raise (Failure ("short decl assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length el) ^ " values"));
        in
        let check_dup_var n (rt,_) =
          if Hashtbl.mem symbols n then raise (Failure ("Semant Err: duplicate local variable declarations ( " ^ n ^ " )")) else  ignore(Hashtbl.add symbols n (List.hd rt))
        in 
        let check_dup_var_function n rt =
          if Hashtbl.mem symbols n then raise (Failure ("Semant Err: duplicate local variable declarations ( " ^ n ^ " )")) else  ignore(Hashtbl.add symbols n rt)
        in
        let _ = match (List.hd ret_list) with
          ([FutureType],SFunctionCall(fname,_)) ->
            List.iter (fun n -> if Hashtbl.mem symbols n then raise (Failure ("Semant Err: duplicate local variable declarations ( " ^ n ^ " )"))
            else ignore(Hashtbl.add symbols n FutureType)) nl;
            List.iter (fun n -> if Hashtbl.mem futures n then raise (Failure ("Semant Err: duplicate future variable declarations ( " ^ n ^ " )"))
            else  ignore(Hashtbl.add futures n fname)) nl;
          | (etl,SFunctionCall(_,_)) | (etl, SAwait(_))   -> 
              List.iter2 check_dup_var_function nl etl
          | _ -> List.iter2 check_dup_var nl ret_list
        in
        SShortDecl(nl, ret_list)
      | Expr(e)                           ->  SExpr(expr e)
      | Return(el)                        -> 
            (match func.typ with
            [VoidType] -> if (List.length el) > 0 
                            then raise (Failure ("Semant Err: too many arguments to return in a void function "^func.fname)) else raise (Failure ("Semant Err: "))
            | _ -> 
              (match (List.length func.typ - List.length el) with
              0 -> let ret_list = List.map (fun e -> expr e) el in
                let _ = List.iter2 (fun (rt,_) ft -> ignore(check_assign (List.hd rt) ft ("cannot use "^(string_of_typ (List.hd rt)) ^" in return argument of function " ^func.fname))) ret_list func.typ
                in SReturn(ret_list)
              | _ when (List.length func.typ - List.length el)> 0 -> raise (Failure ("Semant Err: not enough arguments to return in function "^func.fname))
              | _ -> raise (Failure ("Semant Err: too many arguments in function "^func.fname))
              ))

      | Block(stl)                        -> 
        let rec check_stmt_list = function 
          [Return _ as s] -> [check_stmt s]
        | Return _ :: _      -> raise(Failure ("Statements appear after Return"))
        | Block b::ss     -> check_stmt_list (b@ss)
        | s::ss           ->
          let a = check_stmt s in
          a :: check_stmt_list ss
        | []              ->   [SEmptyStatement]
        in
        SBlock(check_stmt_list stl) 
    
      in

    let rec generate_default_return_value func_typ = 
      (
        match func_typ with
          [VoidType] -> []
          | _ -> 
            let rec make_arr = function
              [] -> []
              | IntegerType :: ar -> Integer(0) :: make_arr ar
              | FloatType :: ar -> Float(0.0) :: make_arr ar
              | StringType :: ar -> String("") :: make_arr ar
            in 
            let new_return = make_arr func_typ in
            [check_stmt (Return(new_return))]
      )

    in (* body of check_function *)
    { sann = func.ann;
      styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      sbody = 
        match check_stmt (Block func.body) with
        SBlock(stl) ->   
          (match List.hd (List.rev stl) with
          SReturn(x) ->  stl
          | _  -> let default_return = generate_default_return_value func.typ in
                  stl@default_return
          )
      | _      -> raise(Failure("function body does not form"))
    }
  in  List.map check_function functions
;;

