import Testing

@testable import Monkey

@Test(
    .disabled()
)
func testNextToken() {
    let input = "=+(){},;"

    let tests: [Token] = [
        .assign,
        .plus,
        .lparen,
        .rparen,
        .lbrace,
        .rbrace,
        .comma,
        .semicolon,
    ]

    #expect(tests.count == 8, "Count of tests")

    var lexer = Lexer.parse(input: input)

    for (i, expectedToken) in tests.enumerated() {
        let token = lexer.next()

        #expect(expectedToken == token, "test \(i) - token type")
    }
}

@Suite(.serialized) class LexerTests {
    static let codeSample = """
        let five = 5;
        let ten = 10;
        let add = fn(x, y) {
            x + y;
        };
        let result = add(five, ten);
        """
    @Test
    func testNextTokenWithCode() {
        var sampleCodeLexer = Lexer.parse(input: LexerTests.codeSample)
        let expectedTokens = [
            Token.let,
            .ident("five"),
            .assign,
            .integer(5),
            .semicolon,
            .let,
            .ident("ten"),
            .assign,
            .integer(10),
            .semicolon,
            .let,
            .ident("add"),
            .assign,
            .function,
            .lparen,
            .ident("x"),
            .comma,
            .ident("y"),
            .rparen,
            .lbrace,
            .ident("x"),
            .plus,
            .ident("y"),
            .semicolon,
            .rbrace,
            .semicolon,
            .let,
            .ident("result"),
            .assign,
            .ident("add"),
            .lparen,
            .ident("five"),
            .comma,
            .ident("ten"),
            .rparen,
            .semicolon,
        ]

        for expectedToken in expectedTokens {
            let token = sampleCodeLexer.next() ?? .eof
            print("Expected: .\(expectedToken), got: .\(token)")
            #expect(expectedToken == token, "Expected token .\(expectedToken), got .\(token)")
        }
    }
}
