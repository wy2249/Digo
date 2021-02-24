type token =
  | NEWLINE
  | PLUS
  | MINUS
  | TIMES
  | DIVIDE
  | LOGICAL_OR
  | LOGICAL_AND
  | IS_EQUAL
  | IS_NOT_EQUAL
  | IS_LESS_THAN
  | IS_GREATER_THAN
  | LEFT_BRACE
  | RIGHT_BRACE
  | LEFT_BRACKET
  | RIGHT_BRACKET
  | LEFT_PARENTHE
  | RIGHT_PARENTHE
  | ASSIGNMENT
  | ASSIGNNEW
  | SEMICOLON
  | EOF
  | COMMA
  | INT_LITERAL of (int)
  | STRING_LITERAL of (string)
  | VARIABLE of (string)
  | KEYWORD_FOR
  | KEYWORD_IF
  | KEYWORD_ELSE
  | KEYWORD_FUNC
  | KEYWORD_RETURN
  | KEYWORD_AWAIT
  | KEYWORD_ASYNC
  | KEYWORD_REMOTE
  | KEYWORD_VAR
  | KEYWORD_STRING
  | KEYWORD_INT
  | KEYWORD_FLOAT
  | KEYWORD_BOOL
  | KEYWORD_CONTINUE
  | KEYWORD_BREAK

open Parsing;;
let _ = parse_error;;
# 1 "parser.mly"
 open Ast 
# 48 "parser.ml"
let yytransl_const = [|
  257 (* NEWLINE *);
  258 (* PLUS *);
  259 (* MINUS *);
  260 (* TIMES *);
  261 (* DIVIDE *);
  262 (* LOGICAL_OR *);
  263 (* LOGICAL_AND *);
  264 (* IS_EQUAL *);
  265 (* IS_NOT_EQUAL *);
  266 (* IS_LESS_THAN *);
  267 (* IS_GREATER_THAN *);
  268 (* LEFT_BRACE *);
  269 (* RIGHT_BRACE *);
  270 (* LEFT_BRACKET *);
  271 (* RIGHT_BRACKET *);
  272 (* LEFT_PARENTHE *);
  273 (* RIGHT_PARENTHE *);
  274 (* ASSIGNMENT *);
  275 (* ASSIGNNEW *);
  276 (* SEMICOLON *);
    0 (* EOF *);
  277 (* COMMA *);
  281 (* KEYWORD_FOR *);
  282 (* KEYWORD_IF *);
  283 (* KEYWORD_ELSE *);
  284 (* KEYWORD_FUNC *);
  285 (* KEYWORD_RETURN *);
  286 (* KEYWORD_AWAIT *);
  287 (* KEYWORD_ASYNC *);
  288 (* KEYWORD_REMOTE *);
  289 (* KEYWORD_VAR *);
  290 (* KEYWORD_STRING *);
  291 (* KEYWORD_INT *);
  292 (* KEYWORD_FLOAT *);
  293 (* KEYWORD_BOOL *);
  294 (* KEYWORD_CONTINUE *);
  295 (* KEYWORD_BREAK *);
    0|]

let yytransl_block = [|
  278 (* INT_LITERAL *);
  279 (* STRING_LITERAL *);
  280 (* VARIABLE *);
    0|]

let yylhs = "\255\255\
\001\000\002\000\002\000\002\000\003\000\004\000\004\000\007\000\
\008\000\008\000\009\000\009\000\009\000\009\000\009\000\009\000\
\009\000\011\000\012\000\012\000\005\000\005\000\005\000\005\000\
\010\000\010\000\010\000\006\000\006\000\006\000\013\000\013\000\
\000\000"

let yylen = "\002\000\
\002\000\000\000\002\000\002\000\010\000\000\000\002\000\002\000\
\000\000\002\000\003\000\003\000\003\000\003\000\003\000\001\000\
\001\000\003\000\000\000\003\000\001\000\001\000\001\000\001\000\
\001\000\001\000\004\000\000\000\002\000\002\000\002\000\003\000\
\002\000"

