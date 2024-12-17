import Testing

@testable import Monkey

enum TestError: Error {
    case error(message: String)
}

@Test
func testParsingLetStatements() throws {
    let input = """
        let x = 5;
        let y = x;
        let sum = (x + y);
        let productAndSum = (7 * (x + y));
    """

    let lexer = Lexer.parse(input: input)
    var parser = Parser(lexer: lexer)
    let program = try? parser.parse()

    #expect(program != nil)
    guard let program = program else { throw TestError.error(message: "Program is nil") }

    guard case let .statements(statements) = program else {
        throw TestError.error(message: "Program is not a statements")
    }

    #expect(statements.count == 4)

    guard case let .`let`(name: xIdent, value: xValue) = statements[0] else {
        throw TestError.error(message: "First statement is not a let statement")
    }
    #expect(xIdent == Identifier.name("x"))
    #expect(xValue == Expression.numericLiteral(5))

    guard case let .`let`(name: yIdent, value: yValue) = statements[1] else {
        throw TestError.error(message: "Second statement is not a let statement")
    }
    #expect(yIdent == Identifier.name("y"))
    #expect(yValue == Expression.identifier(Identifier.name("x")))

    guard case let .`let`(name: sumIdent, value: sumValue) = statements[2] else {
        throw TestError.error(message: "Third statement is not a let statement")
    }
    #expect(sumIdent == Identifier.name("sum"))
    #expect(sumValue == Expression.group(
        Expression.infix(
            left: .identifier(Identifier.name("x")),
            operator: .add,
            right: .identifier(Identifier.name("y")
        ))
    ))

    guard case let .`let`(name: productAndSumIdent, value: productAndSumValue) = statements[3] else {
        throw TestError.error(message: "Fourth statement is not a let statement")
    }
    #expect(productAndSumIdent == Identifier.name("productAndSum"))
    #expect(productAndSumValue == Expression.group(
        Expression.infix(left: .numericLiteral(7), operator: .multiply, right: .group(
            Expression.infix(
                left: .identifier(Identifier.name("x")),
                operator: .add,
                right: .identifier(Identifier.name("y")
            )
        ))
    )))
}

@Test
func testParsingFnAndReturnStatements() {
    let input = """
        fn(x, y) {
            return x + y;
        }
    """

    let lexer = Lexer.parse(input: input)
    var parser = Parser(lexer: lexer)
    let programResult = Result { try parser.parse() }

    guard case .success(let program) = programResult else {
        printParserError(programResult)
        #expect(Bool(false))
        return
    }

    guard case let .statements(statements) = program else { return }
    #expect(statements.count == 1)

    guard case let .expression(expression) = statements[0] else { return }
    guard case let .function(parameters: params, body: body) = expression else { return }
    #expect(params == .named([Identifier.name("x"), Identifier.name("y")]))
    guard case let .statements(bodyStatements) = body else { return }
    #expect(bodyStatements.count == 1)
    guard case let .expression(returnExpression) = bodyStatements[0] else { return }
    guard case let .infix(left: left, operator: op, right: right) = returnExpression else { return }
    #expect(left == .identifier(Identifier.name("x")))
    #expect(op == .add)
    #expect(right == .identifier(Identifier.name("y")))
}

func printParserError(_ result: Result<Program, Error>) {
    switch result {
    case .success(let program):
        print("Program: \(program)")
    case .failure(let error):
        switch error {
            case ParserError.invalidToken(let message, let currToken, let peekToken):
                print("Error: \(message)")
                print("Current token: '\(currToken?.literal ?? "")'")
                print("Peek token: '\(peekToken?.literal ?? "")'")
            default:
                print("Error: \(error)")
        }
    }
}

