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

    mutating func parse() -> Program {
        var statements: [Statement] = []

        while let (ct, pt) = next(), ct != nil {
            guard let ct = ct else { break }

            switch ct {
            case .let:
                guard let stmt = parseLetStatement() else {
                    print("Failed to parse let statement .\(ct) peek: .\(pt ?? .eof)")
                    fatalError("Failed to parse let statement")
                    break
                }
                statements.append(stmt)
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
        let prog = Program(statements: statements)
        return prog
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

        return Statement.let(name: Identifier(value: name), value: Expression(value: expressionToken))
    }
}

