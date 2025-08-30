open Jsonparser.Json

(* Simple test framework *)
let test_count = ref 0
let passed_count = ref 0

let test name test_fn =
  incr test_count;
  try
    test_fn ();
    incr passed_count;
    Printf.printf "✓ %s\n" name
  with
  | e ->
    Printf.printf "✗ %s: %s\n" name (Printexc.to_string e)

let assert_equal expected actual msg =
  if expected = actual then ()
  else failwith (Printf.sprintf "%s: expected %s, got %s" 
    msg 
    (json_to_string expected) 
    (json_to_string actual))

let assert_string_equal expected actual msg =
  if expected = actual then ()
  else failwith (Printf.sprintf "%s: expected '%s', got '%s'" msg expected actual)

let assert_raises expected_exn test_fn msg =
  try
    test_fn ();
    failwith (Printf.sprintf "%s: expected exception but none was raised" msg)
  with
  | exn when exn = expected_exn -> ()
  | exn -> failwith (Printf.sprintf "%s: expected %s but got %s" 
    msg 
    (Printexc.to_string expected_exn) 
    (Printexc.to_string exn))

(* Basic JSON value tests *)
let test_basic_values () =
  test "null parsing" (fun () ->
    assert_equal Null (parse_json "null") "null");
  
  test "bool true" (fun () ->
    assert_equal (Bool true) (parse_json "true") "true");
  
  test "bool false" (fun () ->
    assert_equal (Bool false) (parse_json "false") "false");
  
  test "positive int" (fun () ->
    assert_equal (Int 42) (parse_json "42") "positive int");
  
  test "negative int" (fun () ->
    assert_equal (Int (-17)) (parse_json "-17") "negative int");
  
  test "zero" (fun () ->
    assert_equal (Int 0) (parse_json "0") "zero");
  
  test "positive float" (fun () ->
    assert_equal (Float 3.14) (parse_json "3.14") "positive float");
  
  test "negative float" (fun () ->
    assert_equal (Float (-2.5)) (parse_json "-2.5") "negative float");
  
  test "simple string" (fun () ->
    assert_equal (String "hello") (parse_json "\"hello\"") "simple string");
  
  test "empty string" (fun () ->
    assert_equal (String "") (parse_json "\"\"") "empty string");
  
  test "escaped string" (fun () ->
    assert_equal (String "hello\nworld") (parse_json "\"hello\\nworld\"") "escaped string")

(* Array tests *)
let test_arrays () =
  test "empty array" (fun () ->
    assert_equal (Array []) (parse_json "[]") "empty array");
  
  test "single element array" (fun () ->
    assert_equal (Array [Int 42]) (parse_json "[42]") "single element array");
  
  test "multiple element array" (fun () ->
    assert_equal (Array [Int 1; Int 2; Int 3]) (parse_json "[1, 2, 3]") "multiple elements");
  
  test "mixed array" (fun () ->
    assert_equal (Array [Int 1; String "hello"; Bool true; Null]) 
      (parse_json "[1, \"hello\", true, null]") "mixed array")

(* Object tests *)
let test_objects () =
  test "empty object" (fun () ->
    assert_equal (Object []) (parse_json "{}") "empty object");
  
  test "single pair object" (fun () ->
    assert_equal (Object [("key", String "value")]) 
      (parse_json "{\"key\": \"value\"}") "single pair");
  
  test "multiple pair object" (fun () ->
    assert_equal (Object [("name", String "John"); ("age", Int 30)]) 
      (parse_json "{\"name\": \"John\", \"age\": 30}") "multiple pairs")

(* Nested structure tests *)
let test_nested () =
  test "nested array" (fun () ->
    assert_equal (Array [Array [Int 1; Int 2]; Array [Int 3; Int 4]]) 
      (parse_json "[[1, 2], [3, 4]]") "nested array");
  
  test "nested object" (fun () ->
    assert_equal (Object [("user", Object [("name", String "Alice"); ("id", Int 123)])]) 
      (parse_json "{\"user\": {\"name\": \"Alice\", \"id\": 123}}") "nested object");
  
  test "array of objects" (fun () ->
    assert_equal (Array [Object [("x", Int 1)]; Object [("y", Int 2)]]) 
      (parse_json "[{\"x\": 1}, {\"y\": 2}]") "array of objects")

(* Pretty printing tests *)
let test_pretty_printing () =
  test "simple pretty printing" (fun () ->
    let value = Object [("name", String "John"); ("age", Int 30)] in
    let expected = "{\n  \"name\": \"John\",\n  \"age\": 30\n}" in
    assert_string_equal expected (json_to_string_pretty value) "simple pretty");
  
  test "empty containers pretty" (fun () ->
    assert_string_equal "{}" (json_to_string_pretty (Object [])) "empty object";
    assert_string_equal "[]" (json_to_string_pretty (Array [])) "empty array");
  
  test "array pretty printing" (fun () ->
    let value = Array [String "a"; String "b"; String "c"] in
    let expected = "[\n  \"a\",\n  \"b\",\n  \"c\"\n]" in
    assert_string_equal expected (json_to_string_pretty value) "array pretty")

(* Error handling tests *)
let test_error_handling () =
  test "unterminated string" (fun () ->
    assert_raises (ParseError "String is not terminated") 
      (fun () -> ignore (parse_json "\"unterminated")) "unterminated string");
  
  test "invalid escape sequence" (fun () ->
    assert_raises (ParseError "Illegal string escape: \\z") 
      (fun () -> ignore (parse_json "\"\\z\"")) "invalid escape")

(* Roundtrip tests *)
let test_roundtrip () =
  test "parse and stringify roundtrip" (fun () ->
    let original_json = "{\"name\": \"test\", \"values\": [1, 2, {\"nested\": true}]}" in
    let parsed = parse_json original_json in
    let compact_output = json_to_string parsed in
    let pretty_output = json_to_string_pretty parsed in
    let reparsed_compact = parse_json compact_output in
    let reparsed_pretty = parse_json pretty_output in
    assert_equal parsed reparsed_compact "roundtrip compact";
    assert_equal parsed reparsed_pretty "roundtrip pretty")

(* Main test runner *)
let () =
  Printf.printf "Running JSON Parser Tests\n";
  Printf.printf "========================\n\n";
  
  Printf.printf "Basic JSON Values:\n";
  test_basic_values ();
  
  Printf.printf "\nArrays:\n";
  test_arrays ();
  
  Printf.printf "\nObjects:\n";
  test_objects ();
  
  Printf.printf "\nNested Structures:\n";
  test_nested ();
  
  Printf.printf "\nPretty Printing:\n";
  test_pretty_printing ();
  
  Printf.printf "\nError Handling:\n";
  test_error_handling ();
  
  Printf.printf "\nRoundtrip:\n";
  test_roundtrip ();
  
  Printf.printf "\n========================\n";
  Printf.printf "Results: %d/%d tests passed\n" !passed_count !test_count;
  
  if !passed_count = !test_count then (
    Printf.printf "All tests passed! ✓\n";
    exit 0
  ) else (
    Printf.printf "Some tests failed! ✗\n";
    exit 1
  )