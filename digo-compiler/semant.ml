(* Semantic checking for the Digo compiler *)

open Ast
open Sast
open Llvm
open Llvm_analysis

module StringMap = Map.Make(String)


let check (functions) =

  (* Verify a list of bindings has no void types or duplicate names *)

  (* Collect function declarations for built-in functions: no bodies.
    The built-in fucntions in digo are: append, len, gather.
    To do: change type of these built-in fucntion after defining them in ast
    To fix: parser directly gives error: "Fatal error: exception Stdlib.Parsing.Parse_error"
  *)
  let built_in_decls = 
    let builtins = 
      [
        (* print functions*)
        ("print", { ann = FuncNormal; fname = "print"; typ=[VoidType];
        formals = [] ; body=[] }); 
        ("println", { ann = FuncNormal; fname = "println"; typ=[VoidType];
        formals = [] ; body=[] }); 

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
        ("CompareString", {ann = FuncNormal; fname = "CompareString"; typ = [StringType]; 
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
    let built_in_err = "function " ^ fd.fname ^ " may not be defined"
    and dup_err = "duplicate function " ^ fd.fname
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
  
  (* Ensure "digo_main" is defined *)
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
    let _ = List.iter (fun (t, n) -> Hashtbl.add symbols n t) func.formals in 
    let type_of_identifier n =
      if Hashtbl.mem symbols n then Hashtbl.find symbols n
      else raise (Failure("Err: undeclared identifier " ^ n))
    in
    let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)
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
        print_string("string lit here\n");
        ([StringType],SString(x))
      | EmptyExpr -> ([VoidType],SEmptyExpr) 
      | NamedVariable s  -> 
        print_string "namedvariable called semant\n";
        print_string (" name: " ^ s ^ "\n");
        print_string (" check " ^ s ^ " " ^ string_of_bool (Hashtbl.mem symbols s) ^ "\n");
        ([type_of_identifier s], SNamedVariable(s))
      | AssignOp(var, e) -> 
        print_string "assignment called semant\n";
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
          let var_typ = type_of_identifier x
          and (ret_typ,e') = expr e in
          let err = "illegal assignment" in
          ([check_assign var_typ (List.hd ret_typ) err], SAssignOp((expr var),(ret_typ, e')))   
        | _ ->
          raise(Failure("AssignOp error: left hand side is invalide")) 
        )  
      | UnaryOp(op, e)   -> 
        let (ret_typl,e') = expr e in
        let op_typ = match op with
              Negative when (List.hd ret_typl) = IntegerType || (List.hd ret_typl) = FloatType -> ret_typl
            | LogicalNot when (List.hd ret_typl) = BoolType -> ret_typl
            | _ -> raise (Failure ("illegal unary operator " (*^ stringify_unary_operator op e ^ 
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
            when same && ((List.hd ret_typl1) = IntegerType || (List.hd ret_typl1) = FloatType) -> BoolType
          | LogicalAnd | LogicalOr when same && ((List.hd ret_typl1) = BoolType) -> BoolType
          | Add when same && (List.hd ret_typl1) == StringType -> StringType
          | _ -> raise ( Failure ("illegal binary operator " (*^ stringify_binary_operator e1 op e2^" e1 type "^ 
            stringify_builtin_type ret_typ1^ " e2 type "^stringify_builtin_type ret_typ2*)  )) in 
        ([op_typ],SBinaryOp((ret_typl1,e1'),op,(ret_typl2,e2')))

      | FunctionCall(fname, args) ->
        print_string "functioncall called semant\n";
        (match fname with
        | "print" -> ([VoidType],SFunctionCall(fname,(List.map expr args)))
        | _ -> 
        let fd = find_func fname in 
        let param_length = List.length fd.formals in
        if List.length args <> param_length then
          raise (Failure ("error: different number of aruguments passed expected " ^ string_of_int param_length ^ " aruguments but "
                          ^ string_of_int (List.length args) ^" aruguments provided"))
        else let check_call (ft, _) e = 
          let (ret_typl,e') = expr e in 
          let err = "illegal argument found" (*^ "formal type " ^ ft ^ " real argument type " ^ stringify_statement ret_typ*) in
          ([check_assign ft (List.hd ret_typl) err],e')
        in 
        let args' = List.map2 check_call fd.formals args in 
        (fd.typ,SFunctionCall(fname,args'))
        )
      | BuiltinFunctionCall(nfunc,exl)              ->  
        (
          match nfunc with
          Len              ->
            let exlen = List.length exl in 
            if exlen = 1 
            then 
              let (ret_typl,e') = expr (List.hd exl)in
              ( match ret_typl with
              | [SliceType(_)] -> ([IntegerType],SBuiltinFunctionCall(Len,[(ret_typl,e')]))
              | _  -> raise(Failure("Built-in Len being called on non-slice object"))  
              )
            else 
              raise(Failure("Built-in Len being called with too many aruguments, expected 1 argument"))
         |Append           ->
            let exlen = List.length exl in 
            if exlen = 2 
            then 
              let (ret_typl1,e1') = expr (List.hd exl) in
              let (ret_typl2,e2') = expr (List.nth exl 1) in
              ( match ret_typl1 with
              | [SliceType(x)] -> 
                if x = (List.hd ret_typl2)
                then (ret_typl1,SBuiltinFunctionCall(Append,[(ret_typl1,e1');(ret_typl2,e2')]))
                else raise(Failure("Built-in Append object and element are not compatible due to different type"))
              | _  -> raise(Failure("Built-in Append being called on non-slice object"))  
              )
            else 
              raise(Failure("Built-in Append being called with too many or too few aruguments, expected 2 argument"))         
        ) 
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
      | Await _ -> ([VoidType],SEmptyExpr)
    in 
    
    let check_bool_expr e = 
      let (ret_typl,e') = expr e in 
      if ((List.hd ret_typl) <> BoolType && e <> EmptyExpr) 
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
        print_string "declare called semant\n";
        let check_dup_var n =
          if Hashtbl.mem symbols n then raise (Failure "duplicate local variable declarations") else  ignore(Hashtbl.add symbols n t)
        in List.iter check_dup_var nl;
        print_string (" declare check " ^ (List.hd nl) ^ " " ^ string_of_typ (Hashtbl.find symbols (List.hd nl)) ^"\n");
        let ck = match el with
          [] -> SDeclare(nl, t, [([VoidType],SEmptyExpr)])
          | _ ->
            if List.length nl <> List.length el then raise (Failure ("assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length el) ^ " values"));
            let ret_list = List.map (fun e -> expr e) el in 
            let _ = List.iter (fun (rt,_) -> ignore(check_assign t (List.hd rt) "illegal assignment type")) ret_list
            in SDeclare(nl, t, ret_list)
        in ck
      | ShortDecl(nl,el) -> 
        print_string "short declare called semant\n";
        let ret_list = List.map (fun e -> expr e) el in
        let _ = match (List.hd ret_list) with
            (tyl,SFunctionCall(_,_)) -> 
            print_string "func call in short dec\n";
            if List.length nl <> List.length tyl then raise (Failure ("assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length tyl) ^ " values"));
          | _ ->
            if List.length nl <> List.length el then raise (Failure ("assignment mismatch: "^string_of_int (List.length nl) ^" variables but "^ string_of_int (List.length el) ^ " values"));
        in
        let check_dup_var n (rt,_) =
          if Hashtbl.mem symbols n then raise (Failure "duplicate local variable declarations") else  ignore(Hashtbl.add symbols n (List.hd rt))
        in 
        let check_dup_var_function n rt =
          if Hashtbl.mem symbols n then raise (Failure "duplicate local variable declarations") else  ignore(Hashtbl.add symbols n rt)
        in 
        let _ = 
          match ret_list with
            [(etl,SFunctionCall(_,_))]    -> List.map2 check_dup_var_function nl etl
          | _                             -> List.map2 check_dup_var nl ret_list         
        in
        SShortDecl(nl, ret_list)
      | Expr(e)                           ->  SExpr(expr e)
      | Return(el)                        -> 
        let ret_list = List.map (fun e -> expr e) el in 
        SReturn(ret_list)
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

    in (* body of check_function *)
    { sann = func.ann;
      styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      sbody = match check_stmt (Block func.body) with
        SBlock(stl) ->   stl   
      | _           -> raise(Failure("function body does not form"))
    }
  in  List.map check_function functions
;;


let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.functions Scanner.tokenize lexbuf in

  let sast = check ast in 
  let m = Codegen.translate sast in
  assert_valid_module m;
  print_string(string_of_llmodule m)
