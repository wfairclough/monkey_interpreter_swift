
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
                print("You typed: \(input)")
                print("Running through lexer:")
                for token in lexer {
                    if token == .eof {
                        break
                    }
                    if case .illegal(let position) = token {
                        print("Illegal token found at position \(position)")
                        break
                    }
                    print(".\(token)")
                }
            }
        }
    }

}