let yydefred = "\000\000\
\000\000\000\000\000\000\000\000\033\000\000\000\000\000\003\000\
\000\000\001\000\004\000\000\000\000\000\000\000\000\000\021\000\
\022\000\023\000\024\000\008\000\000\000\007\000\000\000\000\000\
\000\000\000\000\000\000\025\000\026\000\017\000\000\000\000\000\
\000\000\016\000\000\000\000\000\029\000\000\000\000\000\005\000\
\031\000\000\000\000\000\000\000\000\000\000\000\000\000\030\000\
\018\000\032\000\000\000\000\000\013\000\014\000\000\000\000\000\
\000\000\000\000\027\000\020\000"

let yydgoto = "\002\000\
\005\000\006\000\007\000\014\000\020\000\032\000\015\000\000\000\
\033\000\034\000\035\000\057\000\036\000"

let yysindex = "\011\000\
\001\255\000\000\001\255\236\254\000\000\020\000\001\255\000\000\
\010\255\000\000\000\000\028\255\033\255\044\255\028\255\000\000\
\000\000\000\000\000\000\000\000\033\255\000\000\053\255\070\255\
\255\254\255\254\060\255\000\000\000\000\000\000\040\255\063\255\
\037\255\000\000\065\255\255\254\000\000\033\255\042\255\000\000\
\000\000\040\255\040\255\040\255\040\255\040\255\040\255\000\000\
\000\000\000\000\069\255\069\255\000\000\000\000\054\255\032\255\
\066\255\040\255\000\000\000\000"

let yyrindex = "\000\000\
\078\000\000\000\078\000\000\000\000\000\000\000\078\000\000\000\
\000\000\000\000\000\000\064\255\000\000\000\000\064\255\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
\067\255\067\255\000\000\000\000\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\067\255\000\000\000\000\000\000\000\000\
\000\000\000\000\000\000\000\000\000\000\000\000\071\255\000\000\
\000\000\000\000\006\255\030\255\000\000\000\000\004\255\000\000\
\000\000\071\255\000\000\000\000"

let yygindex = "\000\000\
\000\000\003\000\000\000\067\000\028\000\231\255\000\000\000\000\
\228\255\000\000\000\000\025\000\000\000"

let yytablesize = 84
let yytable = "\026\000\
\037\000\003\000\039\000\009\000\015\000\008\000\011\000\011\000\
\011\000\011\000\048\000\001\000\027\000\051\000\052\000\053\000\
\054\000\055\000\056\000\010\000\028\000\029\000\030\000\011\000\
\015\000\012\000\011\000\031\000\004\000\056\000\012\000\012\000\
\012\000\042\000\043\000\044\000\045\000\041\000\042\000\043\000\
\044\000\045\000\050\000\042\000\043\000\044\000\045\000\012\000\
\023\000\046\000\012\000\013\000\058\000\027\000\046\000\042\000\
\043\000\044\000\045\000\046\000\021\000\028\000\029\000\030\000\
\024\000\049\000\016\000\017\000\018\000\019\000\025\000\046\000\
\044\000\045\000\038\000\040\000\047\000\002\000\059\000\028\000\
\006\000\022\000\060\000\019\000"

let yycheck = "\001\001\
\026\000\001\001\031\000\024\001\001\001\003\000\001\001\002\001\
\003\001\007\000\036\000\001\000\014\001\042\000\043\000\044\000\
\045\000\046\000\047\000\000\000\022\001\023\001\024\001\018\001\
\021\001\016\001\021\001\029\001\028\001\058\000\001\001\002\001\
\003\001\002\001\003\001\004\001\005\001\001\001\002\001\003\001\
\004\001\005\001\001\001\002\001\003\001\004\001\005\001\018\001\
\021\000\018\001\021\001\024\001\021\001\014\001\018\001\002\001\
\003\001\004\001\005\001\018\001\017\001\022\001\023\001\024\001\
\012\001\038\000\034\001\035\001\036\001\037\001\001\001\018\001\
\004\001\005\001\015\001\013\001\012\001\000\000\013\001\013\001\
\017\001\015\000\058\000\013\001"

