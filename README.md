# Monkey Interpreter (Swift)

I wanted to practice writting Swift on Linux so why not build an interpreter. I am following the book [Writing An Interpreter In Go](https://interpreterbook.com/) as a guide.

## Building

This is a SPM Swift executable package. Use the standard `swift` cli tools for building.

```sh
swift build
```

It currently only supports Swift 6, as that was the latest version when I started this project.

## Testing

I am using Swift Testing for my unit tests. They can be run by using the command:

```sh
swift test
```

## Usage

Monkey:

```sh
OVERVIEW: Simple interpreter for the Monkey programming language written in Swift

USAGE: monkey <subcommand>

OPTIONS:
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  lexer                   Lexer for the Monkey programming language

  See 'monkey help <subcommand>' for detailed help.
```

Lexer:

```sh
OVERVIEW: Lexer for the Monkey programming language

USAGE: monkey lexer --input <input>

OPTIONS:
  -i, --input <input>     The input string to lex
  --version               Show the version.
  -h, --help              Show help information.

```

