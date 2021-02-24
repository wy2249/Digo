%{ open Ast %}

%token NEWLINE PLUS MINUS TIMES DIVIDE
%token LOGICAL_OR LOGICAL_AND IS_EQUAL IS_NOT_EQUAL IS_LESS_THAN IS_GREATER_THAN
%token LEFT_BRACE RIGHT_BRACE LEFT_BRACKET RIGHT_BRACKET
%token LEFT_PARENTHE RIGHT_PARENTHE
%token ASSIGNMENT ASSIGNNEW SEMICOLON EOF COMMA
%token <int> INT_LITERAL
%token <string> STRING_LITERAL
%token <string> VARIABLE

%token KEYWORD_FOR KEYWORD_IF KEYWORD_ELSE KEYWORD_FUNC
%token KEYWORD_RETURN KEYWORD_AWAIT KEYWORD_ASYNC
%token KEYWORD_REMOTE KEYWORD_VAR KEYWORD_STRING
%token KEYWORD_INT KEYWORD_FLOAT KEYWORD_BOOL
%token KEYWORD_CONTINUE KEYWORD_BREAK

%right ASSIGNMENT
%left LOGICAL_OR
%left LOGICAL_AND
%left IS_EQUAL IS_NOT_EQUAL
%left IS_GREATER_THAN IS_LESS_THAN
%left PLUS MINUS
%left TIMES DIVIDE

%start functions
%type <Ast.functions> functions

%%

functions:
  p_functions EOF { $1 }

p_functions:
| { [] }
| NEWLINE p_functions  { $2 }
| p_function p_functions  { $1::$2 }


p_function:
  KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE p_type
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /*  func FuncName(parameters) retType { statements }  */
    { FunctionImpl($2, [$6], $4, $9)   } 
  /*  function name,  type of return value,  parameters,   statements    */
| KEYWORD_ASYNC KEYWORD_REMOTE KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE p_type
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
    { RemoteFunctionImpl($4, [$8], $6, $11)   } 
| KEYWORD_ASYNC KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE p_type
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
    { AsyncFunctionImpl($3, [$7], $5, $10)   } 
  /*   Functions with multiple return values:  */  
| KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE LEFT_PARENTHE p_type_list RIGHT_PARENTHE
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /*  func FuncName(parameters) (retType1, retType2,...) { statements }  */
    { FunctionImpl($2, $7, $4, $11)   } 
  /*  function name,  type of return values,  parameters,   statements    */
| KEYWORD_ASYNC KEYWORD_REMOTE KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE LEFT_PARENTHE p_type_list RIGHT_PARENTHE
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
    { RemoteFunctionImpl($4, $9, $6, $13)   } 
| KEYWORD_ASYNC KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE LEFT_PARENTHE p_type_list RIGHT_PARENTHE
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
    { AsyncFunctionImpl($3, $8, $5, $12)   } 

p_parameters:
  { [] }
| p_parameter    {  [$1]  }
| p_parameter COMMA p_parameters  {  $1::$3  } 

p_parameter:
  VARIABLE p_type  {  NamedParameter($1, $2)  }

p_expr_list:
| { [] }
| p_expr   {  [$1]  }
| p_expr COMMA p_expr_list { $1::$3 }

p_expr:
  p_expr PLUS   p_expr { BinaryOp($1, Add, $3) }
| p_expr MINUS  p_expr { BinaryOp($1, Sub, $3) }
| p_expr TIMES  p_expr { BinaryOp($1, Mul, $3) }
| p_expr DIVIDE p_expr { BinaryOp($1, Div, $3) }
| p_expr IS_LESS_THAN p_expr { BinaryOp($1, LessThan, $3) }
| p_expr ASSIGNMENT p_expr { AssignOp($1, $3) }
| p_literal          { Literal($1) }
| VARIABLE         { NamedVariable($1) }
| VARIABLE LEFT_PARENTHE p_expr_list RIGHT_PARENTHE { FunctionCall($1, $3)  }
| LEFT_PARENTHE p_expr RIGHT_PARENTHE { $2 }
| p_slice_type LEFT_BRACE p_expr_list RIGHT_BRACE { SliceLiteral($1, List.length $3, $3) }

p_type_list:
  { [] }
| p_type    {  [$1]  }
| p_type COMMA p_type_list  {  $1::$3  } 

p_slice_type:
  LEFT_BRACKET RIGHT_BRACKET p_type { SliceType($3) }

p_type:
  KEYWORD_STRING {  StringType  }
| KEYWORD_INT    {  IntegerType }
| KEYWORD_FLOAT  {  FloatType   }
| KEYWORD_BOOL   {  BoolType    }
| p_slice_type   {  $1 }

p_literal:
  INT_LITERAL  {  Integer($1)  }
| STRING_LITERAL { String($1) }


p_statements:
| { [] }
| NEWLINE p_statements    { $2 }
| p_statement p_statements  { $1::$2 }


p_if_statement:
  KEYWORD_IF p_expr LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE KEYWORD_ELSE LEFT_BRACE
  p_statements
  RIGHT_BRACE
  { IfStatement($2, $5, $9) }
| KEYWORD_IF p_expr LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE KEYWORD_ELSE p_if_statement
  { IfStatement($2, $5, [$8]) }
| KEYWORD_IF p_expr LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE
  { IfStatement($2, $5, [EmptyStatement]) }

/*  var a int = 5 
    var a int
    a := 5
 */

p_simple_statement:
  p_expr              { SimpleExpr($1) }
| KEYWORD_VAR VARIABLE p_type ASSIGNMENT p_expr { SimpleDeclare($3, $2, $5)  }
| KEYWORD_VAR VARIABLE p_type { SimpleDeclare($3, $2, EmptyExpr)  }
| VARIABLE ASSIGNNEW p_expr { SimpleShortDecl($1, $3)  }

p_statement:
  p_expr                 NEWLINE   { Expr($1) }
| KEYWORD_RETURN p_expr  NEWLINE   { Return($2) }

| KEYWORD_VAR VARIABLE p_type ASSIGNMENT p_expr  NEWLINE  { Declare($3, $2, $5)  }
| KEYWORD_VAR VARIABLE p_type                    NEWLINE  { Declare($3, $2, EmptyExpr)  }
| VARIABLE ASSIGNNEW p_expr                      NEWLINE  { ShortDecl($1, $3)  }

| p_if_statement                   { $1 }
| KEYWORD_FOR p_simple_statement SEMICOLON p_expr SEMICOLON p_simple_statement LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE
  {  ForStatement($2, $4, $6, $9)  }
| KEYWORD_FOR p_expr LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE
  {  ForStatement(EmptySimpleStatement, $2, EmptySimpleStatement, $5)  }
| KEYWORD_FOR LEFT_BRACE NEWLINE
  p_statements
  RIGHT_BRACE
  {  ForStatement(EmptySimpleStatement, EmptyExpr, EmptySimpleStatement, $4)  }

| KEYWORD_BREAK   NEWLINE        {  Break  }
| KEYWORD_CONTINUE   NEWLINE     {  Continue  }