let yynames_const = "\
  NEWLINE\000\
  PLUS\000\
  MINUS\000\
  TIMES\000\
  DIVIDE\000\
  LOGICAL_OR\000\
  LOGICAL_AND\000\
  IS_EQUAL\000\
  IS_NOT_EQUAL\000\
  IS_LESS_THAN\000\
  IS_GREATER_THAN\000\
  LEFT_BRACE\000\
  RIGHT_BRACE\000\
  LEFT_BRACKET\000\
  RIGHT_BRACKET\000\
  LEFT_PARENTHE\000\
  RIGHT_PARENTHE\000\
  ASSIGNMENT\000\
  ASSIGNNEW\000\
  SEMICOLON\000\
  EOF\000\
  COMMA\000\
  KEYWORD_FOR\000\
  KEYWORD_IF\000\
  KEYWORD_ELSE\000\
  KEYWORD_FUNC\000\
  KEYWORD_RETURN\000\
  KEYWORD_AWAIT\000\
  KEYWORD_ASYNC\000\
  KEYWORD_REMOTE\000\
  KEYWORD_VAR\000\
  KEYWORD_STRING\000\
  KEYWORD_INT\000\
  KEYWORD_FLOAT\000\
  KEYWORD_BOOL\000\
  KEYWORD_CONTINUE\000\
  KEYWORD_BREAK\000\
  "

let yynames_block = "\
  INT_LITERAL\000\
  STRING_LITERAL\000\
  VARIABLE\000\
  "

let yyact = [|
  (fun _ -> failwith "parser")
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_functions) in
    Obj.repr(
# 32 "parser.mly"
                  ( List.rev _1 )
# 227 "parser.ml"
               : Ast.functions))
