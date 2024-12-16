
enum Statement {
    case `let`(name: Identifier, value: Expression)
    case identifier(Identifier)
    case expression(Expression)
}

enum BlockStatement {
    case statements([Statement])
}

typealias Program = BlockStatement

enum Identifier {
    case name(String)
}

enum InfixOperator {
    case add
    case subtract
    case multiply
    case divide
    case lessThan
    case lessThanOrEqual
    case greaterThan
    case greaterThanOrEqual
    case equal
    case notEqual
}

enum PrefixOperator {
    case bang
    case minus
}

indirect enum Expression {
    case numericLiteral(Int)
    case booleanLiteral(Bool)
    case group(Expression)
    case prefix(operator: PrefixOperator, right: Expression)
    case infix(left: Expression, operator: InfixOperator, right: Expression)
    case identifier(Identifier)
    case function(parameters: [Identifier], body: BlockStatement)
}

