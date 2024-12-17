
enum Statement: Equatable {
    case `let`(name: Identifier, value: Expression)
    case identifier(Identifier)
    case expression(Expression)
}

enum BlockStatement: Equatable {
    case statements([Statement])
}

typealias Program = BlockStatement

enum Identifier: Equatable {
    case name(String)
}

enum FuncParams: Equatable {
    case named([Identifier])
}

enum InfixOperator: Equatable {
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

enum PrefixOperator: Equatable {
    case bang
    case minus
}

indirect enum Expression: Equatable {
    case numericLiteral(Int)
    case booleanLiteral(Bool)
    case group(Expression)
    case prefix(operator: PrefixOperator, right: Expression)
    case infix(left: Expression, operator: InfixOperator, right: Expression)
    case identifier(Identifier)
    case function(parameters: FuncParams, body: BlockStatement)
}

