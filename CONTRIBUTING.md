# Contributing to OCaml JSON Parser

Thank you for your interest in contributing to the OCaml JSON Parser! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Style Guidelines](#style-guidelines)
- [Performance Considerations](#performance-considerations)

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

### Prerequisites

- OCaml 4.14 or later
- Dune 3.0 or later
- Menhir 3.0 or later
- Git

### Development Setup

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub, then:
   git clone https://github.com/YOUR-USERNAME/jsonparser.git
   cd jsonparser
   ```

2. **Set Up OCaml Environment**
   ```bash
   # Install opam if you haven't already
   opam switch create 4.14.0
   eval $(opam env)
   
   # Install dependencies
   opam install . --deps-only --with-test
   opam install menhir
   ```

3. **Verify Setup**
   ```bash
   dune build
   dune runtest
   ```

## Making Changes

### Branching Strategy

- Create feature branches from `main`
- Use descriptive branch names: `feature/add-validation`, `fix/parsing-error`, etc.
- Keep branches focused on single features or fixes

```bash
git checkout -b feature/your-feature-name
```

### Development Workflow

1. **Make your changes**
   - Follow existing code patterns
   - Add appropriate documentation
   - Include tests for new functionality

2. **Test your changes**
   ```bash
   dune build
   dune runtest
   ```

3. **Update documentation if needed**
   - Update README.md if adding new features
   - Add examples to docs/examples/
   - Update API documentation in docs/api/

## Testing

### Running Tests

```bash
# Run all tests
dune runtest

# Run tests with verbose output
dune exec test/test_jsonparser.exe

# Build and test in one command
dune build && dune runtest
```

### Writing Tests

All new functionality must include tests. Tests are located in `test/test_jsonparser.ml`.

Example test structure:
```ocaml
let test_new_feature () =
  test "description of test" (fun () ->
    let input = {|{"test": "data"}|} in
    let expected = Object [("test", String "data")] in
    assert_equal expected (parse_json input) "test description")
```

### Test Categories

Tests should cover:
- **Basic functionality**: Core parsing and formatting
- **Edge cases**: Empty inputs, malformed JSON, large files
- **Error handling**: Invalid syntax, unexpected characters
- **Performance**: Large JSON structures, deeply nested data
- **Roundtrip consistency**: parse → format → parse

## Submitting Changes

### Pull Request Process

1. **Ensure all tests pass**
   ```bash
   dune build && dune runtest
   ```

2. **Update the documentation**
   - Add/update examples if needed
   - Update API documentation
   - Update README if adding major features

3. **Commit your changes**
   ```bash
   git add .
   git commit -m "Brief description of changes
   
   More detailed explanation of what was changed and why.
   References #issue-number if applicable."
   ```

4. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

5. **Create Pull Request**
   - Use the GitHub interface to create a PR
   - Fill out the PR template completely
   - Link any related issues

### PR Requirements

- [ ] All tests pass
- [ ] New tests added for new functionality
- [ ] Documentation updated
- [ ] Code follows project style guidelines
- [ ] Commit messages are clear and descriptive
- [ ] No breaking changes (or clearly documented)

## Style Guidelines

### OCaml Code Style

**Naming Conventions:**
```ocaml
(* Variables and functions: snake_case *)
let parse_json_string = ...
let user_data = ...

(* Types and constructors: PascalCase *)
type JsonValue = Null | String of string
type ParseResult = Success of json_value | Error of string

(* Constants: SCREAMING_SNAKE_CASE *)
let MAX_DEPTH = 1000
```

**Code Organization:**
```ocaml
(* Group related functionality *)
module Parser = struct
  type t = ...
  
  let create () = ...
  let parse t input = ...
end

(* Use meaningful comments for complex logic *)
(* Parse Unicode escape sequences (\uXXXX) *)
let parse_unicode_escape input pos = ...
```

**Error Handling:**
```ocaml
(* Use the ParseError exception for parsing failures *)
let parse_value tokens =
  match tokens with
  | [] -> raise (ParseError "Unexpected end of input")
  | invalid_token :: _ -> 
    raise (ParseError ("Unexpected token: " ^ token_to_string invalid_token))
```

### Documentation Style

**Function Documentation:**
```ocaml
(** Parse a JSON string into a json_value AST.
    
    @param input The JSON string to parse
    @return A json_value representing the parsed JSON
    @raise ParseError when the input is not valid JSON
    
    Example:
    {[
      let json = parse_json {|{"name": "Alice"}|}
      (* Returns: Object [("name", String "Alice")] *)
    ]}
*)
val parse_json : string -> json_value
```

**Markdown Documentation:**
- Use clear, concise language
- Include code examples for all features
- Use consistent formatting
- Link to related sections

## Performance Considerations

When making changes that might affect performance:

1. **Measure before optimizing**
   ```ocaml
   let benchmark_function () =
     let start = Sys.time () in
     (* Your function call *)
     let end_time = Sys.time () in
     Printf.printf "Time: %.4f seconds\n" (end_time -. start)
   ```

2. **Consider algorithmic complexity**
   - Prefer O(n) over O(n²) algorithms
   - Use tail recursion for large inputs
   - Avoid repeated string concatenation

3. **Memory efficiency**
   - Use structural sharing where possible
   - Avoid creating unnecessary intermediate structures
   - Consider lazy evaluation for large datasets

### Performance Testing

Include performance tests for significant changes:
```ocaml
let test_large_file_performance () =
  let large_json = generate_large_json 10000 in
  let start_time = Sys.time () in
  let _ = parse_json large_json in
  let parse_time = Sys.time () -. start_time in
  (* Assert performance bounds *)
  assert (parse_time < 1.0)  (* Should parse in under 1 second *)
```

## Documentation Updates

### API Documentation

Update `docs/api/index.md` when:
- Adding new functions or types
- Changing function signatures
- Adding new modules

### Examples

Add examples to `docs/examples/index.md` when:
- Adding significant new features
- Implementing common use cases
- Demonstrating best practices

### Guides

Update `docs/guides/index.md` for:
- New integration patterns
- Performance optimizations
- Advanced usage techniques

## Getting Help

If you need help:

1. **Check existing documentation**
   - README.md
   - docs/ directory
   - GitHub Issues

2. **Search existing issues**
   - Look for similar problems
   - Check closed issues for solutions

3. **Create a new issue**
   - Use issue templates
   - Provide minimal reproduction case
   - Include environment details

4. **Join discussions**
   - Participate in existing discussions
   - Ask questions in a respectful manner

## Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- Release notes
- Project documentation

Thank you for contributing to the OCaml JSON Parser! 🎉