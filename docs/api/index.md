---
layout: default
title: API Reference
---

# API Reference

Complete API documentation for the OCaml JSON Parser library.

## Module: `Jsonparser.Json`

The main module providing JSON parsing and formatting functionality.

### Types

#### `json_value`

```ocaml
type json_value =
  | Null
  | Bool of bool
  | Int of int
  | Float of float
  | String of string
  | Array of json_value list
  | Object of (string * json_value) list
```

Represents a JSON value using an algebraic data type. This provides type safety and enables pattern matching for processing JSON data.

**Constructors:**
- `Null` - Represents JSON `null`
- `Bool of bool` - JSON boolean values (`true`/`false`)
- `Int of int` - JSON integer numbers
- `Float of float` - JSON floating-point numbers
- `String of string` - JSON strings
- `Array of json_value list` - JSON arrays
- `Object of (string * json_value) list` - JSON objects as key-value pairs

### Functions

#### `parse_json`

```ocaml
val parse_json : string -> json_value
```

**Description:** Parses a JSON string into a `json_value` AST.

**Parameters:**
- `string` - The JSON string to parse

**Returns:** A `json_value` representing the parsed JSON

**Raises:** 
- `ParseError of string` - When the input is not valid JSON

**Example:**
```ocaml
let json = parse_json {|{"name": "Alice", "age": 30}|}
(* Returns: Object [("name", String "Alice"); ("age", Int 30)] *)
```

#### `json_to_string`

```ocaml
val json_to_string : json_value -> string
```

**Description:** Converts a `json_value` to a compact JSON string representation.

**Parameters:**
- `json_value` - The JSON value to serialize

**Returns:** A compact JSON string

**Example:**
```ocaml
let json = Object [("name", String "Alice"); ("age", Int 30)]
let compact = json_to_string json
(* Returns: {"name":"Alice","age":30} *)
```

#### `json_to_string_pretty`

```ocaml
val json_to_string_pretty : ?indent_level:int -> json_value -> string
```

**Description:** Converts a `json_value` to a pretty-printed JSON string with indentation.

**Parameters:**
- `?indent_level:int` - Optional starting indentation level (default: 0)
- `json_value` - The JSON value to serialize

**Returns:** A formatted JSON string with indentation

**Example:**
```ocaml
let json = Object [("users", Array [String "Alice"; String "Bob"])]
let pretty = json_to_string_pretty json
(*
Returns:
{
  "users": [
    "Alice",
    "Bob"
  ]
}
*)
```

### Exception Types

#### `ParseError`

```ocaml
exception ParseError of string
```

**Description:** Raised when JSON parsing fails due to invalid syntax.

**Fields:**
- `string` - Error message describing the parsing failure

**Common Causes:**
- Unterminated strings
- Invalid escape sequences
- Malformed numbers
- Unexpected characters
- Missing commas or colons

**Example:**
```ocaml
try
  let _ = parse_json {|{"invalid": json}|} in
  ()
with
  ParseError msg -> Printf.printf "Parse error: %s\n" msg
```

## Module: `Jsonparser.Types`

Low-level types and utilities (typically not used directly).

### Types

Same `json_value` type as exported by the main `Json` module.

### Functions

#### `json_to_string`

Low-level compact formatting function.

#### `json_to_string_pretty`

Low-level pretty-printing function with configurable indentation.

#### `make_indent`

```ocaml
val make_indent : int -> string
```

Utility function for generating indentation strings.

## Usage Patterns

### Basic Parsing

```ocaml
open Jsonparser.Json

let parse_and_process json_str =
  try
    let parsed = parse_json json_str in
    match parsed with
    | Object pairs -> (* Process object *)
        List.iter (fun (key, value) -> 
          Printf.printf "Key: %s\n" key
        ) pairs
    | Array values -> (* Process array *)
        List.iteri (fun i value ->
          Printf.printf "Item %d: %s\n" i (json_to_string value)
        ) values
    | _ -> (* Handle other types *)
        Printf.printf "Value: %s\n" (json_to_string parsed)
  with
    ParseError msg -> Printf.printf "Error: %s\n" msg
```

### Constructing JSON

```ocaml
let create_user_json name age hobbies =
  Object [
    ("name", String name);
    ("age", Int age);
    ("hobbies", Array (List.map (fun h -> String h) hobbies));
    ("active", Bool true);
    ("metadata", Null)
  ]

let user = create_user_json "Alice" 30 ["reading"; "coding"]
let json_str = json_to_string_pretty user
```

