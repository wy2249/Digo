{ open Parser }

rule tokenize = parse
  [' ' '\t' ] { tokenize lexbuf }
| ['\r' '\n'] { NEWLINE }

| "//"     { comment_line lexbuf }
| "/*"     { comment_block lexbuf}

| '+' { PLUS }
| '-' { MINUS }
| '*' { TIMES }
| '/' { DIVIDE }
| "||" { LOGICAL_OR }
| "&&" { LOGICAL_AND }
| "==" { IS_EQUAL }
| "!=" { IS_NOT_EQUAL }
| "<" { IS_LESS_THAN }
| ">" { IS_GREATER_THAN }
| ">=" {IS_GREATER_EQUAL}
| "<=" {IS_LESS_EQUAL}

| '!' { LOGICAL_NOT  }

| '{' { LEFT_BRACE }
| '}' { RIGHT_BRACE }
| '[' { LEFT_BRACKET }
| ']' { RIGHT_BRACKET }
| '(' { LEFT_PARENTHE }
| ')' { RIGHT_PARENTHE }

| ',' { COMMA }

| '=' { ASSIGNMENT }
| ":=" { ASSIGNNEW }   (* TODO *)
| ':' {COLON}
| ';' { SEMICOLON }
| '%' {  MODSIGN }
| eof { EOF }

| "for"     { KEYWORD_FOR     }
| "if"      { KEYWORD_IF      }
| "else"    { KEYWORD_ELSE    }
| "func"    { KEYWORD_FUNC    }
| "return"  { KEYWORD_RETURN  }
| "await"   { KEYWORD_AWAIT   }
| "async"   { KEYWORD_ASYNC   }
| "remote"  { KEYWORD_REMOTE  }
| "var"     { KEYWORD_VAR     }
| "string"  { KEYWORD_STRING  }
| "int"     { KEYWORD_INT     }
| "float"   { KEYWORD_FLOAT   }
| "bool"    { KEYWORD_BOOL    }
| "continue"{ KEYWORD_CONTINUE}
| "break"   { KEYWORD_BREAK   }

| "gather"  { KEYWORD_GATHER  }
| "len"     { KEYWORD_LEN     }
| "append"  { KEYWORD_APPEND  }

| "future"  { KEYWORD_FUTURE  }
| "void"	{ KEYWORD_VOID    }

| "true" | "false" as boollit { BOOLEAN_LITERAL(bool_of_string boollit)}
| ['0'-'9']+ as lit { INT_LITERAL(int_of_string lit) }
| ['a'-'z' 'A'-'Z'] ['a'-'z' 'A'-'Z' '0'-'9' '_']* as var { VARIABLE(var) }
| '"' ([^ '"' ]*) '"' as str { STRING_LITERAL(str) }
| (['0'-'9']+)'.'(['0'-'9']+) as lxm { FLOAT_LITERAL(float_of_string lxm)}

and comment_line = parse
  '\n'  { tokenize lexbuf }
  | _   { comment_line lexbuf }

and comment_block = parse
  "*/"  { tokenize lexbuf }
  | _   { comment_block lexbuf }
