{
open Parser

exception SyntaxError of string
}

let white = [' ' '\t']
let digit = ['0'-'9']
let int = '-'? ('0' | ['1'-'9'] digit*)
let frac = '.' digit+
let exp = ['e' 'E'] ['-' '+']? digit+
let float = int (frac | exp | frac exp)

rule token = parse
  | white+     { token lexbuf }
  | '\n'       { token lexbuf }
  | int        { INT (int_of_string (Lexing.lexeme lexbuf)) }
  | float      { FLOAT (float_of_string (Lexing.lexeme lexbuf)) }
  | "true"     { TRUE }
  | "false"    { FALSE }
  | "null"     { NULL }
  | '"'        { read_string (Buffer.create 17) lexbuf }
  | '{'        { LEFT_BRACE }
  | '}'        { RIGHT_BRACE }
  | '['        { LEFT_BRACKET }
  | ']'        { RIGHT_BRACKET }
  | ':'        { COLON }
  | ','        { COMMA }
  | _ { raise (SyntaxError ("Unexpected char: " ^ Lexing.lexeme lexbuf)) }
  | eof        { EOF }

and read_string buf = parse
  | '"'       { STRING (Buffer.contents buf) }
  | '\\' '/'  { Buffer.add_char buf '/'; read_string buf lexbuf }
  | '\\' '\\' { Buffer.add_char buf '\\'; read_string buf lexbuf }
  | '\\' 'b'  { Buffer.add_char buf '\b'; read_string buf lexbuf }
  | '\\' 'f'  { Buffer.add_char buf '\012'; read_string buf lexbuf }
  | '\\' 'n'  { Buffer.add_char buf '\n'; read_string buf lexbuf }
  | '\\' 'r'  { Buffer.add_char buf '\r'; read_string buf lexbuf }
  | '\\' 't'  { Buffer.add_char buf '\t'; read_string buf lexbuf }
  | '\\' '"'  { Buffer.add_char buf '"'; read_string buf lexbuf }
  | '\\' 'u' (['0'-'9' 'a'-'f' 'A'-'F'] as a) (['0'-'9' 'a'-'f' 'A'-'F'] as b) (['0'-'9' 'a'-'f' 'A'-'F'] as c) (['0'-'9' 'a'-'f' 'A'-'F'] as d)
    { let hex = String.make 1 a ^ String.make 1 b ^ String.make 1 c ^ String.make 1 d in
      let code = int_of_string ("0x" ^ hex) in
      Buffer.add_utf_8_uchar buf (Uchar.of_int code);
      read_string buf lexbuf }
  | '\\' _    { raise (SyntaxError ("Illegal string escape: " ^ Lexing.lexeme lexbuf)) }
  | [^ '"' '\\']+
    { Buffer.add_string buf (Lexing.lexeme lexbuf);
      read_string buf lexbuf
    }
  | eof { raise (SyntaxError ("String is not terminated")) }