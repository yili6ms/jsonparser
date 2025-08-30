---
layout: default
title: Examples
---

# Examples

Practical examples demonstrating common usage patterns and advanced techniques.

## Basic Examples

### 1. Simple Parsing and Formatting

```ocaml
open Jsonparser.Json

let basic_example () =
  (* Parse a simple JSON object *)
  let json_str = {|{"message": "Hello, World!", "count": 42}|} in
  let parsed = parse_json json_str in
  
  (* Format back to string *)
  let compact = json_to_string parsed in
  let pretty = json_to_string_pretty parsed in
  
  Printf.printf "Original: %s\n" json_str;
  Printf.printf "Compact:  %s\n" compact;
  Printf.printf "Pretty:\n%s\n" pretty
```

**Output:**
```
Original: {"message": "Hello, World!", "count": 42}
Compact:  {"message": "Hello, World!", "count": 42}
Pretty:
{
  "message": "Hello, World!",
  "count": 42
}
```

### 2. Working with Arrays

```ocaml
let array_example () =
  let json_str = {|[1, 2, 3, "hello", true, null]|} in
  let parsed = parse_json json_str in
  
  match parsed with
  | Array values ->
    List.iteri (fun i value ->
      Printf.printf "Item %d: %s (type: %s)\n" 
        i 
        (json_to_string value)
        (match value with
         | Null -> "null"
         | Bool _ -> "boolean"
         | Int _ -> "integer"
         | Float _ -> "float"
         | String _ -> "string"
         | Array _ -> "array"
         | Object _ -> "object")
    ) values
  | _ -> Printf.printf "Expected array\n"
```

### 3. Processing Objects

```ocaml
let object_example () =
  let json_str = {|{
    "name": "Alice",
    "age": 30,
    "email": "alice@example.com",
    "active": true
  }|} in
  
  let parsed = parse_json json_str in
  
  match parsed with
  | Object pairs ->
    List.iter (fun (key, value) ->
      Printf.printf "%s: %s\n" key (json_to_string value)
    ) pairs
  | _ -> Printf.printf "Expected object\n"
```

## Intermediate Examples

### 4. Configuration File Parser

```ocaml
type config = {
  server_port: int;
  database_url: string;
  debug_mode: bool;
  allowed_origins: string list;
}

let parse_config json_str =
  let json = parse_json json_str in
  match json with
  | Object pairs ->
    let get_field key default =
      try
        List.assoc key pairs
      with
        Not_found -> default
    in
    
    let port = match get_field "server_port" (Int 8080) with
      | Int p -> p
      | _ -> 8080
    in
    
    let db_url = match get_field "database_url" (String "") with
      | String url -> url
      | _ -> ""
    in
    
    let debug = match get_field "debug_mode" (Bool false) with
      | Bool d -> d
      | _ -> false
    in
    
    let origins = match get_field "allowed_origins" (Array []) with
      | Array values ->
        List.fold_right (fun v acc ->
          match v with
          | String s -> s :: acc
          | _ -> acc
        ) values []
      | _ -> []
    in
    
    { server_port = port; database_url = db_url; 
      debug_mode = debug; allowed_origins = origins }
  | _ -> 
    failwith "Configuration must be a JSON object"

(* Usage *)
let config_json = {|{
  "server_port": 3000,
  "database_url": "postgresql://localhost/myapp",
  "debug_mode": true,
  "allowed_origins": ["http://localhost:3000", "https://myapp.com"]
}|}

let config = parse_config config_json
```

### 5. Data Transformation Pipeline

