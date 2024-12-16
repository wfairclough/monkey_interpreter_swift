enum ParserError: Error {
    case invalidToken
}

struct Parser: Sequence, IteratorProtocol {
    private var lexer: Lexer
    private var currentToken: Token?
    private var peekToken: Token?

    init(lexer: Lexer) {
        self.lexer = lexer
        _ = next()
    }

    mutating func next() -> Token? {
        currentToken = peekToken
        peekToken = lexer.next()

        guard let peekToken = peekToken else { return nil }
        return peekToken
    }

    mutating func parse() throws -> Program {
        var statements: [Statement] = []

        while let pt = next() {
            guard let ct = currentToken else { break }

            switch ct {
            case .let:
                guard let stmt = parseLetStatement() else {
                    print("Failed to parse let statement .\(currentToken ?? .eof) peek: .\(peekToken ?? .eof)")
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
                print("Unknown token .\(currentToken ?? .eof) .\(peekToken ?? .eof)")
                break
            }
        }
        return .statements(statements)
    }

    private mutating func parseLetStatement() -> Statement? {
        guard currentToken == .let else { return nil }
        guard let pt = next() else { return nil }
        guard let ct = currentToken else { return nil }
        guard case .ident(let name) = ct else { return nil }
        print("Parsing let statement for \(name)")
        guard case .assign = pt else { return nil }
        print("Is assign")
        guard let expressionToken  = next() else { return nil }
        print("Expression token: \(expressionToken)")
        guard let expression = parseExpression() else { return nil }
        print("Expression: \(expression)")

        return Statement.let(name: .name(name), value: expression)
    }

    private mutating func parseExpression() -> Expression? {
        guard let pt = next() else { return nil }
        guard let ct = currentToken else { return nil }
        print("Parsing expression for .\(ct) peek: .\(pt)")

        switch (ct, pt) {
            case (.numeric(let v), .eof):
                return .numericLiteral(v)
            case (.numeric(let v), .semicolon):
                return .numericLiteral(v)
            case (.numeric(let v), .rparen):
                return .numericLiteral(v)

            case (.numeric(let v), _):
                return parseInfixExpression(left: .numericLiteral(v))

            case (.ident(let n), .eof):
                return .identifier(.name(n))
            case (.ident(let n), .semicolon):
                return .identifier(.name(n))
            case (.ident(let n), .rparen):
                return .identifier(.name(n))

            case (.ident(let n), _):
                return parseInfixExpression(left: .identifier(.name(n)))

            case (.minus, _):
                fallthrough
            case (.bang, _):
                return parsePrefixExpression()

            case (.lparen, _):
                return parseGroupedExpression()

            default:
                return nil
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
        print("Parsing grouped expression ()")
        guard case .lparen = currentToken else { return nil }
        guard let expression = parseExpression() else { return nil }
        print("Parsing grouped expression for Ex: \(expression)")
        _ = next()
        guard case .rparen = currentToken else { return nil }

        return .group(expression)
    }

    private mutating func parsePrefixExpression() -> Expression? {
        guard let oper = currentToken else { return nil }
        print("Parsing prefix expression for \(oper.literal)")

        guard let right = parseExpression() else { return nil }

        switch oper {
            case .bang:
                return .prefix(operator: .bang, right: right)
            case .minus:
                return .prefix(operator: .minus, right: right)
            default:
                return nil
        }
    }

    private mutating func parseInfixExpression(left: Expression) -> Expression? {
        guard let pt = next() else { return nil }
        guard let oper = currentToken else { return nil }
        print("Parsing infix expression for .\(left) \(oper.literal) .\(pt)")

        guard let right = parseExpression() else { return nil }

        switch oper {
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

