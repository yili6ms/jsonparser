---
layout: default
title: Guides
---

# Guides

In-depth guides covering advanced topics and best practices for the OCaml JSON Parser.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Performance Optimization](#performance-optimization)
3. [Error Handling Best Practices](#error-handling-best-practices)
4. [Working with Large JSON Files](#working-with-large-json-files)
5. [Integration Patterns](#integration-patterns)
6. [Testing Strategies](#testing-strategies)
7. [Contributing Guide](#contributing-guide)

## Getting Started

### Installation and Setup

The OCaml JSON Parser requires OCaml 4.08+ and uses Dune as its build system.

```bash
# Prerequisites
opam install dune menhir

# Clone and build
git clone https://github.com/username/jsonparser.git
cd jsonparser
dune build

# Verify installation
dune runtest
```

### Project Integration

#### Using as a Library

Add to your `dune-project`:

```dune
(package
 (name your-project)
 (depends ocaml dune jsonparser))
```

In your code:

```ocaml
open Jsonparser.Json

let process_config_file filename =
  let content = In_channel.read_all filename in
  let config = parse_json content in
  (* Process configuration... *)
```

#### Building from Source

For development or customization:

```bash
git clone https://github.com/username/jsonparser.git
cd jsonparser

# Development build with debug symbols
dune build --profile dev

# Production build with optimizations  
dune build --profile release
```

## Performance Optimization

### Memory Management

The parser uses immutable data structures, which provides safety but requires understanding for optimal performance:

```ocaml
(* Efficient: Process in chunks *)
let process_large_array json =
  match json with
  | Array items ->
    List.fold_left (fun acc item ->
      (* Process each item immediately, don't accumulate large structures *)
      process_item item;
      acc + 1
    ) 0 items
  | _ -> 0

(* Less efficient: Building large intermediate structures *)
let inefficient_processing json =
  match json with
  | Array items ->
    let processed = List.map heavy_processing items in
    List.fold_left (+) 0 processed  (* Large intermediate list *)
```

### Streaming for Large Files

For very large JSON files, consider streaming approaches:

```ocaml
let process_large_file filename =
  let ic = open_in filename in
  try
    (* Read in chunks instead of loading entire file *)
    let buffer_size = 8192 in
    let buffer = Bytes.create buffer_size in
    let rec read_chunks acc =
      let bytes_read = input ic buffer 0 buffer_size in
      if bytes_read = 0 then acc
      else (
        let chunk = Bytes.sub_string buffer 0 bytes_read in
        read_chunks (acc ^ chunk)
      )
    in
    let content = read_chunks "" in
    close_in ic;
    parse_json content
  with
  | exn -> close_in ic; raise exn
```

### Parsing Performance Tips

```ocaml
(* Prefer pattern matching over field lookups *)
let efficient_object_processing = function
  | Object [("type", String "user"); ("data", user_data)] ->
    process_user user_data
  | Object [("type", String "product"); ("data", product_data)] ->
    process_product product_data
  | _ -> ()

(* Less efficient: Multiple field lookups *)
let less_efficient json =
  match json with
  | Object pairs ->
    let get_field name = List.assoc name pairs in
    let type_field = get_field "type" in
    let data_field = get_field "data" in
    (* Multiple list traversals *)
  | _ -> ()
```

## Error Handling Best Practices

### Comprehensive Error Handling

```ocaml
type parse_result = 
  | Success of json_value
  | ParseFailure of string
  | IOError of string

let robust_json_loader filename =
  try
    let ic = open_in filename in
    let content = In_channel.read_all filename in
    close_in ic;
    try
      Success (parse_json content)
    with
    | ParseError msg -> ParseFailure ("JSON parse error: " ^ msg)
  with
  | Sys_error msg -> IOError ("File error: " ^ msg)
  | exn -> IOError ("Unexpected error: " ^ Printexc.to_string exn)

(* Usage with proper error handling *)
let process_config filename =
  match robust_json_loader filename with
  | Success json -> process_json json
  | ParseFailure msg -> 
    Printf.eprintf "Configuration parse error: %s\n" msg;
    exit 1
  | IOError msg ->
    Printf.eprintf "Configuration file error: %s\n" msg;
    exit 1
```

### Validation Patterns

```ocaml
let validate_user_json json =
  match json with
  | Object pairs ->
    let required_fields = ["name"; "email"; "age"] in
    let missing_fields = List.filter (fun field ->
      not (List.mem_assoc field pairs)
    ) required_fields in
    
    if missing_fields <> [] then
      Error ("Missing required fields: " ^ String.concat ", " missing_fields)
    else
      (* Validate field types *)
      let validate_field (name, value) =
        match name, value with
        | "name", String _ | "email", String _ -> Ok ()
        | "age", Int n when n >= 0 && n <= 150 -> Ok ()
        | field_name, _ -> Error ("Invalid " ^ field_name ^ " field")
      in
      
      let field_results = List.map validate_field pairs in
      let errors = List.fold_left (fun acc result ->
        match result with
        | Error e -> e :: acc
        | Ok () -> acc
      ) [] field_results in
      
      if errors = [] then Ok json
      else Error ("Validation errors: " ^ String.concat "; " errors)
  | _ -> Error "Expected JSON object"
```

## Working with Large JSON Files

### Memory-Efficient Processing

```ocaml
(* Process JSON arrays element by element *)
let process_json_stream json process_fn =
  match json with
  | Array items ->
    List.iter process_fn items;
    List.length items
  | _ -> 0

(* Example: Processing user records *)
let process_users_file filename =
  let json = parse_json (In_channel.read_all filename) in
  process_json_stream json (function
    | Object pairs ->
      (* Process each user immediately, don't store *)
      let name = try 
        match List.assoc "name" pairs with 
        | String s -> s 
        | _ -> "Unknown"
      with Not_found -> "Unknown" in
      Printf.printf "Processing user: %s\n" name
    | _ -> ()
  )
```

### Lazy Evaluation Patterns

```ocaml
(* Create lazy sequences for large datasets *)
let rec json_array_to_seq = function
  | Array (item :: rest) ->
    fun () -> Seq.Cons (item, json_array_to_seq (Array rest))
  | Array [] | _ ->
    fun () -> Seq.Nil

let process_large_array json =
  let seq = json_array_to_seq json in
  Seq.fold_left (fun count item ->
    process_item item;  (* Process immediately *)
    count + 1
  ) 0 seq
```

## Integration Patterns

### Web Server Integration

```ocaml
(* Example with a hypothetical web framework *)
let json_endpoint request =
  try
    let body = get_request_body request in
    let json = parse_json body in
    
    (* Process the JSON *)
    let response_json = process_request json in
    let response_body = json_to_string response_json in
    
    create_response ~status:200 ~body:response_body ()
  with
  | ParseError msg ->
    let error_json = Object [
      ("error", String "Invalid JSON");
      ("message", String msg)
    ] in
    create_response ~status:400 ~body:(json_to_string error_json) ()
```

### Database Integration

```ocaml
(* Storing JSON in database *)
let store_json_record db json =
  match json with
  | Object pairs ->
    let id = extract_string "id" pairs in
    let data = json_to_string json in
    execute_query db "INSERT INTO json_records (id, data) VALUES (?, ?)" [id; data]
  | _ -> failwith "Expected JSON object"

(* Loading JSON from database *)
let load_json_record db id =
  let results = execute_query db "SELECT data FROM json_records WHERE id = ?" [id] in
  match results with
  | [data] -> parse_json data
  | [] -> raise Not_found
  | _ -> failwith "Multiple records found"
```

### Configuration Management

```ocaml
module Config = struct
  type t = {
    server: server_config;
    database: db_config;
    logging: log_config;
  }
  
  and server_config = {
    port: int;
    host: string;
    workers: int;
  }
  
  and db_config = {
    url: string;
    pool_size: int;
    timeout: float;
  }
  
  and log_config = {
    level: string;
    file: string option;
  }
  
  let from_json json =
    match json with
    | Object pairs ->
      let get_field name = List.assoc name pairs in
      let get_object name = match get_field name with 
        | Object p -> p | _ -> [] in
      
      let server_pairs = get_object "server" in
      let db_pairs = get_object "database" in
      let log_pairs = get_object "logging" in
      
      {
        server = {
          port = (match List.assoc "port" server_pairs with Int p -> p | _ -> 8080);
          host = (match List.assoc "host" server_pairs with String h -> h | _ -> "0.0.0.0");
          workers = (match List.assoc "workers" server_pairs with Int w -> w | _ -> 4);
        };
        database = {
          url = (match List.assoc "url" db_pairs with String u -> u | _ -> "");
          pool_size = (match List.assoc "pool_size" db_pairs with Int p -> p | _ -> 10);
          timeout = (match List.assoc "timeout" db_pairs with Float t -> t | _ -> 30.0);
        };
        logging = {
          level = (match List.assoc "level" log_pairs with String l -> l | _ -> "info");
          file = (match List.assoc "file" log_pairs with String f -> Some f | _ -> None);
        };
      }
    | _ -> failwith "Expected configuration object"
  
  let load_from_file filename =
    let content = In_channel.read_all filename in
    let json = parse_json content in
    from_json json
end
```

## Testing Strategies

### Unit Testing Patterns

```ocaml
(* Property-based testing *)
let test_roundtrip json =
  let serialized = json_to_string json in
  let reparsed = parse_json serialized in
  json = reparsed

let generate_random_json () =
  (* Generate random JSON structures for property testing *)
  let rec gen_json depth =
    if depth <= 0 then
      match Random.int 4 with
      | 0 -> Null
      | 1 -> Bool (Random.bool ())
      | 2 -> Int (Random.int 1000)
      | _ -> String ("test" ^ string_of_int (Random.int 100))
    else
      match Random.int 2 with
      | 0 -> 
        let size = Random.int 5 in
        Array (List.init size (fun _ -> gen_json (depth - 1)))
      | _ ->
        let size = Random.int 5 in
        Object (List.init size (fun i -> 
          ("key" ^ string_of_int i, gen_json (depth - 1))
        ))
  in
  gen_json 3

(* Fuzz testing *)
let fuzz_test iterations =
  for i = 1 to iterations do
    let json = generate_random_json () in
    assert (test_roundtrip json)
  done
```

### Integration Testing

```ocaml
let test_file_processing () =
  let test_data = {|{
    "users": [
      {"name": "Alice", "age": 30},
      {"name": "Bob", "age": 25}
    ],
    "metadata": {
      "version": "1.0",
      "created": "2023-01-01"
    }
  }|} in
  
  (* Write test file *)
  let temp_file = Filename.temp_file "json_test" ".json" in
  let oc = open_out temp_file in
  output_string oc test_data;
  close_out oc;
  
  (* Test processing *)
  let result = Config.load_from_file temp_file in
  
  (* Cleanup *)
  Sys.remove temp_file;
  
  (* Verify results *)
  assert (List.length result.users = 2)
```

## Contributing Guide

### Code Style Guidelines

1. **Naming Conventions**:
   - Use snake_case for functions and variables
   - Use PascalCase for types and constructors
   - Use descriptive names that explain purpose

2. **Documentation**:
   - Add docstrings to all public functions
   - Include usage examples in documentation
   - Document error conditions and exceptions

3. **Error Handling**:
   - Use the `ParseError` exception for parsing failures
   - Provide meaningful error messages
   - Include position information when possible

### Testing Requirements

All contributions must include:

1. Unit tests for new functionality
2. Integration tests for complex features
3. Performance tests for optimization changes
4. Documentation updates

### Development Workflow

```bash
# Fork and clone the repository
git clone https://github.com/your-username/jsonparser.git
cd jsonparser

# Create feature branch
git checkout -b feature/your-feature-name

# Make changes and test
dune build
dune runtest

# Format code (if formatter available)
dune fmt

# Commit changes
git add .
git commit -m "Add your feature"

# Push and create pull request
git push origin feature/your-feature-name
```

### Performance Benchmarking

When making performance changes, include benchmarks:

```ocaml
let benchmark_change () =
  let test_data = generate_large_json () in
  
  let start_time = Sys.time () in
  for i = 1 to 1000 do
    let _ = parse_json test_data in ()
  done;
  let end_time = Sys.time () in
  
  Printf.printf "Time per parse: %.4f ms\n" 
    ((end_time -. start_time) *. 1000.0 /. 1000.0)
```

This comprehensive guide should help you effectively use and contribute to the OCaml JSON Parser project.

---

[← Back to Documentation](../)