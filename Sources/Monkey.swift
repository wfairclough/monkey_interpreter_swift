// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser

@main
struct MonkeyCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "monkey",
        abstract: "Simple interpreter for the Monkey programming language written in Swift",
        version: "1.0.0",
        subcommands: [LexerCommand.self, ParserCommand.self, ReplCommand.self],
        defaultSubcommand: ReplCommand.self
    )

    mutating func run() throws {
        print("Hello, monkey!")
    }
}

struct LexerCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "lexer",
        abstract: "Lexer for the Monkey programming language"
    )

    @Option(name: .shortAndLong, help: "The input string to lex")
    var input: String

    mutating func run() throws {
        let lexer = Lexer.parse(input: input)
        for token in lexer {
            print("Token: \(token)")
        }
    }
}

struct ParserCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "parser",
        abstract: "Parser for the Monkey programming language"
    )

    @Option(name: .shortAndLong, help: "The input string to parse")
    var input: String

    mutating func run() throws {
        let lexer = Lexer.parse(input: input)
        var parser = Parser(lexer: lexer)
        let program = try! parser.parse()
        print("Parsed program:")
        print(program)
        switch program {
            case .statements(let statements):
                statements.forEach { print($0) }
        }
    }
}

struct ReplCommand: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "repl",
        abstract: "Read-Eval-Print Loop for the Monkey programming language"
    )

    mutating func run() throws {
        let repl = Repl()
        repl.run()
    }
}
