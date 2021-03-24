(* Semantic checking for the Digo compiler *)

open Ast
open Llvm

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
                              ("gather", IntegerType)]
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
    let check_duplicate exceptf list =
      let rec helper = function
          n1 :: n2 :: _ when n1 = n2 -> raise (Failure (exceptf n1))
        | _ :: t -> helper t
        | [] -> ()
      in helper (List.sort compare list)

    (* check duplicate in parameters with check_duplicate*)
    in check_duplicate (fun n -> "duplicate formal " ^ n ^ " in function " ^ func.fname)
    (List.map fst func.formals);

    (* To Do: check duplicate local declaration (need to change ast and parser)*)
      
    (* Type of each variable (global, formal, or local *)
    let symbols = Hashtbl.create 5000 in
    let _ = List.iter (fun (n, t) -> Hashtbl.add symbols n t) func.formals
    in
    let type_of_identifier s =
      try Hashtbl.find symbols s
      with Not_found -> raise (Failure ("undeclared identifier " ^ s))
    in
    let check_assign lvaluet rvaluet err =
      if lvaluet = rvaluet then lvaluet else raise (Failure err)
    in   
    (* Return a semantically-checked expression, i.e., with a type *)
    let rec expr e = match e with
        Integer _ -> IntegerType
      | Float _ -> FloatType
      | Bool _  -> BoolType
      | String _   -> StringType
      | EmptyExpr -> StringType (* to fix: change to void? *)
      | NamedVariable s  -> type_of_identifier s
      | AssignOp(var, e) as ex -> StringType (* to fix *)
      | UnaryOp(op, e) as ex -> let t = expr e in
            (match op with
              Negative when t = IntegerType || t = FloatType -> t
            | LogicalNot when t = BoolType -> BoolType
            | _ -> raise (Failure ("illegal unary operator "))
            )
      | BinaryOp(e1, op, e2) as e -> let t1 = expr e1 and t2 = expr e2 in
          (* All binary operators require operands of the same type *)
          let same = t1 = t2 in
          (* Determine expression type based on operator and operand types *)
          let ty = match op with
            Add | Sub | Mul | Div | Mod when same && t1 = IntegerType -> IntegerType
          | Add | Sub | Mul | Div when same && t1 = FloatType -> FloatType
          | IsEqual | IsNotEqual  when same -> BoolType
          | LessThan | LessEqual | GreaterThan | GreaterEqual
            when same && (t1 = IntegerType || t1 = FloatType) -> BoolType
          | LogicalAnd | LogicalOr when same && t1 = BoolType -> BoolType
          | _ -> raise ( Failure ("illegal binary operator ") )
          in ty
      | FunctionCall(fname, args) as call -> StringType
      (*
          let fd = find_func fname in
          let param_length = List.length fd.formals in
          if List.length args != param_length then
            raise (Failure ("error: different number of aruguments passed"))
          else let check_call (_, ft) e = 
            let et = expr e in 
            let err = "illegal argument found "
            in check_assign ft et err
          in 
          List.map2 check_call fd.formals args
      *)
      | BuiltinFunctionCall(_,_) -> StringType
      | SliceLiteral(_,_,_)->StringType
      | SliceIndex(_,_) ->StringType
      | SliceSlice(_,_,_)->StringType
      | Await _ -> StringType
    in 
    
    let check_bool_expr e = if expr e != BoolType
      then raise (Failure ("expected Boolean expression" ))
      else ()
    
    in (* body of check_function *)
    { ann = func.ann;
      typ = func.typ;
      fname = func.fname;
      formals = func.formals;
      body = func.body
    }

  in  List.map check_function functions
;;

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let ast = Parser.functions Scanner.tokenize lexbuf in
  let sast = check ast in
  print_string (string_of_llmodule (Codegen.translate sast)) 
