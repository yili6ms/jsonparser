let main () =
  (* Sample JSON to demonstrate the parser *)
  let sample_json = {|{
  "name": "John Doe",
  "age": 30,
  "active": true,
  "address": {
    "street": "123 Main St",
    "city": "New York",
    "zipcode": "10001"
  },
  "hobbies": ["reading", "swimming", "coding"],
  "salary": 75000.50,
  "spouse": null
}|} in
  
  print_endline "JSON Parser Demo";
  print_endline "================";
  print_endline "\nParsing sample JSON:";
  print_endline sample_json;
  
  (try
    let parsed = Jsonparser.Json.parse_json sample_json in
    let compact = Jsonparser.Json.json_to_string parsed in
    let pretty = Jsonparser.Json.json_to_string_pretty parsed in
    let xml = Jsonparser.Json.json_to_xml parsed in
    let simple_xml = Jsonparser.Json.json_to_simple_xml parsed in
    Printf.printf "\nCompact JSON:\n%s\n" compact;
    Printf.printf "\nPretty JSON:\n%s\n" pretty;
    Printf.printf "\nTyped XML:\n%s\n" xml;
    Printf.printf "\nSimple XML:\n%s\n" simple_xml
  with
    Jsonparser.Json.ParseError msg -> Printf.printf "\nError: %s\n" msg);
  
  print_endline ("\n" ^ String.make 50 '-');
  print_endline "Interactive mode - Enter JSON to parse (or 'quit' to exit):";
  let rec loop () =
    print_string "> ";
    flush stdout;
    let input = read_line () in
    if input = "quit" then
      print_endline "Goodbye!"
    else
      try
        let parsed = Jsonparser.Json.parse_json input in
        let pretty = Jsonparser.Json.json_to_string_pretty parsed in
        let xml = Jsonparser.Json.json_to_simple_xml parsed in
        Printf.printf "JSON:\n%s\n" pretty;
        Printf.printf "XML:\n%s\n" xml
      with
        Jsonparser.Json.ParseError msg -> Printf.printf "Error: %s\n" msg;
      loop ()
  in
  loop ()

let () = main ()
