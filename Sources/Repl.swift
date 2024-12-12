
struct Repl {

    func run() {
        print("Welcome to the Monkey REPL!")
        print("Type 'exit' to quit")
        while true {
            print(">> ", terminator: "")
            if let input = readLine() {
                if input == "exit" {
                    break
                }
                let lexer = Lexer.parse(input: input)
                print(lexer)
                var p = Parser(lexer: lexer)
                let program = p.parse()
                // for token in lexer {
                //     if token == .eof {
                //         break
                //     }
                //     if case .illegal(let position) = token {
                //         print("Illegal token found at position \(position)")
                //         break
                //     }
                //     print(".\(token)")
                // }
                print("Parsed program:")
                print(program)
                program.statements.forEach { print($0) }
            }
        }
    }

}
