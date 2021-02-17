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
  | ArrayType
  | BoolType

type type_value = 
  Integer of int
  | Float of float
  | String of string
  | Array of int * type_value
  | Bool of bool

type expr =
    EmptyExpr
  | BinaryOp of expr * binary_operator * expr
  | UnaryOp  of unary_operator * expr
  | AssignOp of expr * expr
  | FunctionCall of string * expr list
  | TypedValue of type_value
  | NamedVariable of string

type simple_statement = 
    EmptySimpleStatement
  | SimpleDeclare of builtin_type * string * expr
  | SimpleShortDecl of string * expr
  | SimpleExpr of expr

type statement = 
    EmptyStatement
  | IfStatement of expr * statement list * statement list 
     (* condition expression; statements if true; statements if false  *)
  | ForStatement of simple_statement * expr * simple_statement * statement list 
      (*  for ssmt1; expr2; ssmt3 {  statements   }  *)
  | Break
  | Continue
  | Declare of builtin_type * string * expr
  | ShortDecl of string * expr
  | Return of expr
  | Expr of expr

type parameter = 
    NamedParameter of string * builtin_type

type func_proto_impl = 
    FunctionImpl of string * builtin_type * parameter list * statement list
   (*  function name,  type of return value,  parameters,   statements    *)
  | AsyncFunctionImpl of string * builtin_type * parameter list * statement list
  | RemoteFunctionImpl of string * builtin_type * parameter list * statement list

type functions = func_proto_impl list

