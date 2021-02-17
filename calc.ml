open Ast

module StringHash = Hashtbl.Make(struct 
    type t = string
    let equal x y = x = y 
    let hash = Hashtbl.hash 
  end);;
let temp_reg_table : string StringHash.t = StringHash.create 10;;

(*  Define exceptions here  *)

exception NotAssignable of string

let rec stringify_builtin_type = function
IntegerType -> "Integer"
| FloatType -> "Float"

and

  stringify_binary_operator ex1 op ex2 = 
  let new_reg_id = StringHash.length temp_reg_table in
  let new_reg = "r" ^ string_of_int new_reg_id in
  let str = 
  let r1 = stringify_expr ex1 in
  let r2 = stringify_expr ex2 in
  (
    match op with
    Add  ->  r1 ^ " + " ^ r2
  | Sub  ->  r1 ^ " - " ^ r2
  | Mul  ->  r1 ^ " * " ^ r2
  | Div  ->  r1 ^ " / " ^ r2
  | LessThan -> r1 ^ " < " ^ r2
  ) in 
  let reg_content = new_reg ^ " = " ^ str in
  StringHash.replace temp_reg_table new_reg reg_content; new_reg

and

  stringify_expr = function
    EmptyExpr                    -> ""
  | BinaryOp(ex1, op, ex2)       -> stringify_binary_operator ex1 op ex2
  | UnaryOp(op, ex)            ->   ""
  | AssignOp(ex1, ex2)                -> ""
  | FunctionCall(funcName, exlist)                   -> ""
  | TypedValue(tv)               -> ""
  | NamedVariable(nv)                     -> ""

and

  stringify_statement = function
    (*  Top level statement  *)
    EmptyStatement                  -> "Empty Statement"
  | IfStatement(ex, stt, stf)       -> "If Statement" ^ stringify_expr ex ^ stringify_statements stt ^ stringify_statements stf
  | ForStatement(st1, ex, st3, stlist) -> "For Statement" ^ stringify_statement st1
  | Break                           -> "Break"
  | Continue                        -> "Continue"
  | Declare(typ, str)               -> "Declare"
  | DeclareInit(str, ex)            -> "var x := 1"
  | Return(ex)                      -> "Return" ^ stringify_expr ex
  | Expr(ex)                        -> stringify_expr ex

and

  stringify_statements = function
    [] ->   ""
  | (st :: sts) ->    stringify_statement st ^ stringify_statements sts

  ;;

let rec print_function = function
    FunctionImpl(name, typ, parameters, stlist)
       ->  print_endline ("Function " ^ name);
           print_endline (stringify_builtin_type typ);
           print_endline (" Params: " ^ " ? " ^ " Statements: " ^ stringify_statements stlist)
;;

let rec print_functions = function
    []  ->   print_endline ""
  | (func :: funcs)  ->   print_function func ; print_functions funcs
;;

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let functions = Parser.functions Scanner.tokenize lexbuf in
    print_functions functions
