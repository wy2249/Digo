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
  | SAssignOp of sexpr * sexpr 
  | SFunctionCall of string * sexpr list
  | SNamedVariable of string
  | SLen of sexpr
  | SAppend of sexpr list
  | SSliceLiteral of builtin_type * int * sexpr list
  | SSliceIndex of sexpr * sexpr
  | SSliceSlice of sexpr * sexpr * sexpr
  | SAwait of string
  | SRead of sexpr


type sstatement = 
    SEmptyStatement
  | SIfStatement of sexpr * sstatement * sstatement 
  | SForStatement of sexpr * sexpr * sexpr * sstatement 
  | SBreak
  | SContinue
  | SDeclare of string list * builtin_type * sexpr list
  | SShortDecl of string list * sexpr list
  | SReturn of sexpr list
  | SExpr of sexpr
  | SBlock of sstatement list 

type sfunc_decl = {
  sann : func_annotation;
  sfname : string;
  styp : builtin_type list;
  sformals : bind list;
  sbody : sstatement list;
}

type functions = sfunc_decl list