### Error Handling

```ocaml
let safe_parse json_str =
  try
    Some (parse_json json_str)
  with
    ParseError _ -> None

let parse_with_default json_str default =
  try
    parse_json json_str
  with
    ParseError _ -> default
```

### Validation

```ocaml
let rec validate_json = function
  | Null | Bool _ | Int _ | Float _ | String _ -> true
  | Array values -> List.for_all validate_json values
  | Object pairs -> 
    List.for_all (fun (key, value) -> 
      key <> "" && validate_json value
    ) pairs
```

## Performance Notes

- **Parsing Complexity**: O(n) where n is the input string length
- **Memory Usage**: O(n) proportional to the JSON structure size
- **String Operations**: Efficient using OCaml's immutable strings
- **Pattern Matching**: Compile-time optimized exhaustive matching

## Thread Safety

All functions in this library are **thread-safe** as they:
- Use immutable data structures
- Perform no global state mutations
- Have no side effects (except for exceptions)

## XML Conversion Functions

The library also provides comprehensive JSON to XML conversion capabilities.

#### `json_to_xml`

```ocaml
val json_to_xml : ?config:Xml.xml_config -> json_value -> string
```

**Description:** Converts a `json_value` to XML with type attributes.

**Parameters:**
- `?config:Xml.xml_config` - Optional XML configuration (default: `Xml.default_config`)
- `json_value` - The JSON value to convert

**Returns:** XML string with type information

**Example:**
```ocaml
let json = Object [("name", String "Alice"); ("age", Int 30)]
let xml = json_to_xml json
(*
Returns:
<?xml version="1.0" encoding="UTF-8"?>
<root type="object">
  <name type="string">Alice</name>
  <age type="integer">30</age>
</root>
*)
```

#### `json_to_simple_xml`

```ocaml
val json_to_simple_xml : ?config:Xml.xml_config -> json_value -> string
```

**Description:** Converts a `json_value` to clean XML without type attributes.

**Example:**
```ocaml
let xml = json_to_simple_xml json
(*
Returns:
<?xml version="1.0" encoding="UTF-8"?>
<root>
  <name>Alice</name>
  <age>30</age>
</root>
*)
```

#### `json_to_attributes_xml`

```ocaml
val json_to_attributes_xml : ?config:Xml.xml_config -> json_value -> string
```

**Description:** Converts simple JSON values to XML attributes when possible.

#### `json_to_xml_with_style`

```ocaml
val json_to_xml_with_style : ?config:Xml.xml_config -> Xml.conversion_style -> json_value -> string

type conversion_style = 
  | Typed      (* Include type attributes *)
  | Simple     (* Clean XML without type info *)
  | Attributes (* Use XML attributes for simple values *)
```

**Description:** Converts JSON to XML using the specified style.

### XML Configuration

#### `Xml.xml_config`

```ocaml
type xml_config = {
  root_element: string;        (* Root element name (default: "root") *)
  array_element: string;       (* Array container name (default: "array") *)
  array_item: string;          (* Array item name (default: "item") *)
  indent_size: int;            (* Indentation spaces (default: 2) *)
  include_declaration: bool;   (* Include <?xml?> declaration (default: true) *)
  encoding: string;            (* XML encoding (default: "UTF-8") *)
}
```

#### `Xml.create_config`

```ocaml
val create_config :
  ?root_element:string ->
  ?array_element:string ->
  ?array_item:string ->
  ?indent_size:int ->
  ?include_declaration:bool ->
  ?encoding:string ->
  unit -> xml_config
```

**Example:**
```ocaml
let custom_config = Xml.create_config 
  ~root_element:"data"
  ~array_item:"element"
  ~include_declaration:false
  ()

let xml = json_to_simple_xml ~config:custom_config json
```

## Module: `Jsonparser.Json.Xml`

Low-level XML conversion module with additional utilities.

### XML Character Escaping

The XML conversion properly handles:
- `<` → `&lt;`
- `>` → `&gt;`
- `&` → `&amp;`
- `"` → `&quot;`
- `'` → `&#39;`

### XML Name Sanitization

Invalid XML element names are automatically sanitized:
- Non-letter starting characters → prefixed with valid character
- Invalid characters → replaced with `_`
- Empty names → replaced with `"element"`

## Version Compatibility

- **OCaml**: 4.08 or later
- **Dune**: 3.0 or later
- **Menhir**: 3.0 or later

---

[← Back to Documentation](../)