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

let rec string_of_sexpr (tl, e) =
  "(" ^ String.concat ", " (List.map string_of_typ tl) ^ " : " ^ (match e with
  SEmptyExpr -> "empty"
| SInteger(x) -> string_of_int x
| SFloat(x) -> string_of_float x
| SString(x) -> x
| SBool(x) -> string_of_bool x
| SBinaryOp(e1,op,e2) -> string_of_sexpr e1 ^ " " ^ string_of_op op ^ " " ^ string_of_sexpr e2
| SUnaryOp(op,e) -> string_of_uop op ^ string_of_sexpr e
| SAssignOp(e1,e2)-> string_of_sexpr e1 ^ " = " ^ string_of_sexpr e2
| SFunctionCall(f,el)->f ^ "(" ^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
| SNamedVariable(x) -> x
| SSliceLiteral(t,int,el) -> "[]"^string_of_typ t ^ "{"^ String.concat ", " (List.map string_of_sexpr el) ^ "}"
| SSliceIndex(e1,e2)-> string_of_sexpr e1 ^ "[" ^ string_of_sexpr e2^ "]" 
| SSliceSlice (e1,e2,e3)->string_of_sexpr e1 ^ "[" ^ string_of_sexpr e2 ^":"^ string_of_sexpr e3^ "]"
| SLen(e1)->"len("^string_of_sexpr e1 ^ ")" 
| SAppend(el)->"append("^ String.concat ", " (List.map string_of_sexpr el) ^ ")"
| SAwait(e)->"await "^e
| SRead(e)->"read " ^string_of_sexpr e
) ^ ")"				  
