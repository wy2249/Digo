type binary_operator = 
  Add | Sub | Mul | Div | Mod
| LessThan | LessEqual | GreaterThan | GreaterEqual 
| IsEqual | IsNotEqual
| LogicalAnd | LogicalOr

type unary_operator = LogicalNot | Negative

type builtin_type = 
IntegerType
| FloatType
| StringType
| SliceType of builtin_type
| BoolType
| FutureType
| VoidType

type expr =
  EmptyExpr
| Integer of int
| Float of float
| String of string
| Bool of bool
| BinaryOp of expr * binary_operator * expr
| UnaryOp  of unary_operator * expr
| AssignOp of expr * expr
| FunctionCall of string * expr list
| NamedVariable of string
| SliceLiteral of builtin_type * int * expr list
| SliceIndex of expr * expr
| SliceSlice of expr * expr * expr
| Len of expr
| Append of expr list
| Await of string
| Read of expr


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

let rec string_of_expr = function
EmptyExpr -> "empty"
| Integer(x) -> string_of_int x
| Float(x) -> string_of_float x
| String(x) -> x
| Bool(x) -> string_of_bool x
| BinaryOp(e1,op,e2) -> string_of_expr e1 ^ " " ^ string_of_op op ^ " " ^ string_of_expr e2
| UnaryOp(op,e) -> string_of_uop op ^ string_of_expr e
| AssignOp(e1,e2)-> string_of_expr e1 ^ " = " ^ string_of_expr e2
| FunctionCall(f,el)->f ^ "(" ^ String.concat ", " (List.map string_of_expr el) ^ ")"
| NamedVariable(x) -> x
| SliceLiteral(t,int,el) -> "[]"^string_of_typ t ^ "{"^ String.concat ", " (List.map string_of_expr el) ^ "}"
| SliceIndex(e1,e2)-> string_of_expr e1 ^ "[" ^ string_of_expr e2^ "]" 
| SliceSlice (e1,e2,e3)->string_of_expr e1 ^ "[" ^ string_of_expr e2 ^":"^ string_of_expr e3^ "]"
| Len(e1)->"len("^string_of_expr e1 ^ ")" 
| Append(el)->"append("^ String.concat ", " (List.map string_of_expr el) ^ ")"
| Await(e)->"await "^string_of_expr e
| Read(e)->"read " ^string_of_expr e