; (fun __caml_parser_env ->
    Obj.repr(
# 35 "parser.mly"
  ( [] )
# 233 "parser.ml"
               : 'p_functions))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_functions) in
    Obj.repr(
# 36 "parser.mly"
                       ( _2 )
# 240 "parser.ml"
               : 'p_functions))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_function) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_functions) in
    Obj.repr(
# 37 "parser.mly"
                          ( _1::_2 )
# 248 "parser.ml"
               : 'p_functions))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 8 : string) in
    let _4 = (Parsing.peek_val __caml_parser_env 6 : 'p_parameters) in
    let _6 = (Parsing.peek_val __caml_parser_env 4 : 'p_type) in
    let _9 = (Parsing.peek_val __caml_parser_env 1 : 'p_statements) in
    Obj.repr(
# 44 "parser.mly"
    ( FunctionImpl(_2, _6, _4, _9)   )
# 258 "parser.ml"
               : 'p_function))
; (fun __caml_parser_env ->
    Obj.repr(
# 48 "parser.mly"
  ( [] )
# 264 "parser.ml"
               : 'p_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_parameter) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_parameters) in
    Obj.repr(
# 49 "parser.mly"
                            (  _1::_2  )
# 272 "parser.ml"
               : 'p_parameters))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : string) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_type) in
    Obj.repr(
# 52 "parser.mly"
                   (  NamedParameter(_1, _2)  )
# 280 "parser.ml"
               : 'p_parameter))
; (fun __caml_parser_env ->
    Obj.repr(
# 55 "parser.mly"
  ( [] )
# 286 "parser.ml"
               : 'p_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_expr) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr_list) in
    Obj.repr(
# 56 "parser.mly"
                     ( _1::_2 )
# 294 "parser.ml"
               : 'p_expr_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr) in
    Obj.repr(
# 59 "parser.mly"
                       ( BinaryOp(_1, Add, _3) )
# 302 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr) in
    Obj.repr(
# 60 "parser.mly"
                       ( BinaryOp(_1, Sub, _3) )
# 310 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr) in
    Obj.repr(
# 61 "parser.mly"
                       ( BinaryOp(_1, Mul, _3) )
# 318 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr) in
    Obj.repr(
# 62 "parser.mly"
                       ( BinaryOp(_1, Div, _3) )
# 326 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_expr) in
    Obj.repr(
# 63 "parser.mly"
                           ( AssignOp(_1, _3) )
# 334 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : 'p_literal) in
    Obj.repr(
# 64 "parser.mly"
                     ( TypedValue(_1) )
# 341 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 65 "parser.mly"
                   ( NamedVariable(_1) )
# 348 "parser.ml"
               : 'p_expr))
; (fun __caml_parser_env ->
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_type) in
    Obj.repr(
# 68 "parser.mly"
                                    ( SliceType(_3) )
# 355 "parser.ml"
               : 'p_slice_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 71 "parser.mly"
  ( [] )
# 361 "parser.ml"
               : 'p_element_list))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 2 : 'p_expr) in
    let _3 = (Parsing.peek_val __caml_parser_env 0 : 'p_element_list) in
    Obj.repr(
# 72 "parser.mly"
                              ( _1::_3 )
# 369 "parser.ml"
               : 'p_element_list))
; (fun __caml_parser_env ->
    Obj.repr(
# 75 "parser.mly"
                 (  StringType  )
# 375 "parser.ml"
               : 'p_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 76 "parser.mly"
                 (  IntegerType     )
# 381 "parser.ml"
               : 'p_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 77 "parser.mly"
                 (  FloatType   )
# 387 "parser.ml"
               : 'p_type))
; (fun __caml_parser_env ->
    Obj.repr(
# 78 "parser.mly"
                 (  BoolType    )
# 393 "parser.ml"
               : 'p_type))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : int) in
    Obj.repr(
# 81 "parser.mly"
               (  Integer(_1)  )
# 400 "parser.ml"
               : 'p_literal))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 0 : string) in
    Obj.repr(
# 82 "parser.mly"
                 ( String(_1) )
# 407 "parser.ml"
               : 'p_literal))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 3 : 'p_slice_type) in
    let _3 = (Parsing.peek_val __caml_parser_env 1 : 'p_element_list) in
    Obj.repr(
# 83 "parser.mly"
                                                     ( Slice(_1,_3) )
# 415 "parser.ml"
               : 'p_literal))
; (fun __caml_parser_env ->
    Obj.repr(
# 87 "parser.mly"
  ( [] )
# 421 "parser.ml"
               : 'p_statements))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_statements) in
    Obj.repr(
# 88 "parser.mly"
                          ( _2 )
# 428 "parser.ml"
               : 'p_statements))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_statement) in
    let _2 = (Parsing.peek_val __caml_parser_env 0 : 'p_statements) in
    Obj.repr(
# 89 "parser.mly"
                            ( _1::_2 )
# 436 "parser.ml"
               : 'p_statements))
; (fun __caml_parser_env ->
    let _1 = (Parsing.peek_val __caml_parser_env 1 : 'p_expr) in
    Obj.repr(
# 94 "parser.mly"
                                     ( Expr(_1) )
# 443 "parser.ml"
               : 'p_statement))
; (fun __caml_parser_env ->
    let _2 = (Parsing.peek_val __caml_parser_env 1 : 'p_expr) in
    Obj.repr(
# 95 "parser.mly"
                                   ( Return(_2) )
# 450 "parser.ml"
               : 'p_statement))
(* Entry functions *)
; (fun __caml_parser_env -> raise (Parsing.YYexit (Parsing.peek_val __caml_parser_env 0)))
|]
let yytables =
  { Parsing.actions=yyact;
    Parsing.transl_const=yytransl_const;
    Parsing.transl_block=yytransl_block;
    Parsing.lhs=yylhs;
    Parsing.len=yylen;
    Parsing.defred=yydefred;
    Parsing.dgoto=yydgoto;
    Parsing.sindex=yysindex;
    Parsing.rindex=yyrindex;
    Parsing.gindex=yygindex;
    Parsing.tablesize=yytablesize;
    Parsing.table=yytable;
    Parsing.check=yycheck;
    Parsing.error_function=parse_error;
    Parsing.names_const=yynames_const;
    Parsing.names_block=yynames_block }
let functions (lexfun : Lexing.lexbuf -> token) (lexbuf : Lexing.lexbuf) =
   (Parsing.yyparse yytables 1 lexfun lexbuf : Ast.functions)
