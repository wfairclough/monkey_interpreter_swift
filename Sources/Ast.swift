
enum Statement {
    case `let`(name: Identifier, value: Expression)
    case identifier(Identifier)
    case expression(Expression)
}

struct Program {
    let statements: [Statement]
}

struct Identifier {
    let value: String
}

struct Expression {
    let value: Token
}

