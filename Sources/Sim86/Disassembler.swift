/// Disassembles 8086 instructions starting at a segmented address.
///
/// - Parameters:
///   - memory: The 8086 memory model to disassemble from.
///   - disAsmByteCount: How many bytes to disassemble starting at the given address.
///   - disAsmStart: The segmented memory address to begin disassembly.
func disAsm8086(memory: Memory, disAsmByteCount: u32) {
    let disAsmStart = SegmentedAccess(segmentBase: 0, segmentOffset: 0)
    var at = disAsmStart
    var context = DisasmContext()
    var remainingBytes = disAsmByteCount

    
    while remainingBytes > 0 {
        let currentOffset = at.segmentOffset
        let currentByte = memory.readByte(at: getAbsoluteAddress(of: at))
        
        
        var instruction = InstructionDecoder.decodeInstruction(
            context: &context,
            memory: memory,
            at: &at
        )

        if instruction.op != .none {
            
            if remainingBytes >= instruction.size {
                remainingBytes -= instruction.size
            } else {
                break
            }

            // Update context with this instruction
            context.update(with: instruction)
            
            // Apply any pending flags from context to the instruction
            context.applyFlags(to: &instruction)

            // Only print non-prefix instructions
            if instruction.isPrintable {
                printInstruction(&instruction)
                print()
            }

        } else {
            break
        }
    }
    
}


func execAsm8086(memory: Memory, disAsmByteCount: u32) {
    let disAsmStart = SegmentedAccess(segmentBase: 0, segmentOffset: 0)
    var at = disAsmStart
    var context = DisasmContext()
    var remainingBytes = disAsmByteCount
    var cpuState = CPUState()

    print("Final registers:")
    cpuState.printState()
    print("")

    while remainingBytes > 0 {
        var instruction = InstructionDecoder.decodeInstruction(
            context: &context,
            memory: memory,
            at: &at
        )

        if instruction.op != .none {
            if remainingBytes >= instruction.size {
                remainingBytes -= instruction.size
            } else {
                break
            }

            // Update context with this instruction
            context.update(with: instruction)

            // Apply any pending flags from context to the instruction
            context.applyFlags(to: &instruction)

            // Only process non-prefix instructions
            if instruction.isPrintable {
                // Execute the instruction and update CPU state
                let stateChanged = executeInstruction(&instruction, &cpuState, memory)

                // Print instruction with execution results
                printInstructionWithExecution(&instruction, cpuState: &cpuState, stateChanged: stateChanged)
                print()
            }

        } else {
            break
        }
    }

    print("Final registers:")
    cpuState.printState()
}
