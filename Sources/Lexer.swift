import Foundation

enum Token: Equatable {
    case illegal
    case eof

    case ident(String)
    case integer(Int)

    case assign
    case plus
    case equal
    case notEqual

    case comma
    case semicolon

    case lparen
    case rparen
    case lbrace
    case rbrace

    case function
    case `let`

    public var literal: String {
        switch self {
        case .illegal:
            return "ILLEGAL"
        case .eof:
            return ""
        case .ident(let value):
            return value
        case .integer(let value):
            return String(value)
        case .assign:
            return "="
        case .equal:
            return "=="
        case .notEqual:
            return "!="
        case .plus:
            return "+"
        case .comma:
            return ","
        case .semicolon:
            return ";"
        case .lparen:
            return "("
        case .rparen:
            return ")"
        case .lbrace:
            return "{"
        case .rbrace:
            return "}"
        case .function:
            return "fn"
        case .let:
            return "let"
        }
    }
}

struct Lexer : Sequence, IteratorProtocol {
    let input: String
    private var position: Int = 0
    private var readPosition: Int = 0
    private var ch: Character? = nil

    static func parse(input: String) -> Self {
        return Lexer(input: input)
    }

    private init(input: String) {
        self.input = input
        _ = readChar()
    }

    mutating func next() -> Token? {
        switch ch {
        case ch where ch?.isWhitespace == true:
            _ = readChar()
            return next()
        case ",":
            _ = readChar()
            return .comma
        case ";":
            _ = readChar()
            return .semicolon
        case "(":
            _ = readChar()
            return .lparen
        case ")":
            _ = readChar()
            return .rparen
        case "{":
            _ = readChar()
            return .lbrace
        case "}":
            _ = readChar()
            return .rbrace
        case ch where ch == nil:
            return nil
        case "f" where peekChar() == "n":
            _ = readChar(n: 2)
            return Token.function
        case "=" where peekChar() == "=":
            _ = readChar(n: 2)
            return .equal
        case "=":
            _ = readChar()
            return .assign
        case "+":
            _ = readChar()
            return .plus
        case "!" where peekChar() == "=":
            _ = readChar(n: 2)
            return .notEqual
        case "l" where peek(expecting: "et"):
            _ = readChar(n: 3)
            return Token.let
        case ch where ch?.isLetter == true:
            let token = readIdentifier()
            return token
        case ch where ch?.isNumber == true:
            let token = readInteger()
            return token
        default:
            return .illegal
        }
    }

    private mutating func readChar(n: Int = 1) -> Character? {
        if readPosition >= input.count {
            ch = nil
        } else {
            ch = input[safe: readPosition]
        }
        position = readPosition
        readPosition += 1
        if n > 1 {
            for _ in 1..<n {
                _ = readChar()
            }
        }
        return ch
    }

    private func peekChar() -> Character? {
        if readPosition >= input.count {
            return nil
        }
        return input[safe: readPosition]
    }

    private mutating func peek(expecting: String) -> Bool {
        let start = readPosition
        defer {
            self.readPosition = start
        }
        for ch in expecting {
            if readChar() != ch {
                return false
            }
        }
        return true
    }

    private mutating func readIdentifier() -> Token {
        var chars = [Character]()
        while let ch = ch, ch.isLetter {
            chars.append(ch)
            _ = readChar()
        }
        return Token.ident(String(chars))
    }

    private mutating func readInteger() -> Token {
        var chars = [Character]()
        while let ch = ch, ch.isNumber {
            chars.append(ch)
            _ = readChar()
        }
        return Token.integer(Int(String(chars))!)
    }
}

extension String {
    // func subscript(safe index: Int) -> Element? {
    subscript(safe index: Int) -> Character? {
        if index < 0 || index >= count {
            return nil
        }
        let value = self[String.Index(utf16Offset: index, in: self)]
        return value
    }
}
