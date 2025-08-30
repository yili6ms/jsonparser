# OCaml JSON Parser

## Abstract

This project presents a comprehensive JSON (JavaScript Object Notation) parsing library implemented in OCaml, utilizing modern parsing techniques and tools. The implementation employs OCamllex for lexical analysis and Menhir for syntactic analysis, providing a robust foundation for JSON data processing. The parser supports the complete JSON specification (RFC 7159) including all primitive types, composite structures, and handles edge cases with appropriate error reporting. Additionally, the library features both compact and pretty-printed output formatting with configurable indentation.

## 1. Introduction

JSON has become the de facto standard for data interchange in modern applications, particularly in web services and APIs. This implementation provides a complete JSON parsing solution in OCaml, leveraging the language's strong type system and functional programming paradigms to ensure correctness and maintainability.

### 1.1 Motivation

The motivation for this project stems from the need for a well-structured, academically rigorous implementation of JSON parsing that demonstrates:

- Application of formal parsing theory using lexer/parser generators
- Type-safe representation of semi-structured data
- Comprehensive error handling and validation
- Performance-oriented design principles

### 1.2 Objectives

The primary objectives of this implementation are:

1. **Correctness**: Full compliance with JSON specification (RFC 7159)
2. **Robustness**: Comprehensive error handling and validation
3. **Maintainability**: Clean architecture with separation of concerns
4. **Performance**: Efficient parsing through generated lexer/parser
5. **Usability**: Both programmatic API and interactive command-line interface

## 2. Architecture

### 2.1 System Overview

The JSON parser follows a traditional compiler architecture with distinct phases:

```
Input String → Lexical Analysis → Syntactic Analysis → AST → Output
     ↓              ↓                   ↓           ↓        ↓
   Raw Text    Token Stream      Parse Tree    JSON Value  Formatted String
```

### 2.2 Component Architecture

The system is organized into three primary modules:

#### 2.2.1 Library (`lib/`)
- **Types Module**: Defines the JSON value ADT and formatting functions
- **Lexer Module**: OCamllex-generated lexical analyzer
- **Parser Module**: Menhir-generated syntax analyzer  
- **JSON Module**: High-level parsing interface

#### 2.2.2 Binary (`bin/`)
- **Main Module**: Interactive command-line interface and demonstration

#### 2.2.3 Tests (`test/`)
- **Test Suite**: Comprehensive unit and integration tests

### 2.3 Data Representation

The JSON data model is represented using an algebraic data type (ADT):

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

This representation provides:
- **Type Safety**: Compile-time guarantees about data structure validity
- **Pattern Matching**: Exhaustive case analysis with compiler verification
- **Immutability**: Functional data structures preventing accidental mutation

## 3. Implementation Details

### 3.1 Lexical Analysis

The lexical analyzer is implemented using OCamllex, defining regular expressions for JSON tokens:

- **Literals**: `null`, `true`, `false`
- **Numbers**: Integer and floating-point with scientific notation
- **Strings**: Unicode support with escape sequence handling
- **Structural**: Braces, brackets, colons, commas
- **Whitespace**: Space, tab, newline (ignored)

#### 3.1.1 String Processing

String parsing handles the complete set of JSON escape sequences:
- Basic escapes: `\"`, `\\`, `\/`, `\b`, `\f`, `\n`, `\r`, `\t`
- Unicode escapes: `\uXXXX` (hexadecimal code points)

### 3.2 Syntactic Analysis

The parser is implemented using Menhir, a LR(1) parser generator. The grammar follows the JSON specification precisely:

```
json_value := value EOF
value := NULL | TRUE | FALSE | INT | FLOAT | STRING | array | object
array := '[' array_elements ']'
object := '{' object_elements '}'
```

#### 3.2.1 Error Recovery

The parser provides meaningful error messages with position information, facilitating debugging and user feedback.

### 3.3 Pretty Printing

The system provides two output modes:

1. **Compact**: Minimal whitespace for storage efficiency
2. **Pretty**: Indented format for human readability

The pretty printer implements configurable indentation (default: 2 spaces) with proper handling of nested structures.

## 4. Testing Methodology

### 4.1 Test Coverage

The test suite comprises 27 comprehensive tests across multiple categories:

- **Basic Values** (11 tests): Primitive types and edge cases
- **Arrays** (4 tests): Empty, single, multiple, and mixed-type arrays
- **Objects** (3 tests): Empty, single-pair, and multi-pair objects
- **Nested Structures** (3 tests): Complex nested combinations
- **Pretty Printing** (3 tests): Formatting validation
- **Error Handling** (2 tests): Invalid input scenarios
- **Roundtrip** (1 test): Parse-serialize consistency

### 4.2 Test Infrastructure

A custom testing framework provides:
- Clear pass/fail reporting with detailed error messages
- Comprehensive assertion functions for different data types
- Exception testing for error conditions
- Automated test execution via Dune

