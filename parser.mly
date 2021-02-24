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
  p_functions EOF { List.rev $1 }

p_functions:
| { [] }
| NEWLINE p_functions  { $2 }
| p_function p_functions  { $1::$2 }


p_function:
  KEYWORD_FUNC VARIABLE LEFT_PARENTHE p_parameters RIGHT_PARENTHE p_type
  LEFT_BRACE NEWLINE p_statements RIGHT_BRACE
  /*  func FuncName(parameters) retType { statements }  */
    { FunctionImpl($2, $6, $4, $9)   } 
  /*  function name,  type of return value,  parameters,   statements    */

p_parameters:
  { [] }
| p_parameter p_parameters  {  $1::$2  } 

p_parameter:
  VARIABLE p_type  {  NamedParameter($1, $2)  }

p_expr_list:
| { [] }
| p_expr p_expr_list { $1::$2 }

p_expr:
  p_expr PLUS   p_expr { BinaryOp($1, Add, $3) }
| p_expr MINUS  p_expr { BinaryOp($1, Sub, $3) }
| p_expr TIMES  p_expr { BinaryOp($1, Mul, $3) }
| p_expr DIVIDE p_expr { BinaryOp($1, Div, $3) }
| p_expr ASSIGNMENT p_expr { AssignOp($1, $3) }
| p_literal          { TypedValue($1) }
| VARIABLE         { NamedVariable($1) }

p_slice_type:
  LEFT_BRACKET RIGHT_BRACKET p_type { SliceType($3) }

p_element_list: 
  { [] }
| p_expr COMMA p_element_list { $1::$3 }

p_type:
  KEYWORD_STRING {  StringType  }
| KEYWORD_INT    {  IntegerType     }
| KEYWORD_FLOAT  {  FloatType   }
| KEYWORD_BOOL   {  BoolType    }

p_literal:
  INT_LITERAL  {  Integer($1)  }
| STRING_LITERAL { String($1) }
| p_slice_type LEFT_BRACE p_element_list RIGHT_BRACE { Slice($1,$3) }


p_statements:
| { [] }
| NEWLINE p_statements    { $2 }
| p_statement p_statements  { $1::$2 }



p_statement:
  p_expr                 NEWLINE     { Expr($1) }
| KEYWORD_RETURN p_expr  NEWLINE   { Return($2) }
