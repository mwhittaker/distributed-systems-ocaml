{
  open RedisParser
}

let white   = [' ' '\t']+
let newline = '\r' | '\n' | "\r\n"
let ident   = ['a'-'z' 'A'-'Z' '0'-'9' '_'] ['a'-'z' 'A'-'Z' '0'-'9' '_']*

rule token = parse
  | white       { token lexbuf }
  | newline     { token lexbuf }
  | "GET"       { GET          }
  | "SET"       { SET          }
  | "APPEND"    { APPEND       }
  | "STRLEN"    { STRLEN       }
  | ident as id { VAR id       }
