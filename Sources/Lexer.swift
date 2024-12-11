import Foundation

enum Token: Equatable {
    case illegal(position: Int)
    case eof

    case ident(String)
    case integer(Int)
    case singleLineComment(String)

    case assign
    case bang
    case equal
    case notEqual

    case plus
    case minus
    case asterisk
    case slash

    case lt
    case lte
    case gt
    case gte

    case comma
    case semicolon

    case lparen
    case rparen
    case lbrace
    case rbrace

    case function
    case `let`
    case `if`
    case `else`
    case `return`
    case `true`
    case `false`

    public var literal: String {
        switch self {
        case .illegal(_):
            return "ILLEGAL"
        case .eof:
            return ""
        case .ident(let value):
            return value
        case .integer(let value):
            return String(value)
        case .singleLineComment(let value):
            return value
        case .assign:
            return "="
        case .equal:
            return "=="
        case .notEqual:
            return "!="
        case .bang:
            return "!"
        case .plus:
            return "+"
        case .minus:
            return "-"
        case .asterisk:
            return "*"
        case .slash:
            return "/"
        case .lt:
            return "<"
        case .lte:
            return "<="
        case .gt:
            return ">"
        case .gte:
            return ">="
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
        case .if:
            return "if"
        case .else:
            return "else"
        case .return:
            return "return"
        case .true:
            return "true"
        case .false:
            return "false"
        }
    }

}

struct Lexer: Sequence, IteratorProtocol {
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
        case ch where ch == nil:
            return nil
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
        case "=" where peekChar() == "=":
            _ = readChar(n: 2)
            return .equal
        case "=":
            _ = readChar()
            return .assign
        case "+":
            _ = readChar()
            return .plus
        case "-":
            _ = readChar()
            return .minus
        case "*":
            _ = readChar()
            return .asterisk
        case "/" where peekChar() == "/":
            return readSingleLineComment()
        case "/":
            _ = readChar()
            return .slash
        case "<" where peekChar() == "=":
            _ = readChar(n: 2)
            return .lte
        case "<":
            _ = readChar()
            return .lt
        case ">" where peekChar() == "=":
            _ = readChar(n: 2)
            return .gte
        case ">":
            _ = readChar()
            return .gt
        case "!" where peekChar() == "=":
            _ = readChar(n: 2)
            return .notEqual
        case "!":
            _ = readChar()
            return .bang
        case ch where ch?.isLetter == true:
            switch ch {
            case "l" where peek(keyword: .let):
                _ = readChar(n: Token.let.literal.count)
                return Token.let
            case "i" where peek(keyword: .if):
                _ = readChar(n: Token.if.literal.count)
                return Token.if
            case "e" where peek(keyword: .else):
                _ = readChar(n: Token.else.literal.count)
                return Token.else
            case "r" where peek(keyword: .return):
                _ = readChar(n: Token.return.literal.count)
                return Token.return
            case "t" where peek(keyword: .true):
                _ = readChar(n: Token.true.literal.count)
                return Token.true
            case "f" where peek(keyword: .false):
                _ = readChar(n: Token.false.literal.count)
                return Token.false
            case "f" where peek(keyword: .function):
                _ = readChar(n: Token.function.literal.count)
                return Token.function
            default:
                let token = readIdentifier()
                return token
            }
        case ch where ch?.isNumber == true:
            let token = readInteger()
            return token
        default:
            return .illegal(position: position)
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

    private mutating func readChar(while whileFn: (Character) -> Bool) -> Character? {
        while let ch = ch, whileFn(ch) {
            _ = readChar()
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
        guard let actual = input[safe: readPosition..<readPosition + expecting.count] else {
            return false
        }
        return actual == expecting
    }

    private mutating func peek(keyword: Token) -> Bool {
        let expecting = keyword.literal
        guard let actual = input[safe: (readPosition - 1)..<readPosition + (expecting.count - 1)] else {
            print("No actual")
            return false
        }
        guard let nextChar = input[safe: readPosition + (expecting.count - 1)] else {
            print("No next char")
            return false
        }
        return
            (nextChar.isWhitespace || nextChar == Token.semicolon.literal.first
            || nextChar == Token.rparen.literal.first || nextChar == Token.lparen.literal.first)
            && actual == expecting
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

    private mutating func readSingleLineComment() -> Token {
        var chars = [Character]()
        _ = readChar(while: { $0 == "/" })
        _ = readChar(while: { $0.isWhitespace })
        while let ch = ch, ch != "\n" {
            chars.append(ch)
            _ = readChar()
        }
        return Token.singleLineComment(String(chars))
    }
}
