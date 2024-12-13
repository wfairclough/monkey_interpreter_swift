enum ParserError: Error {
    case invalidToken
}

struct Parser: Sequence, IteratorProtocol {
    private var lexer: Lexer
    private var _lastPeekedToken: Token?

    init(lexer: Lexer) {
        self.lexer = lexer
    }

    mutating func next() -> (curToken: Token?, peekToken: Token?)? {
        let curToken = _lastPeekedToken ?? lexer.next()
        let peekToken = lexer.next()
        _lastPeekedToken = peekToken

        guard let peekToken = peekToken else { return nil }
        return (curToken, peekToken)
    }

    mutating func parse() throws -> Program {
        var statements: [Statement] = []

        while let (ct, pt) = next(), ct != nil {
            guard let ct = ct else { break }

            switch ct {
            case .let:
                guard let stmt = parseLetStatement() else {
                    print("Failed to parse let statement .\(ct) peek: .\(pt ?? .eof)")
                    throw ParserError.invalidToken
                }
                statements.append(stmt)
            case .return:
                break
            case .if:
                break
            case .function:
                break
            case .eof:
                print("Reached EOF")
                break
            default:
                print("Unknown token .\(ct) .\(pt ?? .eof)")
                break
            }
        }
        return .statements(statements)
    }

    private mutating func parseLetStatement() -> Statement? {
        guard let (ct, pt) = next() else { return nil }
        guard case .ident(let name) = ct else { return nil }
        print("Parsing let statement for \(name)")
        guard case .assign = pt else { return nil }
        print("Is assign")
        guard let (_, pt) = next() else { return nil }
        guard let expressionToken = pt else { return nil }
        print("Expression token: \(expressionToken)")
        guard let expression = parseExpression() else { return nil }

        return Statement.let(name: .name(name), value: expression)
    }

    private mutating func parseExpression() -> Expression? {
        guard let (ct, pt) = next() else { return nil }
        guard let ct = ct else { return nil }
        guard let pt = pt else { return nil }
        print("Parsing expression for \(ct) peek: \(pt)")

        switch (ct, pt) {
            case (.integer(let v), .lte):
                fallthrough
            case (.integer(let v), .lt):
                fallthrough
            case (.integer(let v), .gte):
                fallthrough
            case (.integer(let v), .gt):
                fallthrough
            case (.integer(let v), .equal):
                fallthrough
            case (.integer(let v), .notEqual):
                fallthrough
            case (.integer(let v), .slash):
                fallthrough
            case (.integer(let v), .asterisk):
                fallthrough
            case (.integer(let v), .minus):
                fallthrough
            case (.integer(let v), .plus):
                return parseInfixExpression(left: .integer(v))
            case (.integer(let v), .eof):
                return .integer(v)
            case (.integer(let v), .semicolon):
                return .integer(v)
            //     return .integer(value)
            // case .ident(let name):
            //     return .identifier(.name(name))
            // case .lparen:
            //     return parseGroupedExpression()
            // case .bang:
            //     return parsePrefixExpression()
            // case .minus:
            //     guard let (_, pt) = next() else { return nil }
            //     switch pt {
            //         case .integer(_):
            //             return parsePrefixExpression()
            //         case .ident(_):
            //             return parsePrefixExpression()
            //         case .lparen:
            //             return parsePrefixExpression()
            //         default:
            //             return parseInfixExpression()
            //     }
            // case .equal:
            //     fallthrough
            // case .notEqual:
            //     fallthrough
            // case .lt:
            //     fallthrough
            // case .lte:
            //     fallthrough
            // case .gt:
            //     fallthrough
            // case .gte:
            //     fallthrough
            // case .plus:
            //     fallthrough
            // case .asterisk:
            //     fallthrough
            // case .slash:
            //     return parseInfixExpression()
            // case .true:
            //     return .boolean(true)
            // case .false:
            //     return .boolean(false)
            // default:
            //     return nil
        }

        return nil
    }

    private mutating func parseGroupedExpression() -> Expression? {
        guard let expression = parseExpression() else { return nil }
        guard let (ct, pt) = next() else { return nil }
        guard let ct = ct else { return nil }
        guard let pt = pt else { return nil }
        print("Parsing grouped expression for \(ct) peek: \(pt)")

        guard case .rparen = ct else { return nil }

        return expression
    }

    private mutating func parsePrefixExpression() -> Expression? {
        guard let (ct, pt) = next() else { return nil }
        guard let ct = ct else { return nil }
        guard let pt = pt else { return nil }
        print("Parsing prefix expression for \(ct) peek: \(pt)")

        guard let right = parseExpression() else { return nil }

        switch ct {
            case .bang:
                return .prefix(operator: .bang, right: right)
            case .minus:
                return .prefix(operator: .minus, right: right)
            default:
                return nil
        }
    }

    private mutating func parseInfixExpression(left: Expression) -> Expression? {
        guard let (ct, pt) = next() else { return nil }
        guard let ct = ct else { return nil }
        guard let pt = pt else { return nil }
        print("Parsing infix expression for \(ct) peek: \(pt)")

        guard let left = parseExpression() else { return nil }
        guard let right = parseExpression() else { return nil }

        switch ct {
            case .equal:
                return .infix(left: left, operator: .equal, right: right)
            case .notEqual:
                return .infix(left: left, operator: .notEqual, right: right)
            case .lt:
                return .infix(left: left, operator: .lessThan, right: right)
            case .lte:
                return .infix(left: left, operator: .lessThanOrEqual, right: right)
            case .gt:
                return .infix(left: left, operator: .greaterThan, right: right)
            case .gte:
                return .infix(left: left, operator: .greaterThanOrEqual, right: right)
            case .plus:
                return .infix(left: left, operator: .add, right: right)
            case .minus:
                return .infix(left: left, operator: .subtract, right: right)
            case .asterisk:
                return .infix(left: left, operator: .multiply, right: right)
            case .slash:
                return .infix(left: left, operator: .divide, right: right)
            default:
                return nil
        }
    }

}

