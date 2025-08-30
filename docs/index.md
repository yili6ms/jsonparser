---
layout: default
title: OCaml JSON Parser Documentation
---

# OCaml JSON Parser

A comprehensive JSON parsing library for OCaml with modern tooling and robust error handling.

## Features

- 🚀 **High Performance**: Built with OCamllex and Menhir for optimal parsing speed
- 🔒 **Type Safe**: Leverages OCaml's type system for guaranteed correctness
- 🎨 **Pretty Printing**: Beautiful, indented JSON output with customizable formatting
- ⚡ **Complete Coverage**: Full JSON specification (RFC 7159) compliance
- 🧪 **Thoroughly Tested**: Comprehensive test suite with 27+ test cases
- 📚 **Well Documented**: Academic-quality documentation and examples

## Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/username/jsonparser.git
cd jsonparser

# Build the project
dune build

# Run tests
dune runtest

# Try the interactive parser
dune exec jsonparser
```

### Basic Usage

```ocaml
open Jsonparser.Json

(* Parse JSON string *)
let json_str = {|{"name": "Alice", "age": 30, "hobbies": ["reading", "coding"]}|}
let parsed = parse_json json_str

(* Generate compact output *)
let compact = json_to_string parsed
(* Output: {"name":"Alice","age":30,"hobbies":["reading","coding"]} *)

(* Generate pretty-printed output *)
let pretty = json_to_string_pretty parsed
(*
Output:
{
  "name": "Alice",
  "age": 30,
  "hobbies": [
    "reading",
    "coding"
  ]
}
*)
```

## Documentation Sections

### 📖 [API Reference](api/)
Complete API documentation with function signatures and examples.

### 🎯 [Examples](examples/)
Practical examples and usage patterns for common scenarios.

### 📋 [Guides](guides/)
In-depth guides covering advanced topics and best practices.

## Architecture Overview

The parser follows a clean, modular architecture:

```
Input JSON → Lexer → Parser → AST → Output
     ↓         ↓       ↓      ↓       ↓
  Raw Text  Tokens  Grammar JSON   String
```

### Core Components

- **Types**: JSON value representation using algebraic data types
- **Lexer**: OCamllex-generated lexical analyzer
- **Parser**: Menhir-generated LR(1) parser
- **JSON**: High-level parsing and formatting interface

## Performance

- **Time Complexity**: O(n) linear parsing
- **Space Complexity**: O(n) proportional to input size
- **Memory Efficient**: Immutable data structures with structural sharing

## Testing

Comprehensive test coverage across multiple categories:

- ✅ Basic JSON values (null, bool, numbers, strings)
- ✅ Arrays and objects (empty, nested, mixed)
- ✅ Complex nested structures
- ✅ Pretty printing validation
- ✅ Error handling and edge cases
- ✅ Roundtrip consistency (parse → format → parse)

## Project Status

- **Version**: 1.0.0
- **Status**: Stable
- **OCaml Compatibility**: 4.08+
- **Dependencies**: Menhir 3.0+

## Contributing

We welcome contributions! Please see our [contributing guidelines](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

*Generated with ❤️ using OCaml and modern parsing techniques*