```ocaml
let transform_users json_str =
  let json = parse_json json_str in
  match json with
  | Object [("users", Array users)] ->
    let transformed_users = List.map (fun user ->
      match user with
      | Object pairs ->
        let updated_pairs = List.map (fun (key, value) ->
          match key, value with
          | "name", String name -> (key, String (String.uppercase_ascii name))
          | "age", Int age when age < 18 -> ("status", String "minor")
          | "age", Int age -> ("status", String "adult")
          | _ -> (key, value)
        ) pairs in
        Object updated_pairs
      | _ -> user
    ) users in
    Object [("users", Array transformed_users)]
  | _ -> json

let users_json = {|{
  "users": [
    {"name": "alice", "age": 25},
    {"name": "bob", "age": 16}
  ]
}|}

let transformed = transform_users users_json
let result = json_to_string_pretty transformed
```

## Advanced Examples

### 6. JSON Schema Validator

```ocaml
type schema = 
  | StringSchema
  | IntSchema
  | BoolSchema
  | ArraySchema of schema
  | ObjectSchema of (string * schema) list

let rec validate_against_schema schema json =
  match schema, json with
  | StringSchema, String _ -> true
  | IntSchema, Int _ -> true
  | BoolSchema, Bool _ -> true
  | ArraySchema item_schema, Array items ->
    List.for_all (validate_against_schema item_schema) items
  | ObjectSchema field_schemas, Object pairs ->
    List.for_all (fun (field_name, field_schema) ->
      try
        let field_value = List.assoc field_name pairs in
        validate_against_schema field_schema field_value
      with
        Not_found -> false
    ) field_schemas
  | _ -> false

(* Define a user schema *)
let user_schema = ObjectSchema [
  ("name", StringSchema);
  ("age", IntSchema);
  ("active", BoolSchema);
  ("hobbies", ArraySchema StringSchema)
]

(* Validate JSON against schema *)
let validate_user json_str =
  try
    let json = parse_json json_str in
    if validate_against_schema user_schema json then
      Printf.printf "Valid user JSON\n"
    else
      Printf.printf "Invalid user JSON\n"
  with
    ParseError msg -> Printf.printf "Parse error: %s\n" msg
```

### 7. JSON Diff Tool

```ocaml
let rec json_diff original updated =
  match original, updated with
  | Null, Null | Bool true, Bool true | Bool false, Bool false -> []
  | Int a, Int b when a = b -> []
  | Float a, Float b when a = b -> []
  | String a, String b when a = b -> []
  | Array a, Array b when List.length a = List.length b ->
    List.flatten (List.mapi (fun i (va, vb) ->
      let subdiffs = json_diff va vb in
      List.map (fun diff -> "array[" ^ string_of_int i ^ "]" ^ diff) subdiffs
    ) (List.combine a b))
  | Object a, Object b ->
    let all_keys = List.sort_uniq compare 
      ((List.map fst a) @ (List.map fst b)) in
    List.fold_left (fun acc key ->
      let val_a = try Some (List.assoc key a) with Not_found -> None in
      let val_b = try Some (List.assoc key b) with Not_found -> None in
      match val_a, val_b with
      | Some va, Some vb ->
        let subdiffs = json_diff va vb in
        acc @ (List.map (fun diff -> "." ^ key ^ diff) subdiffs)
      | Some _, None -> acc @ [".removed " ^ key]
      | None, Some _ -> acc @ [".added " ^ key]
      | None, None -> acc
    ) [] all_keys
  | a, b -> ["value changed from " ^ json_to_string a ^ " to " ^ json_to_string b]

(* Usage *)
let original = parse_json {|{"name": "Alice", "age": 30}|}
let updated = parse_json {|{"name": "Alice", "age": 31, "city": "NYC"}|}
let diffs = json_diff original updated
List.iter (Printf.printf "Diff: %s\n") diffs
```

### 8. Performance Benchmarking

