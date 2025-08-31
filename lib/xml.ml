open Types

type xml_config = {
  root_element: string;
  array_element: string;
  array_item: string;
  indent_size: int;
  include_declaration: bool;
  encoding: string;
}

let default_config = {
  root_element = "root";
  array_element = "array";
  array_item = "item";
  indent_size = 2;
  include_declaration = true;
  encoding = "UTF-8";
}

exception XmlConversionError of string

let escape_xml_content s =
  let buffer = Buffer.create (String.length s * 2) in
  String.iter (function
    | '<' -> Buffer.add_string buffer "&lt;"
    | '>' -> Buffer.add_string buffer "&gt;"
    | '&' -> Buffer.add_string buffer "&amp;"
    | '"' -> Buffer.add_string buffer "&quot;"
    | '\'' -> Buffer.add_string buffer "&#39;"
    | c -> Buffer.add_char buffer c
  ) s;
  Buffer.contents buffer

let escape_xml_attribute s =
  let buffer = Buffer.create (String.length s * 2) in
  String.iter (function
    | '<' -> Buffer.add_string buffer "&lt;"
    | '>' -> Buffer.add_string buffer "&gt;"
    | '&' -> Buffer.add_string buffer "&amp;"
    | '"' -> Buffer.add_string buffer "&quot;"
    | '\'' -> Buffer.add_string buffer "&#39;"
    | '\n' -> Buffer.add_string buffer "&#10;"
    | '\r' -> Buffer.add_string buffer "&#13;"
    | '\t' -> Buffer.add_string buffer "&#9;"
    | c -> Buffer.add_char buffer c
  ) s;
  Buffer.contents buffer

let make_indent config level = 
  String.make (level * config.indent_size) ' '

let is_valid_xml_name name =
  let len = String.length name in
  if len = 0 then false
  else
    let is_name_start_char = function
      | 'A'..'Z' | 'a'..'z' | '_' | ':' -> true
      | _ -> false
    in
    let is_name_char = function
      | 'A'..'Z' | 'a'..'z' | '0'..'9' | '.' | '-' | '_' | ':' -> true
      | _ -> false
    in
    is_name_start_char name.[0] &&
    (let rec check i =
       if i >= len then true
       else if is_name_char name.[i] then check (i + 1)
       else false
     in check 1)

let sanitize_xml_name name =
  if is_valid_xml_name name then name
  else
    let buffer = Buffer.create (String.length name) in
    String.iteri (fun i c ->
      match c with
      | 'A'..'Z' | 'a'..'z' | '_' -> Buffer.add_char buffer c
      | '0'..'9' | '.' | '-' when i > 0 -> Buffer.add_char buffer c
      | _ -> Buffer.add_char buffer '_'
    ) name;
    let result = Buffer.contents buffer in
    if String.length result = 0 then "element"
    else if not (is_valid_xml_name result) then "element"
    else result

let rec json_to_xml_element config indent_level element_name json =
  let indent = make_indent config indent_level in
  
  match json with
  | Null -> 
    Printf.sprintf "%s<%s xsi:nil=\"true\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"/>" 
      indent element_name
  
  | Bool true -> 
    Printf.sprintf "%s<%s type=\"boolean\">true</%s>" indent element_name element_name
  
  | Bool false -> 
    Printf.sprintf "%s<%s type=\"boolean\">false</%s>" indent element_name element_name
  
  | Int n -> 
    Printf.sprintf "%s<%s type=\"integer\">%d</%s>" indent element_name n element_name
  
  | Float f -> 
    Printf.sprintf "%s<%s type=\"number\">%g</%s>" indent element_name f element_name
  
  | String s -> 
    let escaped = escape_xml_content s in
    Printf.sprintf "%s<%s type=\"string\">%s</%s>" indent element_name escaped element_name
  
  | Array [] ->
    Printf.sprintf "%s<%s type=\"array\"/>" indent element_name
  
  | Array values ->
    let items = List.map (fun value ->
      json_to_xml_element config (indent_level + 1) config.array_item value
    ) values in
    Printf.sprintf "%s<%s type=\"array\">\n%s\n%s</%s>" 
      indent element_name (String.concat "\n" items) indent element_name
  
  | Object [] ->
    Printf.sprintf "%s<%s type=\"object\"/>" indent element_name
  
  | Object pairs ->
    let elements = List.map (fun (key, value) ->
      let safe_key = sanitize_xml_name key in
      json_to_xml_element config (indent_level + 1) safe_key value
    ) pairs in
    Printf.sprintf "%s<%s type=\"object\">\n%s\n%s</%s>" 
      indent element_name (String.concat "\n" elements) indent element_name

