%{
open Types
%}

%token <int> INT
%token <float> FLOAT
%token <string> STRING
%token TRUE
%token FALSE
%token NULL
%token LEFT_BRACE
%token RIGHT_BRACE
%token LEFT_BRACKET
%token RIGHT_BRACKET
%token COLON
%token COMMA
%token EOF

%start <json_value> json_value

%%

json_value:
  | value EOF { $1 }

value:
  | NULL { Null }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | INT { Int $1 }
  | FLOAT { Float $1 }
  | STRING { String $1 }
  | LEFT_BRACKET array_elements RIGHT_BRACKET { Array $2 }
  | LEFT_BRACE object_elements RIGHT_BRACE { Object $2 }

array_elements:
  | (* empty *) { [] }
  | value { [$1] }
  | value COMMA array_elements { $1 :: $3 }

object_elements:
  | (* empty *) { [] }
  | object_pair { [$1] }
  | object_pair COMMA object_elements { $1 :: $3 }

object_pair:
  | STRING COLON value { ($1, $3) }