%{ open Ast %}

%token NEWLINE PLUS MINUS TIMES DIVIDE MODSIGN
%token LOGICAL_OR LOGICAL_AND IS_EQUAL IS_NOT_EQUAL IS_LESS_THAN IS_GREATER_THAN
%token IS_LESS_EQUAL IS_GREATER_EQUAL LOGICAL_NOT
%token LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET
%token LEFT_PARENTHE RIGHT_PARENTHE
%token ASSIGNMENT ASSIGNNEW SEMICOLON COLON EOF COMMA
%token <int> INT_LITERAL
%token <string> STRING_LITERAL
%token <float> FLOAT_LITERAL
%token <bool> BOOLEAN_LITERAL
%token <string> VARIABLE

%token KEYWORD_FOR KEYWORD_IF KEYWORD_ELSE KEYWORD_FUNC
%token KEYWORD_RETURN KEYWORD_AWAIT KEYWORD_ASYNC
%token KEYWORD_REMOTE KEYWORD_VAR KEYWORD_STRING
%token KEYWORD_INT KEYWORD_FLOAT KEYWORD_BOOL KEYWORD_FUTURE
%token KEYWORD_CONTINUE KEYWORD_BREAK
%token KEYWORD_GATHER KEYWORD_LEN KEYWORD_APPEND KEYWORD_VOID

%nonassoc NOELSE
%nonassoc KEYWORD_ELSE
%nonassoc COLON
%nonassoc COMMA
%nonassoc ASSIGNNEW
%nonassoc LEFT_PARENTHE
%nonassoc LEFT_BRACKET
%right ASSIGNMENT
%left LOGICAL_OR
%left LOGICAL_AND
%right LOGICAL_NOT
%left IS_EQUAL IS_NOT_EQUAL
%left IS_GREATER_THAN IS_LESS_THAN IS_GREATER_EQUAL IS_LESS_EQUAL
%left PLUS MINUS
%left TIMES DIVIDE MODSIGN
%right NEGATIVE

%start functions
%type <Ast.functions> functions

%%

functions:
  p_functions EOF { $1 }

p_functions:
| { [] }
| NEWLINE p_functions  { $2 }
| p_function_decl p_functions { $1::$2 }
/*| p_function p_functions  { $1::$2 } */

p_function_annotation:
  { FuncNormal }
| KEYWORD_ASYNC { FuncAsync }
| KEYWORD_ASYNC KEYWORD_REMOTE { FuncAsyncRemote }

p_function_decl:
  /*   the variable here is actually an ID     */
  /* 1. func FuncName(parameters) retType */
  p_function_annotation KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE 
  p_type LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /*{ FunctionProto($1, $3, [$7], $5) }*/
  { { ann = $1;
    fname = $3;
    typ = [$7];
    formals = $5;
    body = $10 } }
| /* 2. func FuncName(parameters)  */
  p_function_annotation KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /* { FunctionProto($1, $3, [], $5) } */
  { { ann = $1;
    fname = $3;
    typ = [];
    formals = $5;
    body = $9 } }
| /* 3. func FuncName(parameters)  (retType1, retType2, ...)  */
  p_function_annotation KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE 
  LEFT_PARENTHE p_type_list RIGHT_PARENTHE 
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /* { FunctionProto($1, $3, $8, $5) } */
  { { ann = $1;
    fname = $3;
    typ = $8;
    formals = $5;
    body = $12 } }


/*p_function_impl:*/
  /*LEFT_BRACE NEWLINE p_statements RIGHT_BRACE   {  FunctionImpl($3) }*/

/*p_function: */
/*  p_function_prototype p_function_impl  {  Function($1, $2)   }  */


p_type_list:
  /* empty type list is not allowed  */
| p_type    {  [$1]  }
| p_type COMMA p_type_list  {  $1::$3  } 

p_variable_list:
  /* empty variabie list is not allowed  */ 
| VARIABLE    {  [$1]  } 
| VARIABLE COMMA p_variable_list  {  $1::$3  }

p_parameters:
  { [] }
| p_parameter    {  [$1]  }
| p_parameter COMMA p_parameters  {  $1::$3  } 

p_parameter:
  VARIABLE p_type  {  ($2, $1)  }

p_expr_list:
  { [] }
| p_expr_list_required   {  $1  }

/*   at least one p_expr in the list  */
p_expr_list_required:
| p_expr   {  [$1]  }
| p_expr COMMA p_expr_list_required { $1::$3 }

p_expr:
  p_expr PLUS   p_expr { BinaryOp($1, Add, $3) }
| p_expr MINUS  p_expr { BinaryOp($1, Sub, $3) }
| p_expr TIMES  p_expr { BinaryOp($1, Mul, $3) }
| p_expr DIVIDE p_expr { BinaryOp($1, Div, $3) }
| p_expr MODSIGN p_expr { BinaryOp($1, Mod, $3) }
| p_expr IS_LESS_THAN p_expr { BinaryOp($1, LessThan, $3) }
| p_expr IS_GREATER_THAN p_expr {BinaryOp($1, GreaterThan, $3)}
| p_expr IS_NOT_EQUAL p_expr {BinaryOp($1, IsNotEqual, $3)}
| p_expr IS_EQUAL p_expr {BinaryOp($1, IsEqual, $3)}
| p_expr IS_LESS_EQUAL p_expr {BinaryOp($1, LessEqual, $3)}
| p_expr IS_GREATER_EQUAL p_expr {BinaryOp($1, GreaterEqual, $3)} 
| p_expr LOGICAL_AND p_expr {BinaryOp($1, LogicalAnd, $3)}
| p_expr LOGICAL_OR p_expr {BinaryOp($1, LogicalOr, $3)}

