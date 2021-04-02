(* Semantic checking for the Digo compiler *)

open Ast
open Llvm
open Llvm_analysis
open Printer

module StringMap = Map.Make(String)


let check (functions) =

  (* Verify a list of bindings has no void types or duplicate names *)

  (* Collect function declarations for built-in functions: no bodies.
    The built-in fucntions in digo are: append, len, gather.
    To do: change type of these built-in fucntion after defining them in ast
    To fix: parser directly gives error: "Fatal error: exception Stdlib.Parsing.Parse_error"
  *)
  let built_in_decls = 
    let add_bind map (name, ty) = StringMap.add name {
      ann = FuncNormal; 
      fname = name;
      typ = [];
      formals = [];
      body = [] } map
    in List.fold_left add_bind StringMap.empty [("append", IntegerType);
                              ("len", IntegerType);
                              ("gather", IntegerType);
                              ("printString", StringType);
                              ("printFloat", FloatType);
                              ("printInt",IntegerType)]
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
  
  (* Ensure "main" is defined *)
  let _ = find_func "main" in 
  
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
      | ((n1,_)::(n2,_)::_) when n1 = n2 -> raise(Failure("duplicate in "^ kind ^ " : " ^ n1))
      | _::vdecls -> dup_check vdecls
      in 
        dup_check (List.sort (fun (n1,_)(n2._)-> compare a b) binds)
    in  

    check_binds "argument" func.formals;
    check_binds "local" func.locals;

    (* Type of each variable (global, formal, or local *)
    let symbols = Hashtbl.create 500 in                                             
    let _ = List.iter (fun (n, t) -> Hashtbl.add symbols n t) func.formals in 
    let _ = List.iter (fun (n, t) -> Hashtbl.add symbols n t) func.locals in 
    let type_of_identifier s =
      try Hashtbl.find symbols s
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in
    let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in   
    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr e = match e with
        Integer(x)  -> (IntegerType, SInteger(x))
      | Float(x) -> (FloatType, SFloat(x))
      | Bool(x)  -> (BoolType, SBool(x))
      | String (x)   -> (StringType,SString(x))
      | EmptyExpr -> (VoidType,SEmptyExpr) 
      | NamedVariable s  -> (type_of_identifier s, SNamedVariable(s))
      | AssignOp(var, e) as ex -> 
        let var_typ = type_of_identifier var 
        and (ret_typ,e') = expr e in
        let err = "illegal assignment variable type " ^ stringify_builtin_type var_type ^ " to expression type "
          ^ stringify_builtin_type ret_typ in 
        (check_assign var_typ ret_typ err, SAssignOp(var,(ret_typ,e')))
      | UnaryOp(op, e) as ex -> 
        let (ret_typ,e') = expr e in
        let op_typ = match op with
              Negative when ret_typ = IntegerType || ret_typ = FloatType -> ret_typ
            | LogicalNot when ret_typ = BoolType -> ret_typ
            | _ -> raise (Failure ("illegal unary operator " ^ stringify_unary_operator op e ^ 
              " expression type "^stringify_builtin_type ret_typ) in
        (op_typ,SUnaryOp(op,(ret_typ,e')))0
            
      | BinaryOp(e1, op, e2) as e -> 
        let (ret_typ1,e1') = expr e1 and (ret_typ2,e2') = expr e2 in
          (* All binary operators require operands of the same type *)
        let same = ret_typ1 = ret_typ2 in
          (* Determine expression type based on operator and operand types *)
        let op_typ = match op with
            Add | Sub | Mul | Div | Mod when same && (ret_typ1 = IntegerType) -> IntegerType
          | Add | Sub | Mul | Div when same && (ret_typ1 = FloatType) -> FloatType
          | IsEqual | IsNotEqual  when same -> BoolType
          | LessThan | LessEqual | GreaterThan | GreaterEqual
            when same && (ret_typ1 = IntegerType || ret_typ1 = FloatType) -> BoolType
          | LogicalAnd | LogicalOr when same && (ret_typ1 = BoolType) -> BoolType
          | Add when same && ret_typ1 == StringType -> StringType
          | _ -> raise ( Failure ("illegal binary operator " ^ stringify_binary_operator e1 op e2^" e1 type "^ 
            stringify_builtin_type ret_typ1^ " e2 type "^stringify_builtin_type ret_typ2)) in 
        (op_typ,SBinaryOp((ret_typ1,e1'),op,(ret_typ2,e2')))

      | FunctionCall(fname, args) as call -> 
        let fd = find_func fname in
        let param_length = List.length fd.formals in
        if List.length args != param_length then
          raise (Failure ("error: different number of aruguments passed expected " ^ string_of_int param_length ^ " aruguments but "
                          ^ string_of_int (List.length args) ^" aruguments provided"))
        else let check_call (_, ft) e = 
          let (ret_typ,e') = expr e in 
          let err = "illegal argument found formal type " ^ ft ^ " real argument type " ^ ret_typ in
          (check_assign ft ret_typ err,e')
        in 
        let args' = List.map2 check_call fd.formals args in 
        (fd.typ,SFunctionCall(fname,args'))
      
      | BuiltinFunctionCall(_,_) -> (VoidType,SEmptyExpr)
      | SliceLiteral(_,_,_)->(VoidType,SEmptyExpr)
      | SliceIndex(_,_) ->(VoidType,SEmptyExpr)
      | SliceSlice(_,_,_)->(VoidType,SEmptyExpr)
      | Await _ -> (VoidType,SEmptyExpr)
    in 
    
    let check_bool_expr e = 
      let (ret_typ,e') = expr e in 
      if ret_typ != BoolType
      then raise (Failure ("expected Boolean expression"))
      else (ret_typ,e')
    in 

    let rec check_stmt = function 
        EmptyStatement                    ->  SEmptyStatement
      | IfStatement(e,st1,st2)            ->  SIfStatement(check_bool_expr e, check_stmt st1, check_stmt st2)                         
      | ForStatement(st1,e,st2,st3)       ->  SForStatement(check_stmt st1, check_bool_expr e, check_stmt st2, check_stmt st3)
      | Break                             ->  SBreak                                (*more on sbreak*)
      | Continue                          ->  SContinune                            (*more on scontinune*)
      | Expr(e)                           ->  SExpr(expr e)      
      | Return(el)                        ->  
        let ret_list = List.map (fun e -> expr e) el in 
        SReturn(ret_list)
      | Block(stl)                        ->  
        let rec check_stmt_list = function 
          [Return _ as s] -> [check_stmt s]
        | Return_::_      -> raise(Failure ("Statements appear after Return"))
        | Block b::ss     -> check_stmt_list (b@ss)
        | s::ss           -> check_stmt s:: check_stmt_list ss
        | []              -> []
        in SBlock(check_stmt_list stl)  

    in (* body of check_function *)
    { sann = func.ann;
      styp = func.typ;
      sfname = func.fname;
      sformals = func.formals;
      slocals = func.locals;
      sbody = match check_stmt Block(func.body) with
        SBlock(stl) -> stl   
      | _           -> raise(Failure("function body does not form"))
    }

  in  List.map check_function functions
;;

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.functions Scanner.tokenize lexbuf in
  let sast = check ast in
  let m =Codegen.translate sast in
  assert_valid_module m;
  print_string(string_of_llmodule m)