let json_to_xml ?(config = default_config) json =
  let declaration = 
    if config.include_declaration then
      Printf.sprintf "<?xml version=\"1.0\" encoding=\"%s\"?>\n" config.encoding
    else ""
  in
  let body = json_to_xml_element config 0 config.root_element json in
  declaration ^ body

let rec json_to_simple_xml_helper config indent_level element_name json =
  let indent = make_indent config indent_level in
  
  match json with
  | Null -> Printf.sprintf "%s<%s/>" indent element_name
  
  | Bool b -> 
    Printf.sprintf "%s<%s>%s</%s>" indent element_name (string_of_bool b) element_name
  
  | Int n -> 
    Printf.sprintf "%s<%s>%d</%s>" indent element_name n element_name
  
  | Float f -> 
    Printf.sprintf "%s<%s>%g</%s>" indent element_name f element_name
  
  | String s -> 
    let escaped = escape_xml_content s in
    Printf.sprintf "%s<%s>%s</%s>" indent element_name escaped element_name
  
  | Array [] ->
    Printf.sprintf "%s<%s/>" indent element_name
  
  | Array values ->
    let items = List.map (fun value ->
      json_to_simple_xml_helper config (indent_level + 1) config.array_item value
    ) values in
    Printf.sprintf "%s<%s>\n%s\n%s</%s>" 
      indent element_name (String.concat "\n" items) indent element_name
  
  | Object [] ->
    Printf.sprintf "%s<%s/>" indent element_name
  
  | Object pairs ->
    let elements = List.map (fun (key, value) ->
      let safe_key = sanitize_xml_name key in
      json_to_simple_xml_helper config (indent_level + 1) safe_key value
    ) pairs in
    Printf.sprintf "%s<%s>\n%s\n%s</%s>" 
      indent element_name (String.concat "\n" elements) indent element_name

let json_to_simple_xml ?(config = default_config) json =
  let declaration = 
    if config.include_declaration then
      Printf.sprintf "<?xml version=\"1.0\" encoding=\"%s\"?>\n" config.encoding
    else ""
  in
  let body = json_to_simple_xml_helper config 0 config.root_element json in
  declaration ^ body

let rec json_to_attributes_xml_helper config indent_level element_name json =
  let indent = make_indent config indent_level in
  
  match json with
  | Object pairs ->
    let (attrs, children) = List.partition (fun (_, value) ->
      match value with
      | String _ | Int _ | Float _ | Bool _ -> true
      | _ -> false
    ) pairs in
    
    let attr_strings = List.map (fun (key, value) ->
      let safe_key = sanitize_xml_name key in
      let escaped_value = match value with
        | String s -> escape_xml_attribute s
        | Int n -> string_of_int n
        | Float f -> string_of_float f
        | Bool b -> string_of_bool b
        | _ -> ""
      in
      Printf.sprintf "%s=\"%s\"" safe_key escaped_value
    ) attrs in
    
    let attr_part = 
      if attr_strings = [] then ""
      else " " ^ String.concat " " attr_strings
    in
    
    if children = [] then
      Printf.sprintf "%s<%s%s/>" indent element_name attr_part
    else
      let child_elements = List.map (fun (key, value) ->
        let safe_key = sanitize_xml_name key in
        json_to_attributes_xml_helper config (indent_level + 1) safe_key value
      ) children in
      Printf.sprintf "%s<%s%s>\n%s\n%s</%s>" 
        indent element_name attr_part (String.concat "\n" child_elements) indent element_name
  
  | _ -> json_to_simple_xml_helper config indent_level element_name json

let json_to_attributes_xml ?(config = default_config) json =
  let declaration = 
    if config.include_declaration then
      Printf.sprintf "<?xml version=\"1.0\" encoding=\"%s\"?>\n" config.encoding
    else ""
  in
  let body = json_to_attributes_xml_helper config 0 config.root_element json in
  declaration ^ body

type conversion_style = 
  | Typed      (* Include type attributes *)
  | Simple     (* Clean XML without type info *)
  | Attributes (* Use XML attributes for simple values *)

let json_to_xml_with_style ?(config = default_config) style json =
  match style with
  | Typed -> json_to_xml ~config json
  | Simple -> json_to_simple_xml ~config json
  | Attributes -> json_to_attributes_xml ~config json

let create_config 
    ?root_element 
    ?array_element 
    ?array_item 
    ?indent_size 
    ?include_declaration 
    ?encoding 
    () =
  {
    root_element = Option.value root_element ~default:default_config.root_element;
    array_element = Option.value array_element ~default:default_config.array_element;
    array_item = Option.value array_item ~default:default_config.array_item;
    indent_size = Option.value indent_size ~default:default_config.indent_size;
    include_declaration = Option.value include_declaration ~default:default_config.include_declaration;
    encoding = Option.value encoding ~default:default_config.encoding;
  }