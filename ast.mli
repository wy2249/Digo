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
  | FutureType

type literal = 
  Integer of int
  | Float of float
  | String of string
  | Slice of builtin_type * int * literal list
  | Bool of bool

type expr =
    EmptyExpr
  | BinaryOp of expr * binary_operator * expr
  | UnaryOp  of unary_operator * expr
  | AssignOp of expr * expr
  | FunctionCall of string * expr list
  | Literal of literal
  | NamedVariable of string
  | SliceLiteral of builtin_type * int * expr list

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
    FunctionImpl of string * builtin_type list * parameter list * statement list
   (*  function name,  type of return value,  parameters,   statements    *)
  | AsyncFunctionImpl of string * builtin_type list * parameter list * statement list
  | RemoteFunctionImpl of string * builtin_type list * parameter list * statement list

type functions = func_proto_impl list

