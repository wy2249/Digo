open Ast

module StringHash = Hashtbl.Make(struct 
    type t = string
    let equal x y = x = y 
    let hash = Hashtbl.hash 
  end);;
let temp_reg_table : string StringHash.t = StringHash.create 10;;

let temp_label_table : string StringHash.t = StringHash.create 10;;

(*  Define exceptions here  *)

exception NotAssignable of string

let rec stringify_builtin_type = function
IntegerType -> "Integer"
| FloatType -> "Float"
| StringType -> "String"

and

  stringify_literal = function
  Integer(x)  ->  "Integer " ^ string_of_int x
| String(x)   ->  "String " ^ x

and

  stringify_builtin_type_list = function
  []             ->   ""
| (typ :: typs)  ->   stringify_builtin_type typ ^ ", " ^ stringify_builtin_type_list typs

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
  StringHash.replace temp_reg_table new_reg reg_content; reg_content

and

  stringify_expr = function
    EmptyExpr                    -> ""
  | BinaryOp(ex1, op, ex2)       -> stringify_binary_operator ex1 op ex2
  | UnaryOp(op, ex)              -> ""
  | AssignOp(ex1, ex2)           -> stringify_expr ex1 ^ " = " ^ stringify_expr ex2
  | FunctionCall(funcName, exlist) -> "Call " ^ funcName ^ " with arguments " ^ stringify_expressions exlist
  | Literal(lit)               -> "" ^ stringify_literal lit
  | NamedVariable(nv)            -> "Variable " ^ nv

and

  stringify_expressions = function
  []           ->      ""
| (ex :: exs)  ->      stringify_expr ex ^ ", " ^ stringify_expressions exs

and

  stringify_declare typ name exp = 
  "Declare " ^ name ^ " " ^ stringify_builtin_type typ ^ " with " ^ stringify_expr exp

and

  stringify_short_declare name exp = 
  "Short declare " ^ name ^ " " ^ stringify_expr exp

and

  stringify_statement = function
    (*  Top level statement  *)
    EmptyStatement                  -> "Empty Statement"
  | IfStatement(ex, stt, stf)       -> 
    let label_id = StringHash.length temp_label_table in
    let label = "if" ^ string_of_int label_id in
    StringHash.replace temp_label_table label ""; 
    "\nIf Statement (" ^ label ^  ") Begin, Condition: " ^ stringify_expr ex ^ "\n(" ^ label ^")If true: \n" ^ stringify_statements stt ^ 
    "\n(" ^ label ^ ")If false: \n" ^ stringify_statements stf ^ "If Statement (" ^ label ^ ") End"
  | ForStatement(sst1, ex, sst3, stlist) -> 
    "For (" ^ stringify_simple_statement sst1 ^ ", " ^ stringify_expr ex ^ ", " ^ stringify_simple_statement sst3 ^ ")" ^
    "\nStatements: \n" ^ stringify_statements stlist ^ "For end."
  | Break                           -> "Break"
  | Continue                        -> "Continue"
  | Declare(typ, str, ex)           -> stringify_declare typ str ex
  | ShortDecl(str, ex)              -> stringify_short_declare str ex
  | Return(ex)                      -> "Return " ^ stringify_expr ex
  | Expr(ex)                        -> stringify_expr ex

and

  stringify_statements = function
    [] ->   ""
  | (st :: sts) ->  "" ^ stringify_statement st ^ "\n" ^ stringify_statements sts

and

  stringify_simple_statement = function
    EmptySimpleStatement                  -> "Empty short statement"
  | SimpleDeclare(typ, str, ex)           -> stringify_declare typ str ex
  | SimpleShortDecl(str, ex)              -> stringify_short_declare str ex
  | SimpleExpr(ex)                        -> stringify_expr ex

;;

let rec stringify_parameter = function 
   NamedParameter(name, typ)       ->    "Parameter: name " ^ name ^ " type " ^ stringify_builtin_type typ
;;

let rec stringify_parameters = function
   []           ->      ""
 | (par :: pars) ->      stringify_parameter par ^ ", " ^ stringify_parameters pars
;;

let rec print_function = function
    FunctionImpl(name, typ, parameters, stlist)
       ->  print_endline ("Function " ^ name);
           print_endline (" Return Type: " ^ stringify_builtin_type_list typ);
           print_endline (" Params: " ^ stringify_parameters parameters);
           print_endline (" Statements: \n   " ^ stringify_statements stlist);
  | RemoteFunctionImpl(name, typ, parameters, stlist)
      ->  print_endline ("Async remote function " ^ name);
          print_endline (" Return Type: " ^ stringify_builtin_type_list typ);
          print_endline (" Params: " ^ stringify_parameters parameters);
          print_endline (" Statements: \n   " ^ stringify_statements stlist);
  | AsyncFunctionImpl(name, typ, parameters, stlist)
      ->  print_endline ("Async function " ^ name);
          print_endline (" Return Type: " ^ stringify_builtin_type_list typ);
          print_endline (" Params: " ^ stringify_parameters parameters);
          print_endline (" Statements: \n   " ^ stringify_statements stlist);
;;


let rec print_functions = function
    []  ->   print_endline ""
  | (func :: funcs)  ->   print_function func ; print_functions funcs
;;

let _ =
    let lexbuf = Lexing.from_channel stdin in
    let functions = Parser.functions Scanner.tokenize lexbuf in
    print_functions functions