```ocaml
let benchmark_parsing () =
  let large_json = {|{
    "users": [|} ^
    String.concat ",\n" (List.init 1000 (fun i ->
      Printf.sprintf {|{"id": %d, "name": "user%d", "active": %s}|}
        i i (if i mod 2 = 0 then "true" else "false")
    )) ^ {|
    ],
    "total": 1000
  }|} in
  
  let start_time = Sys.time () in
  
  for i = 1 to 100 do
    let _ = parse_json large_json in ()
  done;
  
  let parse_time = Sys.time () -. start_time in
  
  let parsed = parse_json large_json in
  let start_format = Sys.time () in
  
  for i = 1 to 100 do
    let _ = json_to_string parsed in ()
  done;
  
  let format_time = Sys.time () -. start_format in
  
  Printf.printf "Parse time (100 iterations): %.4f seconds\n" parse_time;
  Printf.printf "Format time (100 iterations): %.4f seconds\n" format_time;
  Printf.printf "JSON size: %d characters\n" (String.length large_json)
```

### 9. Command Line JSON Formatter

```ocaml
let format_file filename pretty =
  try
    let ic = open_in filename in
    let content = really_input_string ic (in_channel_length ic) in
    close_in ic;
    
    let parsed = parse_json content in
    let formatted = 
      if pretty then json_to_string_pretty parsed 
      else json_to_string parsed 
    in
    print_endline formatted
  with
  | Sys_error msg -> Printf.eprintf "Error: %s\n" msg
  | ParseError msg -> Printf.eprintf "JSON Parse Error: %s\n" msg

(* Command line usage *)
let () =
  match Sys.argv with
  | [| _; filename |] -> format_file filename false
  | [| _; "--pretty"; filename |] -> format_file filename true
  | [| _; filename; "--pretty" |] -> format_file filename true
  | _ -> Printf.eprintf "Usage: %s [--pretty] <file.json>\n" Sys.argv.(0)
```

### 10. JSON to CSV Converter

```ocaml
let json_to_csv json_str =
  let json = parse_json json_str in
  match json with
  | Array records ->
    (* Extract all unique keys *)
    let all_keys = List.fold_left (fun acc record ->
      match record with
      | Object pairs -> 
        List.fold_left (fun acc (key, _) ->
          if List.mem key acc then acc else key :: acc
        ) acc pairs
      | _ -> acc
    ) [] records in
    let sorted_keys = List.sort compare all_keys in
    
    (* Print header *)
    Printf.printf "%s\n" (String.concat "," sorted_keys);
    
    (* Print rows *)
    List.iter (fun record ->
      match record with
      | Object pairs ->
        let row = List.map (fun key ->
          try
            let value = List.assoc key pairs in
            match value with
            | String s -> "\"" ^ s ^ "\""
            | Int i -> string_of_int i
            | Float f -> string_of_float f
            | Bool true -> "true"
            | Bool false -> "false"
            | Null -> ""
            | _ -> json_to_string value
          with Not_found -> ""
        ) sorted_keys in
        Printf.printf "%s\n" (String.concat "," row)
      | _ -> ()
    ) records
  | _ -> Printf.eprintf "Expected array of objects\n"

(* Usage *)
let csv_data = {|[
  {"name": "Alice", "age": 30, "city": "NYC"},
  {"name": "Bob", "age": 25, "city": "LA"},
  {"name": "Carol", "age": 35, "department": "Engineering"}
]|}

let () = json_to_csv csv_data
```

## Error Handling Examples

### Safe Parsing with Result Type

```ocaml
type ('a, 'b) result = Ok of 'a | Error of 'b

let safe_parse json_str =
  try
    Ok (parse_json json_str)
  with
    ParseError msg -> Error msg

let process_json json_str =
  match safe_parse json_str with
  | Ok json -> Printf.printf "Success: %s\n" (json_to_string json)
  | Error msg -> Printf.printf "Error: %s\n" msg
```

### Partial Parsing with Defaults

```ocaml
let extract_field json field_name default =
  match json with
  | Object pairs ->
    (try List.assoc field_name pairs 
     with Not_found -> default)
  | _ -> default

let safe_extract json_str field_name default =
  try
    let json = parse_json json_str in
    extract_field json field_name default
  with
    ParseError _ -> default
```

These examples demonstrate the versatility and power of the OCaml JSON parser for various real-world scenarios.

---

[← Back to Documentation](../)