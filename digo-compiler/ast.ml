type binary_operator = 
    Add | Sub | Mul | Div | Mod
  | LessThan | LessEqual | GreaterThan | GreaterEqual 
  | IsEqual | IsNotEqual
  | LogicalAnd | LogicalOr

type unary_operator = LogicalNot | Negative

(* do we need a void type for no return func?*)
type builtin_type = 
  IntegerType
  | FloatType
  | StringType
  | SliceType of builtin_type
  | BoolType
  | FutureType

(*
type literal = 
  Integer of int
  | Float of float
  | String of string
  | Bool of bool
*)

type builtin_function = 
    Gather
  | Len
  | Append

type expr =
    EmptyExpr
  | Integer of int
  | Float of float
  | String of string
  | Bool of bool
  | BinaryOp of expr * binary_operator * expr
  | UnaryOp  of unary_operator * expr
  | AssignOp of string * expr list
  | FunctionCall of string * expr list
  | NamedVariable of string
  | SliceLiteral of builtin_type * int * expr list
  | SliceIndex of expr * expr
  | SliceSlice of expr * expr * expr
  | BuiltinFunctionCall of builtin_function * expr list
  | Await of string

type simple_statement = 
    EmptySimpleStatement
  | SimpleDeclare of builtin_type list * string list * expr list
  | SimpleShortDecl of string list * expr list
  | SimpleExpr of expr

type statement = 
    EmptyStatement
  | IfStatement of expr * statement list * statement list 
     (* condition expression; statements if true; statements if false  *)
  | ForStatement of simple_statement * expr * simple_statement * statement list 
      (*  for ssmt1; expr2; ssmt3 {  statements   }  *)
  | Break
  | Continue
  | Declare of builtin_type list * string list * expr list
  | ShortDecl of string list * expr list
  | Return of expr list
  | Expr of expr

type parameter = string * builtin_type
  (* NamedParameter of string * builtin_type *)

type func_annotation = 
    FuncNormal
  | FuncAsync
  | FuncAsyncRemote

type func_decl = {
  ann : func_annotation;
  fname : string;
  typ : builtin_type list;
  formals : parameter list;
  body : statement list;
}

(*
type func_proto = 
  (*  annotation,  function name,  type of return value,  parameters,   statements    *)
    FunctionProto of func_annotation * string * builtin_type list * parameter list

type func_impl = 
    FunctionImpl of statement list

type func_proto_impl = 
    Function of func_proto * func_impl
*)

type functions = func_decl list (* func_proto_impl list *)


let string_of_op = function
  Add -> "+"
| Sub -> "-"
| Mul -> "*"
| Div -> "/"
| LessThan -> "<"
| LessEqual -> "<="
| GreaterThan -> ">"
| GreaterEqual -> ">="
| IsEqual -> "=="
| IsNotEqual -> "!="
| LogicalAnd -> "&&"
| LogicalOr -> "||"
| Mod -> "%"

let string_of_uop = function
  LogicalNot -> "!"
| Negative -> "-"

let rec string_of_typ = function
IntegerType -> "int"
| FloatType -> "float"
| StringType -> "string"
| SliceType(typ) ->"Slice(" ^ string_of_typ typ ^ ")"
| BoolType -> "bool"
| FutureType -> "future"

let rec stringify_builtin_function = function
  Gather       ->    "Builtin_Gather"
| Len          ->    "Builtin_Len"
| Append       ->    "Builtin_Append"
