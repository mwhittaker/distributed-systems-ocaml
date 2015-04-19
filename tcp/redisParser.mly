%{
  open RedisOp
%}

%token <string> VAR
%token GET
%token SET
%token APPEND
%token STRLEN

%start <RedisOp.op> op

%%

op:
  | GET VAR        { Get $2          }
  | SET VAR VAR    { Set ($2, $3)    }
  | APPEND VAR VAR { Append ($2, $3) }
  | STRLEN VAR     { Strlen ($2)     }
  ;
