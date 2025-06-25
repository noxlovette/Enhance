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
                    let sign = address.displacement >= 0 ? " + " : ""
                    print("\(sign)\(address.displacement)", terminator: "")
                }
                print("]", terminator: "")

            case .immediate:
                print("\(operand.immediateU32)", terminator: "")

            case .relativeImmediate:
                print(
                    "$\(operand.immediateS32 >= 0 ? " + " : "")\(operand.immediateS32)",
                    terminator: "")

            case .none:
                break
            }
        }
    }
}

func printInstructionWithExecution(_ instruction: inout Instruction, cpuState: inout CPUState, stateChanged: Bool) {
    // Print the instruction as before
    printInstruction(&instruction)

    // If execution simulation is enabled and state changed, show the changes
    if stateChanged {
        print(" ; ", terminator: "")

        // Show register changes based on instruction type
        switch instruction.op {
        case .mov:
            if instruction.operands.count >= 2 {
                let dest = instruction.operands[0]
                if dest.type == .register {
                    let value = cpuState.getValue(for: dest.register)
                    if dest.register.count == 2 {
                        print("\(dest.register.getName()) = 0x\(String(format: "%04x", value)) (\(value))", terminator: "")
                    } else {
                        print("\(dest.register.getName()) = 0x\(String(format: "%02x", value)) (\(value))", terminator: "")
                    }
                }
            }

        case .add:
            if instruction.operands.count >= 2 {
                let dest = instruction.operands[0]
                let src = instruction.operands[1]
                if dest.type == .register {
                    let newValue = cpuState.getValue(for: dest.register)

                    // Calculate what the old value was
                    var srcValue: u32 = 0
                    switch src.type {
                    case .register:
                        srcValue = cpuState.getValue(for: src.register)
                    case .immediate:
                        srcValue = src.immediateU32
                    default:
                        break
                    }

                    let oldValue = newValue &- srcValue // Reverse the addition

                    if dest.register.count == 2 {
                        print("\(dest.register.getName()): 0x\(String(format: "%04x", oldValue)) -> 0x\(String(format: "%04x", newValue)) (\(oldValue) -> \(newValue))", terminator: "")
                    } else {
                        print("\(dest.register.getName()): 0x\(String(format: "%02x", oldValue)) -> 0x\(String(format: "%02x", newValue)) (\(oldValue) -> \(newValue))", terminator: "")
                    }
                }
            }

        case .sub:
            if instruction.operands.count >= 2 {
                let dest = instruction.operands[0]
                let src = instruction.operands[1]
                if dest.type == .register {
                    let newValue = cpuState.getValue(for: dest.register)

                    // Calculate what the old value was
                    var srcValue: u32 = 0
                    switch src.type {
                    case .register:
                        srcValue = cpuState.getValue(for: src.register)
                    case .immediate:
                        srcValue = src.immediateU32
                    default:
                        break
                    }

                    let oldValue = newValue + srcValue // Reverse the subtraction

                    if dest.register.count == 2 {
                        print("\(dest.register.getName()): 0x\(String(format: "%04x", oldValue)) -> 0x\(String(format: "%04x", newValue)) (\(oldValue) -> \(newValue))", terminator: "")
                    } else {
                        print("\(dest.register.getName()): 0x\(String(format: "%02x", oldValue)) -> 0x\(String(format: "%02x", newValue)) (\(oldValue) -> \(newValue))", terminator: "")
                    }
                }
            }

        default:
            break
        }
    }
}
