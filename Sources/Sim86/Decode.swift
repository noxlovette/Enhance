import Foundation

// MARK: - Instruction Table
struct InstructionDecoder {

    // Helper function to create binary literal
    private static func B(_ value: UInt32, bitCount: UInt8) -> InstructionBits {
        return InstructionBits.literal(value, bitCount: bitCount)
    }

    static let instructionFormats: [InstructionFormat] = [
        // MOV instructions
        InstructionFormat(.mov, [B(0b100010, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .mov,
            [
                B(0b1100011, bitCount: 7), .w, .mod, B(0b000, bitCount: 3), .rm, .data, .dataIfW,
                .impD(0),
            ]),
        InstructionFormat(.mov, [B(0b1011, bitCount: 4), .w, .reg, .data, .dataIfW, .impD(1)]),
        InstructionFormat(
            .mov,
            [B(0b1010000, bitCount: 7), .w] + InstructionBits.addr + [
                .impREG(0), .impMOD(0b0), .impRM(0b110), .impD(1),
            ]),
        InstructionFormat(
            .mov,
            [B(0b1010001, bitCount: 7), .w] + InstructionBits.addr + [
                .impREG(0), .impMOD(0b0), .impRM(0b110), .impD(0),
            ]),
        InstructionFormat(
            .mov,
            [
                B(0b100011, bitCount: 6), .d, B(0b0, bitCount: 1), .mod, B(0b0, bitCount: 1), .sr,
                .rm,
            ]),

        // PUSH instructions
        InstructionFormat(
            .push, [B(0b11111111, bitCount: 8), .mod, B(0b110, bitCount: 3), .rm, .impW(1)]),
        InstructionFormat(.push, [B(0b01010, bitCount: 5), .reg, .impW(1)]),
        InstructionFormat(.push, [B(0b000, bitCount: 3), .sr, B(0b110, bitCount: 3), .impW(1)]),

        // POP instructions
        InstructionFormat(
            .pop, [B(0b10001111, bitCount: 8), .mod, B(0b000, bitCount: 3), .rm, .impW(1)]),
        InstructionFormat(.pop, [B(0b01011, bitCount: 5), .reg, .impW(1)]),
        InstructionFormat(.pop, [B(0b000, bitCount: 3), .sr, B(0b111, bitCount: 3), .impW(1)]),

        // ADD instructions
        InstructionFormat(.add, [B(0b000000, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .add,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b000, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .add, [B(0b0000010, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),

        // SUB instructions
        InstructionFormat(.sub, [B(0b001010, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .sub,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b101, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .sub, [B(0b0010110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),

        // CMP instructions
        InstructionFormat(.cmp, [B(0b001110, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .cmp,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b111, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .cmp, [B(0b0011110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),

        // Jump instructions
        InstructionFormat(.jmp, [B(0b11101001, bitCount: 8)] + InstructionBits.addr),
        InstructionFormat(.jmp, [B(0b11101011, bitCount: 8), .disp]),

        // Conditional jumps
        InstructionFormat(.je, [B(0b01110100, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jl, [B(0b01111100, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jle, [B(0b01111110, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jb, [B(0b01110010, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jbe, [B(0b01110110, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jne, [B(0b01110101, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jnl, [B(0b01111101, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jg, [B(0b01111111, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jnb, [B(0b01110011, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.ja, [B(0b01110111, bitCount: 8), .disp, .flags(.relJMPDisp)]),

        // Loop instructions
        InstructionFormat(.loop, [B(0b11100010, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.loopz, [B(0b11100001, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.loopnz, [B(0b11100000, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jcxz, [B(0b11100011, bitCount: 8), .disp, .flags(.relJMPDisp)]),
    ]

    // Register mapping table
    private static let regTable: [[(RegisterIndex, UInt8, UInt8)]] = [
        [(.a, 0, 1), (.a, 0, 2)],
        [(.c, 0, 1), (.c, 0, 2)],
        [(.d, 0, 1), (.d, 0, 2)],
        [(.b, 0, 1), (.b, 0, 2)],
        [(.a, 1, 1), (.sp, 0, 2)],
        [(.c, 1, 1), (.bp, 0, 2)],
        [(.d, 1, 1), (.si, 0, 2)],
        [(.b, 1, 1), (.di, 0, 2)],
    ]
    // convert intel's REG and RM field register encodings into ours
    private static func getRegOperand(intelRegIndex: UInt32, wide: Bool) -> InstructionOperand {
        var operand = InstructionOperand(type: .none)
        operand.type = .register

        let reg = regTable[Int(intelRegIndex & 0x7)][wide ? 1 : 0]
        operand.register = RegisterAccess(index: reg.0, offset: reg.1, count: reg.2)

        return operand
    }

    private static func parseDataValue(
        memory: Memory, access: inout SegmentedAccess, exists: Bool, wide: Bool,
        signExtended: Bool
    ) -> u32 {
        var result: u32 = 0
        if exists {
            if wide {
                let d0 = memory.readByte(at: getAbsoluteAddress(of: access))
                let d1 = memory.readByte(at: getAbsoluteAddress(of: access))
                result = (u32(d1) << 8) | u32(d0)
                access.segmentOffset += 2
            } else {
                result = u32(memory.readByte(at: getAbsoluteAddress(of: access)))
                if signExtended {
                    result = u32(Int32(Int8(bitPattern: u8(result))))
                }
                access.segmentOffset += 1

            }
        }

        return result
    }

    static func decodeInstruction(
        context: inout DisasmContext, memory: Memory, at: inout SegmentedAccess
    ) -> Instruction {
        var result = Instruction()

        for format in instructionFormats {
            if let instruction = tryDecode(
                context: &context, format: format, memory: memory, at: at)
            {
                at.segmentOffset += u16(instruction.size)
                result = instruction
                break
            }
        }
        return result
    }

    private static func tryDecode(
        context: inout DisasmContext, format: InstructionFormat, memory: Memory,
        at originalAt: SegmentedAccess
    ) -> Instruction? {
        var instruction = Instruction()
        var hasBits: u32 = 0
        var bits = Array(repeating: u32(0), count: Int(BitsUsage.count.rawValue))
        var valid = true
        var at = originalAt

        let startingAddress = getAbsoluteAddress(of: at)

        var bitsPendingCount: u8 = 0
        var bitsPending: u8 = 0

        for testBits in format.bits {
            if testBits.usage == .literal && testBits.bitCount == 0 {
                break
            }

            var readBits = testBits.value
            if testBits.bitCount != 0 {
                if bitsPendingCount == 0 {
                    bitsPendingCount = 8
                    bitsPending = memory.readByte(at: getAbsoluteAddress(of: at))
                    at.segmentOffset += 1
                }

                guard testBits.bitCount <= bitsPendingCount else {
                    return nil  // invalid instruction format
                }

                bitsPendingCount -= testBits.bitCount
                readBits = u32(bitsPending)
                readBits >>= bitsPendingCount
                readBits &= ~(0xff << testBits.bitCount)
            }

            if testBits.usage == .literal {
                valid = valid && (readBits == testBits.value)
            } else {
                bits[Int(testBits.usage.rawValue)] |= (readBits << testBits.shift)
                hasBits |= (1 << testBits.usage.rawValue)
            }

            if !valid {
                break
            }
        }

        guard valid else { return nil }

        // Process the decoded bits
        let mod = bits[Int(BitsUsage.mod.rawValue)]
        let rm = bits[Int(BitsUsage.rm.rawValue)]
        let w = bits[Int(BitsUsage.w.rawValue)]
        let s = bits[Int(BitsUsage.s.rawValue)] != 0
        let d = bits[Int(BitsUsage.d.rawValue)] != 0

        let hasDirectAddress = (mod == 0b00) && (rm == 0b110)
        let hasDisplacement =
            (bits[Int(BitsUsage.hasDisp.rawValue)] != 0) || (mod == 0b10) || (mod == 0b01)
            || hasDirectAddress
        let displacementIsW =
            (bits[Int(BitsUsage.dispAlwaysW.rawValue)] != 0) || (mod == 0b10) || hasDirectAddress
        let dataIsW = (bits[Int(BitsUsage.wMakesDataW.rawValue)] != 0) && !s && (w != 0)

        bits[Int(BitsUsage.disp.rawValue)] |= parseDataValue(
            memory: memory, access: &at, exists: hasDisplacement, wide: displacementIsW,
            signExtended: !displacementIsW)
        bits[Int(BitsUsage.data.rawValue)] |= parseDataValue(
            memory: memory, access: &at, exists: bits[Int(BitsUsage.hasData.rawValue)] != 0,
            wide: dataIsW, signExtended: s)

        instruction.op = format.op
        instruction.flags = InstructionFlag(
            rawValue: context.additionalFlags.rawValue
        )
        instruction.address = startingAddress
        instruction.size = getAbsoluteAddress(of: at) - startingAddress

        if w != 0 {
            instruction.flags.insert(.wide)  // Inst_Wide flag
        }

        let displacement = Int16(bitPattern: UInt16(bits[Int(BitsUsage.disp.rawValue)]))

        let regOperandIndex = d ? 0 : 1
        let modOperandIndex = d ? 1 : 0

        // Handle register operand
        if hasBits & (1 << BitsUsage.reg.rawValue) != 0 {
            instruction.operands[regOperandIndex] = getRegOperand(
                intelRegIndex: bits[Int(BitsUsage.reg.rawValue)], wide: w != 0)
        }

        // Handle mod operand
        if hasBits & (1 << BitsUsage.mod.rawValue) != 0 {
            if mod == 0b11 {
                instruction.operands[modOperandIndex] = getRegOperand(
                    intelRegIndex: rm,
                    wide: (w != 0) || (bits[Int(BitsUsage.rmRegAlwaysW.rawValue)] != 0))
            } else {
                instruction.operands[modOperandIndex].type = .memory
                instruction.operands[modOperandIndex].address.segment = context.defaultSegment
                instruction.operands[modOperandIndex].address.displacement = s32(displacement)

                if (mod == 0b00) && (rm == 0b110) {
                    instruction.operands[modOperandIndex].address.base = .direct
                } else {
                    instruction.operands[modOperandIndex].address.base =
                        EffectiveAddressBase(rawValue: 1 + rm) ?? .direct
                }
            }
        }

        // Handle additional operands
        var lastOperandIndex = 0
        if instruction.operands[0].type != .none {
            lastOperandIndex = 1
        }

        if bits[Int(BitsUsage.relJMPDisp.rawValue)] != 0 {
            instruction.operands[lastOperandIndex].type = .relativeImmediate
            instruction.operands[lastOperandIndex].immediateS32 =
                Int32(displacement) + Int32(instruction.size)
        }

        if bits[Int(BitsUsage.hasData.rawValue)] != 0 {
            instruction.operands[lastOperandIndex].type = .immediate
            instruction.operands[lastOperandIndex].immediateU32 = bits[Int(BitsUsage.data.rawValue)]
        }

        return instruction

    }
}
