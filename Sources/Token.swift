
enum Token: Equatable {
    case illegal(position: Int)
    case eof

    case ident(String)
    case numeric(Int)
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
        case .numeric(let value):
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
