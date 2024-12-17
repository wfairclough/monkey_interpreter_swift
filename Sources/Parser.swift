enum ParserError: Error {
    case invalidToken(message: String, current: Token?, peek: Token?)
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
        return .statements(try parseStatements())
    }

    private mutating func parseLetStatement() throws -> Statement {
        guard currentToken == .let else {
            throw ParserError.invalidToken(message: "Expected 'let' token", current: currentToken, peek: peekToken)
        }
        guard let pt = next() else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard let ct = currentToken else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard case .ident(let name) = ct else {
            throw ParserError.invalidToken(message: "Expected identifier token", current: currentToken, peek: peekToken)
        }
        guard case .assign = pt else {
            throw ParserError.invalidToken(message: "Expected '=' token", current: currentToken, peek: peekToken)
        }
        guard let expressionToken = next() else {
            throw ParserError.invalidToken(message: "Expected expression token", current: currentToken, peek: peekToken)
        }
        let expression = try parseExpression()

        return Statement.let(name: .name(name), value: expression)
    }

    private mutating func parseExpression() throws -> Expression {
        guard let pt = next() else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard let ct = currentToken else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        print("Parsing expression for .\(ct) peek: .\(pt)")

        switch (ct, pt) {
            case (.numeric(let v), .eof):
                return .numericLiteral(v)
            case (.numeric(let v), .semicolon):
                return .numericLiteral(v)
            case (.numeric(let v), .rparen):
                return .numericLiteral(v)

            case (.numeric(let v), _):
                return try parseInfixExpression(left: .numericLiteral(v))

            case (.ident(let n), .eof):
                return .identifier(.name(n))
            case (.ident(let n), .semicolon):
                return .identifier(.name(n))
            case (.ident(let n), .rparen):
                return .identifier(.name(n))

            case (.ident(let n), _):
                return try parseInfixExpression(left: .identifier(.name(n)))

            case (.minus, _):
                fallthrough
            case (.bang, _):
                return try parsePrefixExpression()

            case (.lparen, _):
                return try parseGroupedExpression()

            default:
                throw ParserError.invalidToken(message: "Invalid token", current: ct, peek: pt)
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
    }

    private mutating func parseGroupedExpression() throws -> Expression {
        print("Parsing grouped expression ()")
        guard case .lparen = currentToken else {
            throw ParserError.invalidToken(message: "Expected '(' token", current: currentToken, peek: peekToken)
        }
        let expression = try parseExpression()
        print("Parsing grouped expression for Ex: \(expression)")
        _ = next()
        guard case .rparen = currentToken else {
            throw ParserError.invalidToken(message: "Expected ')' token", current: currentToken, peek: peekToken)
        }

        return .group(expression)
    }

    private mutating func parsePrefixExpression() throws -> Expression {
        guard let oper = currentToken else {
            throw ParserError.invalidToken(message: "Expected operator token", current: currentToken, peek: peekToken)
        }
        print("Parsing prefix expression for \(oper.literal)")

        let right = try parseExpression()

        switch oper {
            case .bang:
                return .prefix(operator: .bang, right: right)
            case .minus:
                return .prefix(operator: .minus, right: right)
            default:
                throw ParserError.invalidToken(message: "Invalid token", current: currentToken, peek: peekToken)
        }
    }

    private mutating func parseInfixExpression(left: Expression) throws -> Expression {
        guard let pt = next() else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard let oper = currentToken else {
            throw ParserError.invalidToken(message: "Expected operator token", current: currentToken, peek: peekToken)
        }
        print("Parsing infix expression for .\(left) \(oper.literal) .\(pt)")

        let right = try parseExpression()

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
                throw ParserError.invalidToken(message: "Invalid token", current: currentToken, peek: peekToken)
        }
    }

    private mutating func parseReturnStatement() throws -> Statement {
        guard case .return = currentToken else {
            throw ParserError.invalidToken(message: "Expected 'return' token", current: currentToken, peek: peekToken)
        }
        let expression = try parseExpression()
        return .expression(expression)
    }

    private mutating func parseFunctionStatment() throws -> Statement {
        print("Parsing function statement")
        guard case .function = currentToken else {
            throw ParserError.invalidToken(message: "Expected 'function' token", current: currentToken, peek: peekToken)
        }
        guard let _ = next() else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard let ct = currentToken else {
            throw ParserError.invalidToken(message: "Expected token, got .eof", current: currentToken, peek: peekToken)
        }
        guard case .lparen = ct else {
            throw ParserError.invalidToken(message: "Expected '(' token", current: currentToken, peek: peekToken)
        }
        let parameters = try parseFunctionParameters()
        let body = try parseBlockStatement()
        return Statement.expression(.function(parameters: parameters, body: body))
    }

    private mutating func parseFunctionParameters() throws -> FuncParams {
        var params: [Identifier] = []
        param_loop: while let _ = next() {
            guard let ct = currentToken else { break }

            switch ct {
            case .ident(let name):
                print("Parsing function parameter \(name)")
                params.append(.name(name))
                break
            case .comma:
                break
            case .rparen:
                print("End of function parameters")
                break param_loop
            default:
                print("Unknown token .\(currentToken ?? .eof) .\(peekToken ?? .eof)")
                break param_loop
            }
        }
        guard case .rparen = currentToken else {
            throw ParserError.invalidToken(message: "Expected .\(Token.rparen) token", current: currentToken, peek: peekToken)
        }
        guard case .lbrace = peekToken else {
            throw ParserError.invalidToken(message: "Expected .\(Token.lbrace) token", current: currentToken, peek: peekToken)
        }
        _ = next()
        return .named(params)
    }

    private mutating func parseBlockStatement() throws -> BlockStatement {
        guard case .lbrace = currentToken else {
            throw ParserError.invalidToken(message: "Expected .\(Token.lbrace) token", current: currentToken, peek: peekToken)
        }
        let stmts = try parseStatements()
        guard case .rbrace = currentToken else {
            throw ParserError.invalidToken(message: "Expected .\(Token.rbrace) token", current: currentToken, peek: peekToken)
        }
        _ = next()
        return .statements(stmts)
    }

    private mutating func parseStatements() throws -> [Statement] {
        var statements: [Statement] = []

        while let pt = next() {
            guard let ct = currentToken else { break }

            switch ct {
            case .let:
                let stmt = try parseLetStatement()
                statements.append(stmt)
            case .return:
                let returnStmt = try parseReturnStatement()
                statements.append(returnStmt)
            case .if:
                break
            case .function:
                let fnStmt = try parseFunctionStatment()
                statements.append(fnStmt)
            case .rbrace:
                break
            case .eof:
                print("Reached EOF")
                break
            default:
                print("Unknown token .\(currentToken ?? .eof) .\(peekToken ?? .eof)")
                break
            }
        }
        return statements
    }

}

