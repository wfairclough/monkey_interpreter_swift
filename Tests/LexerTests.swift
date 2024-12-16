import Testing

@testable import Monkey

@Test
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
    static let simpleSampleCode = """
        let five = 5;
        let ten = 10;
        let add = fn(x, y) {
            x + y;
        };
        let result = add(five, ten);
        """

    static let complexSampleCode = """
        let five = 5;
        let ten = 10;

        let add = fn(x, y) {
            x + y;
        };

        let result = add(five, ten);
        !-/*5;
        5 < 10 > 5;

        if (5 < 10) {
            return true;
        } else {
            return false;
        }

        10 == 10;
        10 != 9;

        // This is a comment
        //// Comment1
        //    Comment2
        /////     Comment3
        //Comment4
        / NotAComment
    """

    @Test
    func testNextTokenWithSimpleCode() {
        var sampleCodeLexer = Lexer.parse(input: LexerTests.simpleSampleCode)
        let expectedTokens = [
            Token.let,
            .ident("five"),
            .assign,
            .numeric(5),
            .semicolon,
            .let,
            .ident("ten"),
            .assign,
            .numeric(10),
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
            #expect(expectedToken == token, "Expected token .\(expectedToken), got .\(token)")
        }
    }
    
    @Test
    func testNextTokenWithComplexCode() {
        var sampleCodeLexer = Lexer.parse(input: LexerTests.complexSampleCode)
        let expectedTokens = [
            Token.let,
            .ident("five"),
            .assign,
            .numeric(5),
            .semicolon,
            .let,
            .ident("ten"),
            .assign,
            .numeric(10),
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
            .bang,
            .minus,
            .slash,
            .asterisk,
            .numeric(5),
            .semicolon,
            .numeric(5),
            .lt,
            .numeric(10),
            .gt,
            .numeric(5),
            .semicolon,
            .if,
            .lparen,
            .numeric(5),
            .lt,
            .numeric(10),
            .rparen,
            .lbrace,
            .return,
            .true,
            .semicolon,
            .rbrace,
            .else,
            .lbrace,
            .return,
            .false,
            .semicolon,
            .rbrace,
            .numeric(10),
            .equal,
            .numeric(10),
            .semicolon,
            .numeric(10),
            .notEqual,
            .numeric(9),
            .semicolon,
            .singleLineComment("This is a comment"),
            .singleLineComment("Comment1"),
            .singleLineComment("Comment2"),
            .singleLineComment("Comment3"),
            .singleLineComment("Comment4"),
            .slash,
            .ident("NotAComment"),
        ]

        for expectedToken in expectedTokens {
            let token = sampleCodeLexer.next() ?? .eof
            if case .illegal(let position) = token {
                #expect(Bool(false), "Illegal token found at position \(position)")
                break
            }
            #expect(expectedToken == token, "Expected token .\(expectedToken), got .\(token)")
        }
    }

}
