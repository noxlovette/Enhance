func printInstruction(_ instruction: inout Instruction) {
    let flags = instruction.flags
    let isWide = flags.contains(.wide)

    // Handle LOCK prefix
    if flags.contains(.lock) {
        if instruction.op == .xchg {
            // Swap operands 0 and 1
            if instruction.operands.count >= 2 {
                let temp = instruction.operands[0]
                instruction.operands[0] = instruction.operands[1]
                instruction.operands[1] = temp
            }
        }
        print("lock ", terminator: "")
    }

    // REP prefix - Fixed logic
    var mnemonicSuffix = ""
    if flags.contains(.rep) {
        print("rep ", terminator: "")
        mnemonicSuffix = isWide ? "w" : "b"
    }

    print("\(instruction.op.mnemonic)\(mnemonicSuffix) ", terminator: "")

    var separator = ""
    for operand in instruction.operands {
        if operand.type != .none {
            print(separator, terminator: "")
            separator = ", "

            switch operand.type {
            case .register:
                print(operand.register.getName(), terminator: "")

            case .memory:
                let address = operand.address
                if instruction.operands.first?.type != .register {
                    print(isWide ? "word " : "byte ", terminator: "")
                }
                if flags.contains(.segment) {
                    print("\(address.segment.getName(count: 0, offset: 2)):", terminator: "")
                }
                print("[\(address.base.expression)", terminator: "")
                if address.displacement != 0 {
                    let sign = address.displacement >= 0 ? "+" : ""
                    print("\(sign)\(address.displacement)", terminator: "")
                }
                print("]", terminator: "")

            case .immediate:
                print("\(operand.immediateS32)", terminator: "")

            case .relativeImmediate:
                print(
                    "$\(operand.immediateS32 >= 0 ? "+" : "")\(operand.immediateS32)",
                    terminator: "")

            case .none:
                break
            }
        }
    }
    print()  // newline at the end
}
