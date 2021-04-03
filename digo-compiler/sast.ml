open Ast

type sexpr = builtin_type list * sx
and sx = 
    SEmptyExpr
  | SInteger of int
  | SFloat of float
  | SString of string
  | SBool of bool
  | SBinaryOp of sexpr * binary_operator * sexpr
  | SUnaryOp  of unary_operator * sexpr
  | SAssignOp of string list * sexpr 
  | SFunctionCall of string * sexpr list
  | SNamedVariable of string 
  | SSliceLiteral of builtin_type * int * sexpr list
  | SSliceIndex of sexpr * sexpr
  | SSliceSlice of sexpr * sexpr * sexpr
  | SBuiltinFunctionCall of builtin_function * sexpr list
  | SAwait of string


type sstatement = 
    SEmptyStatement
  | SIfStatement of sexpr * sstatement * sstatement 
     (* condition expression; statements if true; statements if false  *)
  | SForStatement of sexpr * sexpr * sexpr * sstatement 
      (*  for ssmt1; expr2; ssmt3 {  statements   }  *)
  | SBreak
  | SContinue
  (*| SDeclare of builtin_type list * string list * sexpr list
  | SShortDecl of string list * sexpr list                      *)
  | SReturn of sexpr list
  | SExpr of sexpr
  (*| SEmptySimpleStatement*)
  (*| SSimpleDeclare of builtin_type list * string list * sexpr list
  | SSimpleShortDecl of string list * sexpr list
  | SSimpleExpr of sexpr*)
  | SBlock of sstatement list 

type sfunc_decl = {
  sann : func_annotation;
  sfname : string;
  styp : builtin_type list;
  sformals : bind list;
  slocals : bind list;
  sbody : sstatement list;
}

type functions = sfunc_decl list