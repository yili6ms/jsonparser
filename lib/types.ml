type json_value =
  | Null
  | Bool of bool
  | Int of int
  | Float of float
  | String of string
  | Array of json_value list
  | Object of (string * json_value) list

let rec json_to_string = function
  | Null -> "null"
  | Bool true -> "true"
  | Bool false -> "false"
  | Int n -> string_of_int n
  | Float f -> string_of_float f
  | String s -> "\"" ^ String.escaped s ^ "\""
  | Array values ->
    "[" ^ String.concat ", " (List.map json_to_string values) ^ "]"
  | Object pairs ->
    let pair_to_string (key, value) =
      "\"" ^ String.escaped key ^ "\": " ^ json_to_string value
    in
    "{" ^ String.concat ", " (List.map pair_to_string pairs) ^ "}"

let make_indent level = String.make (level * 2) ' '

let rec json_to_string_pretty ?(indent_level=0) = function
  | Null -> "null"
  | Bool true -> "true"
  | Bool false -> "false"
  | Int n -> string_of_int n
  | Float f -> string_of_float f
  | String s -> "\"" ^ String.escaped s ^ "\""
  | Array [] -> "[]"
  | Array values ->
    let current_indent = make_indent indent_level in
    let next_indent = make_indent (indent_level + 1) in
    let formatted_values = List.map (json_to_string_pretty ~indent_level:(indent_level + 1)) values in
    "[\n" ^ next_indent ^ String.concat (",\n" ^ next_indent) formatted_values ^ "\n" ^ current_indent ^ "]"
  | Object [] -> "{}"
  | Object pairs ->
    let current_indent = make_indent indent_level in
    let next_indent = make_indent (indent_level + 1) in
    let pair_to_string (key, value) =
      next_indent ^ "\"" ^ String.escaped key ^ "\": " ^ json_to_string_pretty ~indent_level:(indent_level + 1) value
    in
    "{\n" ^ String.concat ",\n" (List.map pair_to_string pairs) ^ "\n" ^ current_indent ^ "}"