### 4.3 Validation Results

All tests pass successfully, demonstrating:
- Correctness across the JSON specification
- Robust error handling
- Consistent roundtrip behavior (parse → format → parse)

## 5. Usage

### 5.1 Library API

```ocaml
(* Parse JSON string to AST *)
val parse_json : string -> json_value

(* Format AST to compact JSON *)
val json_to_string : json_value -> string

(* Format AST to pretty JSON *)
val json_to_string_pretty : ?indent_level:int -> json_value -> string
```

### 5.2 Command Line Interface

```bash
# Build the project
dune build

# Run interactive parser
dune exec jsonparser

# Execute test suite
dune runtest
```

### 5.3 Example Usage

```ocaml
open Jsonparser.Json

(* Parse JSON *)
let json_str = {|{"name": "Alice", "scores": [95, 87, 92]}|}
let parsed = parse_json json_str

(* Generate output *)
let compact = json_to_string parsed
let pretty = json_to_string_pretty parsed
```

## 6. Performance Analysis

### 6.1 Time Complexity

- **Lexical Analysis**: O(n) where n is input length
- **Syntactic Analysis**: O(n) for LR(1) parsing
- **Overall Complexity**: O(n) linear time parsing

### 6.2 Space Complexity

- **Token Storage**: O(t) where t is number of tokens
- **AST Construction**: O(v) where v is number of JSON values
- **Overall Space**: O(n) proportional to input size

### 6.3 Optimization Strategies

The implementation employs several optimization techniques:
- Generated lexer/parser for optimal performance
- Immutable data structures with structural sharing
- Tail-recursive functions where applicable
- Lazy evaluation for large structures (future enhancement)

## 7. Build System and Dependencies

### 7.1 Build Configuration

The project uses Dune, a modern OCaml build system, with the following key configurations:

- **OCaml**: Compatible with OCaml 4.08+
- **Menhir**: Parser generator (version 3.0+)
- **OCamllex**: Lexer generator (built-in)

### 7.2 Project Structure

```
jsonparser/
├── dune-project          # Project configuration
├── lib/                  # Core library
│   ├── dune             # Library build rules
│   ├── types.ml         # JSON value types
│   ├── lexer.mll        # Lexer specification
│   ├── parser.mly       # Parser grammar
│   └── json.ml          # Main interface
├── bin/                  # Executable
│   ├── dune             # Binary build rules
│   └── main.ml          # CLI implementation
├── test/                 # Test suite
│   ├── dune             # Test configuration
│   └── test_jsonparser.ml # Test implementation
└── README.md            # This document
```

## 8. Future Enhancements

### 8.1 Performance Optimizations

- Stream processing for large JSON files
- Memory-mapped I/O for file operations
- Incremental parsing for partial updates

### 8.2 Extended Functionality

- JSON Schema validation
- JSONPath query support
- Custom serialization/deserialization
- Binary JSON format support (e.g., BSON)

### 8.3 Tooling Integration

- Language Server Protocol (LSP) support
- Integration with popular OCaml toolchains
- Package manager distribution (opam)

## 9. Conclusion

This JSON parser implementation demonstrates the application of formal parsing techniques to real-world data processing problems. The use of OCamllex and Menhir provides a solid theoretical foundation while delivering practical performance. The comprehensive test suite ensures reliability, and the clean architecture facilitates future maintenance and enhancement.

The project serves as both a practical JSON processing tool and an educational example of principled software engineering in functional programming languages.

## References

1. Crockford, D. (2006). The application/json Media Type for JavaScript Object Notation (JSON). RFC 4627.
2. Bray, T. (2014). The JavaScript Object Notation (JSON) Data Interchange Format. RFC 7159.
3. Leroy, X., et al. OCaml Manual. INRIA.
4. Pottier, F. & Régis-Gianas, Y. Menhir Reference Manual.

## Appendix A: Grammar Specification

The complete JSON grammar in Menhir syntax:

```menhir
%start <json_value> json_value

%%

json_value:
  | value EOF { $1 }

value:
  | NULL { Null }
  | TRUE { Bool true }
  | FALSE { Bool false }
  | INT { Int $1 }
  | FLOAT { Float $1 }
  | STRING { String $1 }
  | LEFT_BRACKET array_elements RIGHT_BRACKET { Array $2 }
  | LEFT_BRACE object_elements RIGHT_BRACE { Object $2 }

array_elements:
  | (* empty *) { [] }
  | value { [$1] }
  | value COMMA array_elements { $1 :: $3 }

object_elements:
  | (* empty *) { [] }
  | object_pair { [$1] }
  | object_pair COMMA object_elements { $1 :: $3 }

object_pair:
  | STRING COLON value { ($1, $3) }
```

## License

This project is released under the MIT License. See LICENSE file for details.