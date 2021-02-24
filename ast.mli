type binary_operator = 
    Add | Sub | Mul | Div | Mod
  | LessThan | LessEqual | GreaterThan | GreaterEqual 
  | IsEqual | IsNotEqual
  | LogicalAnd | LogicalOr

type unary_operator = LogicalNot | Await | Negative

type builtin_type = 
  IntegerType
  | FloatType
  | StringType
  | SliceType of builtin_type
  | BoolType


type type_value = 
  Integer of int
  | Float of float
  | String of string
  | Slice of builtin_type * type_value list
  | Bool of bool

type expr =
    EmptyExpr
  | BinaryOp of expr * binary_operator * expr
  | UnaryOp  of unary_operator * expr
  | AssignOp of expr * expr
  | FunctionCall of string * expr list
  | TypedValue of type_value
  | NamedVariable of string

type statement = 
    EmptyStatement
  | IfStatement of expr * statement list * statement list 
     (* condition expression; statements if true; statements if false  *)
  | ForStatement of statement * expr * statement * statement list 
      (*  for expr1; expr2; expr3 {  statements   }  *)
  | Break
  | Continue
  | Declare of builtin_type * string
  | DeclareInit of string * expr
  | Return of expr
  | Expr of expr

type parameter = 
    NamedParameter of string * builtin_type

type func_proto_impl = 
    FunctionImpl of string * builtin_type * parameter list * statement list
   (*  function name,  type of return value,  parameters,   statements    *)

type functions = func_proto_impl list

