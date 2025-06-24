/// Disassembles 8086 instructions starting at a segmented address.
///
/// - Parameters:
///   - memory: The 8086 memory model to disassemble from.
///   - disAsmByteCount: How many bytes to disassemble starting at the given address.
///   - disAsmStart: The segmented memory address to begin disassembly.
func disAsm8086(memory: Memory, disAsmByteCount: u32, disAsmStart: SegmentedAccess) {
    var at = disAsmStart  // Current location in memory
    var context = defaultDisAsmContext()  // Assume this returns a struct or class
    var remainingBytes = disAsmByteCount

    while remainingBytes > 0 {
        let instruction = decodeInstruction(context: context, at: at, memory: memory)

        if instruction.op != .none {
            if remainingBytes >= instruction.size {
                remainingBytes -= instruction.size
            } else {
                print("ERROR: Instruction extends outside disassembly region")
                break
            }

            // Accept instruction and move forward
            updateContext(&context, instruction)

            if isPrintable(instruction) {
                printInstruction(instruction)
                print()
            }

            // Advance the instruction pointer
            at = advanceSegmentedAddress(at, by: instruction.size)
        } else {
            print("ERROR: Unrecognised binary in instruction stream.")
            break
        }
    }
}
