type json_value = Types.json_value =
  | Null
  | Bool of bool
  | Int of int
  | Float of float
  | String of string
  | Array of json_value list
  | Object of (string * json_value) list

let json_to_string = Types.json_to_string
let json_to_string_pretty = Types.json_to_string_pretty

exception ParseError of string

let parse_json input =
  let lexbuf = Lexing.from_string input in
  try
    Parser.json_value Lexer.token lexbuf
  with
  | Lexer.SyntaxError msg -> raise (ParseError msg)
  | Parser.Error ->
      let pos = Lexing.lexeme_start_p lexbuf in
      let line = pos.pos_lnum in
      let col = pos.pos_cnum - pos.pos_bol + 1 in
      raise (ParseError (Printf.sprintf "Parse error at line %d, column %d" line col))