| MINUS p_expr %prec NEGATIVE {  UnaryOp(Negative, $2) }
| LOGICAL_NOT p_expr {  UnaryOp(LogicalNot, $2) }

/* p_expr_list_required will cause reduce/reduce conflict   */
/*  FIXME or do not support a, b = b, a */
| VARIABLE ASSIGNMENT p_expr { AssignOp($1, $3) }

/* literals */
| INT_LITERAL     { Integer($1) }
| STRING_LITERAL  { String($1)  }
| FLOAT_LITERAL   { Float($1)   }
| BOOLEAN_LITERAL { Bool($1)    }

/* identifier */
| VARIABLE        { NamedVariable($1) }

/*  the variable here is actually an ID (for a function)  */
| VARIABLE LEFT_PARENTHE p_expr_list RIGHT_PARENTHE { FunctionCall($1, $3)  }

/* built-in functions */
| KEYWORD_AWAIT  VARIABLE {  Await($2)  }
| KEYWORD_GATHER LEFT_PARENTHE p_expr_list RIGHT_PARENTHE { BuiltinFunctionCall(Gather, $3)  }
| KEYWORD_LEN    LEFT_PARENTHE p_expr_list RIGHT_PARENTHE { BuiltinFunctionCall(Len, $3)  }
| KEYWORD_APPEND LEFT_PARENTHE p_expr_list RIGHT_PARENTHE { BuiltinFunctionCall(Append, $3)  }

| LEFT_PARENTHE p_expr RIGHT_PARENTHE { $2 }

| p_slice_type LEFT_BRACE p_expr_list RIGHT_BRACE { SliceLiteral($1, List.length $3, $3) }
/* index */
| p_expr LEFT_BRACKET p_expr RIGHT_BRACKET { SliceIndex($1, $3) }
/* slice */
| p_expr LEFT_BRACKET p_expr COLON p_expr RIGHT_BRACKET { SliceSlice($1, $3, $5) }
| p_expr LEFT_BRACKET COLON p_expr RIGHT_BRACKET { SliceSlice($1, EmptyExpr, $4) }
| p_expr LEFT_BRACKET p_expr COLON RIGHT_BRACKET { SliceSlice($1, $3, EmptyExpr) }

p_slice_type:
  LEFT_BRACKET RIGHT_BRACKET p_type { SliceType($3) }

p_type:
  KEYWORD_STRING {  StringType  }
| KEYWORD_INT    {  IntegerType }
| KEYWORD_FLOAT  {  FloatType   }
| KEYWORD_BOOL   {  BoolType    }
| KEYWORD_FUTURE {  FutureType  }
| KEYWORD_VOID   {  VoidType    }
| p_slice_type   {  $1 }


p_statements:
  { [] }
| NEWLINE p_statements    { $2 }
| p_statement p_statements  { $1::$2 }


p_if_statement:
  KEYWORD_IF LEFT_PARENTHE p_expr RIGHT_PARENTHE p_statement KEYWORD_ELSE p_statement { IfStatement($3,$5, $7) }
| KEYWORD_IF LEFT_PARENTHE p_expr RIGHT_PARENTHE p_statement %prec NOELSE  {IfStatement($3, $5,EmptyStatement) }

/*  Declare:
    var a int = 5 
    var a int
    Simple declare:
    a := 5
 */

/*p_simple_statement: */                                                      /* need to check with local variables, works latter*/
/*  p_expr              { Expr($1) }                                        */
/*| KEYWORD_VAR p_variable_list p_type_list ASSIGNMENT p_expr_list_required { SimpleDeclare($3, $2, $5)  }*/
/*| KEYWORD_VAR p_variable_list p_type_list { SimpleDeclare($3, $2, [EmptyExpr])  }*/
/*| p_variable_list ASSIGNNEW p_expr_list_required { SimpleShortDecl($1, $3)  }*/                                  

p_statement:
  p_expr                 NEWLINE   { Expr($1) }
// Return
| KEYWORD_RETURN p_expr_list  NEWLINE   { Return($2) }
// If
| p_if_statement                   { $1 }
// Declare
| KEYWORD_VAR p_variable_list p_type ASSIGNMENT p_expr_list_required NEWLINE  { Declare($2, $3, $5)  }
| KEYWORD_VAR p_variable_list p_type NEWLINE  { Declare($2, $3, [EmptyExpr])  }
| p_variable_list ASSIGNNEW p_expr_list_required NEWLINE  { ShortDecl($1, $3)}
// For loop
| KEYWORD_FOR LEFT_PARENTHE p_expr SEMICOLON p_expr SEMICOLON p_expr RIGHT_PARENTHE p_statement {ForStatement($3, $5, $7, $9)}
| KEYWORD_FOR LEFT_PARENTHE SEMICOLON p_expr SEMICOLON RIGHT_PARENTHE p_statement {  ForStatement(EmptyExpr, $4, EmptyExpr, $7)}
| KEYWORD_FOR LEFT_PARENTHE SEMICOLON SEMICOLON RIGHT_PARENTHE p_statement  {ForStatement(EmptyExpr, EmptyExpr, EmptyExpr, $6)  }
| KEYWORD_FOR LEFT_PARENTHE SEMICOLON p_expr SEMICOLON p_expr RIGHT_PARENTHE p_statement {ForStatement(EmptyExpr, $4, $6 , $8)}
| KEYWORD_FOR LEFT_PARENTHE p_expr SEMICOLON p_expr SEMICOLON RIGHT_PARENTHE p_statement {ForStatement($3, $5, EmptyExpr, $8)}
// Break
| KEYWORD_BREAK   NEWLINE        {  Break  }
// Continue
| KEYWORD_CONTINUE   NEWLINE     {  Continue  }
// Block
| LEFT_BRACE NEWLINE p_statements RIGHT_BRACE NEWLINE {Block($3)}

