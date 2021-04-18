open Ast

module StringMap = Map.Make(String)

let rec stringify_builtin_type = function
IntegerType -> "int"
| FloatType -> "double"
| StringType -> "string"
| SliceType(typ) -> "slice"
| BoolType   ->  "int"
| FutureType ->  "future"
| VoidType -> "void"
;;

let rec stringify_builtin_types = function
[]             ->   ""
| (typ :: typs)  ->   stringify_builtin_type typ ^ ", " ^ stringify_builtin_types typs
;;

let rec stringify_builtin_type_list l = 
  let s = stringify_builtin_types l in
    String.sub s 0 (String.length s-2)
;;

let rec stringify_parameter (bind : builtin_type * string) : string =
     let (typ, name) = bind in
       stringify_builtin_type typ
;;

let rec stringify_parameters = function
   []           ->      ""
 | (par :: pars) ->      stringify_parameter par ^ ", " ^ stringify_parameters pars
;;

let rec stringify_parameter_list l = 
  let s = stringify_parameters l in
    if String.length s == 0 then
      ""
    else
    String.sub s 0 (String.length s-2)
;;

let rec stringify_func_metadata f (ann_str : string) : string = 
  "; FUNC DECLARE BEGIN\n" ^ "; FUNC_NAME = '" ^ f.fname ^ "'\n; FUNC_ANNOT = '" ^ ann_str ^
  "'\n; PARAMETERS = '" ^ stringify_parameter_list f.formals ^ "'\n" ^ "; RETURN_TYPE = '" ^
  stringify_builtin_type_list f.typ ^ "'\n; FUNC DECLARE END\n"
;;

let rec print_metadata f = 
  match f.ann with
  | FuncNormal -> ()
  | FuncAsync -> print_endline (stringify_func_metadata f "async")
  | FuncAsyncRemote -> print_endline (stringify_func_metadata f "async remote")
;;

let rec print_mul_metadata = function
    []  ->   print_endline ""
  | (func :: funcs)  ->   print_metadata func ; print_mul_metadata funcs
;;

let _ =
  let lexbuf = Lexing.from_channel stdin in
  let functions = Parser.functions Scanner.tokenize lexbuf in
  print_endline "; DIGO Async Function Metadata BEGIN\n\n; VERSION = 1\n";
  print_mul_metadata functions;
  print_endline "\n; DIGO Async Function Metadata END\n";
