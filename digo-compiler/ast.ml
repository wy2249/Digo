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
| VoidType

type builtin_function = 
  Gather
| Append

type expr =
  EmptyExpr
| Integer of int
| Float of float
| String of string
| Bool of bool
| BinaryOp of expr * binary_operator * expr
| UnaryOp  of unary_operator * expr
| AssignOp of string * expr
| FunctionCall of string * expr list
| NamedVariable of string
| SliceLiteral of builtin_type * int * expr list
| SliceIndex of expr * expr
| SliceSlice of expr * expr * expr
| Len of expr
| Await of string
| BuiltinFunctionCall of builtin_function * expr list


type statement = 
  EmptyStatement
| IfStatement of expr * statement * statement
   (* condition expression; statements if true; statements if false  *)
| ForStatement of expr * expr * expr * statement
    (*  for ssmt1; expr2; ssmt3 {  statements   }  *)
| Break
| Continue
| Return of expr list
| Expr of expr
| Declare of string list * builtin_type * expr list
| ShortDecl of string list * expr list
(*| EmptySimpleStatement
| SimpleDeclare of builtin_type list * string list * expr list
| SimpleShortDecl of string list * expr list
| SimpleExpr of expr*)
| Block of statement list

type bind = builtin_type * string 

type func_annotation = 
  FuncNormal
| FuncAsync
| FuncAsyncRemote

type func_decl = {
ann : func_annotation;
fname : string;
typ : builtin_type list;
formals : bind list;
body : statement list;
}

type functions = func_decl list


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
| VoidType -> "void"

let rec string_of_ann = function
FuncNormal -> "normal"
| FuncAsync -> "async"
| FuncAsyncRemote -> "async remote"



