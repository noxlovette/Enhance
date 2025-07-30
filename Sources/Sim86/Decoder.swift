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
        
        // XCHG instructions
        InstructionFormat(.xchg, [B(0b1000011, bitCount: 7), .w, .mod, .reg, .rm]),
        InstructionFormat(.xchg, [B(0b10010, bitCount: 5), .reg, .impW(1), .impREG(0)]), // with AX
        
        // IN/OUT instructions
        InstructionFormat(.`in`, [B(0b1110010, bitCount: 7), .w, .data, .impREG(0)]),
        InstructionFormat(.`in`, [B(0b1110110, bitCount: 7), .w, .impREG(0), .impREG(2)]), // from DX
        InstructionFormat(.out, [B(0b1110011, bitCount: 7), .w, .data, .impREG(0)]),
        InstructionFormat(.out, [B(0b1110111, bitCount: 7), .w, .impREG(2), .impREG(0)]), // to DX
        
        // String operations
        InstructionFormat(.xlat, [B(0b11010111, bitCount: 8)]),
        
        // LEA, LDS, LES
        InstructionFormat(.lea, [B(0b10001101, bitCount: 8), .mod, .reg, .rm, .impW(1)]),
        InstructionFormat(.lds, [B(0b11000101, bitCount: 8), .mod, .reg, .rm, .impW(1)]),
        InstructionFormat(.les, [B(0b11000100, bitCount: 8), .mod, .reg, .rm, .impW(1)]),
        
        // Flag operations
        InstructionFormat(.lahf, [B(0b10011111, bitCount: 8)]),
        InstructionFormat(.sahf, [B(0b10011110, bitCount: 8)]),
        InstructionFormat(.pushf, [B(0b10011100, bitCount: 8)]),
        InstructionFormat(.popf, [B(0b10011101, bitCount: 8)]),
        
        // ADD instructions
        InstructionFormat(.add, [B(0b000000, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .add,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b000, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .add, [B(0b0000010, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // ADC instructions
        InstructionFormat(.adc, [B(0b000100, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .adc,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b010, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .adc, [B(0b0001010, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // INC instructions
        InstructionFormat(.inc, [B(0b1111111, bitCount: 7), .w, .mod, B(0b000, bitCount: 3), .rm]),
        InstructionFormat(.inc, [B(0b01000, bitCount: 5), .reg, .impW(1)]),
        
        // AAA, DAA
        InstructionFormat(.aaa, [B(0b00110111, bitCount: 8)]),
        InstructionFormat(.daa, [B(0b00100111, bitCount: 8)]),
        
        // SUB instructions
        InstructionFormat(.sub, [B(0b001010, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .sub,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b101, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .sub, [B(0b0010110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // SBB instructions
        InstructionFormat(.sbb, [B(0b000110, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .sbb,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b011, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .sbb, [B(0b0001110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // DEC instructions
        InstructionFormat(.dec, [B(0b1111111, bitCount: 7), .w, .mod, B(0b001, bitCount: 3), .rm]),
        InstructionFormat(.dec, [B(0b01001, bitCount: 5), .reg, .impW(1)]),
        
        // NEG instruction
        InstructionFormat(.neg, [B(0b1111011, bitCount: 7), .w, .mod, B(0b011, bitCount: 3), .rm]),
        
        // CMP instructions
        InstructionFormat(.cmp, [B(0b001110, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(
            .cmp,
            [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b111, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(
            .cmp, [B(0b0011110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // AAS, DAS
        InstructionFormat(.aas, [B(0b00111111, bitCount: 8)]),
        InstructionFormat(.das, [B(0b00101111, bitCount: 8)]),
        
        // MUL instructions
        InstructionFormat(.mul, [B(0b1111011, bitCount: 7), .w, .mod, B(0b100, bitCount: 3), .rm]),
        
        // IMUL instructions
        InstructionFormat(.imul, [B(0b1111011, bitCount: 7), .w, .mod, B(0b101, bitCount: 3), .rm]),
        
        // AAM, AAD
        InstructionFormat(.aam, [B(0b1101010000001010, bitCount: 16)]),
        InstructionFormat(.aad, [B(0b1101010100001010, bitCount: 16)]),
        
        // DIV instructions
        InstructionFormat(.div, [B(0b1111011, bitCount: 7), .w, .mod, B(0b110, bitCount: 3), .rm]),
        
        // IDIV instructions
        InstructionFormat(.idiv, [B(0b1111011, bitCount: 7), .w, .mod, B(0b111, bitCount: 3), .rm]),
        
        // CBW, CWD
        InstructionFormat(.cbw, [B(0b10011000, bitCount: 8)]),
        InstructionFormat(.cwd, [B(0b10011001, bitCount: 8)]),
        
        // NOT instruction
        InstructionFormat(.not, [B(0b1111011, bitCount: 7), .w, .mod, B(0b010, bitCount: 3), .rm]),
        
        // Shift/Rotate instructions
        InstructionFormat(.shl, [B(0b1101000, bitCount: 7), .w, .mod, B(0b100, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.shl, [B(0b1101001, bitCount: 7), .w, .mod, B(0b100, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.shr, [B(0b1101000, bitCount: 7), .w, .mod, B(0b101, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.shr, [B(0b1101001, bitCount: 7), .w, .mod, B(0b101, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.sar, [B(0b1101000, bitCount: 7), .w, .mod, B(0b111, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.sar, [B(0b1101001, bitCount: 7), .w, .mod, B(0b111, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.rol, [B(0b1101000, bitCount: 7), .w, .mod, B(0b000, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.rol, [B(0b1101001, bitCount: 7), .w, .mod, B(0b000, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.ror, [B(0b1101000, bitCount: 7), .w, .mod, B(0b001, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.ror, [B(0b1101001, bitCount: 7), .w, .mod, B(0b001, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.rcl, [B(0b1101000, bitCount: 7), .w, .mod, B(0b010, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.rcl, [B(0b1101001, bitCount: 7), .w, .mod, B(0b010, bitCount: 3), .rm, .impREG(1)]),
        InstructionFormat(.rcr, [B(0b1101000, bitCount: 7), .w, .mod, B(0b011, bitCount: 3), .rm, .impD(1)]),
        InstructionFormat(.rcr, [B(0b1101001, bitCount: 7), .w, .mod, B(0b011, bitCount: 3), .rm, .impREG(1)]),
        
        // Logical operations
        InstructionFormat(.and, [B(0b001000, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(.and, [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b100, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(.and, [B(0b0010010, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        InstructionFormat(.test, [B(0b1000010, bitCount: 7), .w, .mod, .reg, .rm]),
        InstructionFormat(.test, [B(0b1111011, bitCount: 7), .w, .mod, B(0b000, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(.test, [B(0b1010100, bitCount: 7), .w, .data, .dataIfW, .impREG(0)]),
        
        InstructionFormat(.or, [B(0b000010, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(.or, [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b001, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(.or, [B(0b0000110, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        InstructionFormat(.xor, [B(0b001100, bitCount: 6), .d, .w, .mod, .reg, .rm]),
        InstructionFormat(.xor, [B(0b100000, bitCount: 6), .s, .w, .mod, B(0b110, bitCount: 3), .rm, .data, .dataIfW]),
        InstructionFormat(.xor, [B(0b0011010, bitCount: 7), .w, .data, .dataIfW, .impREG(0), .impD(1)]),
        
        // String operations with REP
        InstructionFormat(.rep, [B(0b11110011, bitCount: 8)]), // REP prefix
        InstructionFormat(.movs, [B(0b1010010, bitCount: 7), .w]),
        InstructionFormat(.cmps, [B(0b1010011, bitCount: 7), .w]),
        InstructionFormat(.scas, [B(0b1010111, bitCount: 7), .w]),
        InstructionFormat(.lods, [B(0b1010110, bitCount: 7), .w]),
        InstructionFormat(.stos, [B(0b1010101, bitCount: 7), .w]),
        
        // Control transfer
        InstructionFormat(.call, [B(0b11101000, bitCount: 8)] + InstructionBits.addr),
        InstructionFormat(.call, [B(0b11111111, bitCount: 8), .mod, B(0b010, bitCount: 3), .rm, .impW(1)]),
        InstructionFormat(.call, [B(0b01010, bitCount: 5), .reg, .impW(1)]),
        
        InstructionFormat(.jmp, [B(0b11101001, bitCount: 8)] + InstructionBits.addr),
        InstructionFormat(.jmp, [B(0b11101011, bitCount: 8), .disp]),
        InstructionFormat(.jmp, [B(0b11111111, bitCount: 8), .mod, B(0b100, bitCount: 3), .rm, .impW(1)]),
        InstructionFormat(.jmp, [B(0b01000, bitCount: 5), .reg, .impW(1)]),
        
        InstructionFormat(.ret, [B(0b11000011, bitCount: 8)]),
        InstructionFormat(.ret, [B(0b11000010, bitCount: 8), .data]),
        
        // Conditional jumps
        InstructionFormat(.je, [B(0b01110100, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jl, [B(0b01111100, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jle, [B(0b01111110, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jb, [B(0b01110010, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jbe, [B(0b01110110, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jp, [B(0b01111010, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jo, [B(0b01110000, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.js, [B(0b01111000, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jne, [B(0b01110101, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jnl, [B(0b01111101, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jg, [B(0b01111111, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jnb, [B(0b01110011, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.ja, [B(0b01110111, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jnp, [B(0b01111011, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jno, [B(0b01110001, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jns, [B(0b01111001, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        
        // Loop instructions
        InstructionFormat(.loop, [B(0b11100010, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.loopz, [B(0b11100001, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.loopnz, [B(0b11100000, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        InstructionFormat(.jcxz, [B(0b11100011, bitCount: 8), .disp, .flags(.relJMPDisp)]),
        
        // Interrupt instructions
        InstructionFormat(.int, [B(0b11001101, bitCount: 8), .data]),
        InstructionFormat(.int3, [B(0b11001100, bitCount: 8)]),
        InstructionFormat(.into, [B(0b11001110, bitCount: 8)]),
        InstructionFormat(.iret, [B(0b11001111, bitCount: 8)]),
        
        // Flag control
        InstructionFormat(.clc, [B(0b11111000, bitCount: 8)]),
        InstructionFormat(.cmc, [B(0b11110101, bitCount: 8)]),
        InstructionFormat(.stc, [B(0b11111001, bitCount: 8)]),
        InstructionFormat(.cld, [B(0b11111100, bitCount: 8)]),
        InstructionFormat(.std, [B(0b11111101, bitCount: 8)]),
        InstructionFormat(.cli, [B(0b11111010, bitCount: 8)]),
        InstructionFormat(.sti, [B(0b11111011, bitCount: 8)]),
        InstructionFormat(.hlt, [B(0b11110100, bitCount: 8)]),
        InstructionFormat(.wait, [B(0b10011011, bitCount: 8)]),
        
        // Prefixes
        InstructionFormat(.lock, [B(0b11110000, bitCount: 8)]),
        InstructionFormat(.segment, [B(0b001, bitCount: 3), .sr, B(0b110, bitCount: 3)]), // Segment override
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
    
    /// Segment register table
    private static let segmentRegTable: [RegisterIndex] = [
        .es, .cs, .ss, .ds
    ]
    
    /// convert intel's REG and RM field register encodings into ours
    private static func getRegOperand(intelRegIndex: UInt32, wide: Bool) -> InstructionOperand {
        var operand = InstructionOperand(type: .none)
        operand.type = .register
        
        let reg = regTable[Int(intelRegIndex & 0x7)][wide ? 1 : 0]
        operand.register = RegisterAccess(index: reg.0, offset: reg.1, count: reg.2)
        
        return operand
    }
    
    /// Get segment register operand
    private static func getSegmentRegOperand(segmentRegIndex: UInt32) -> InstructionOperand {
        var operand = InstructionOperand(type: .none)
        operand.type = .register
        
        let segReg = segmentRegTable[Int(segmentRegIndex & 0x3)]
        operand.register = RegisterAccess(index: segReg, offset: 0, count: 2)
        
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
                access.segmentOffset += 1
                let d1 = memory.readByte(at: getAbsoluteAddress(of: access))
                access.segmentOffset += 1
                result = (u32(d1) << 8) | u32(d0)
            } else {
                result = u32(memory.readByte(at: getAbsoluteAddress(of: access)))
                access.segmentOffset += 1
                
                if signExtended {
                    // Properly handle sign extension using bitPattern
                    let signedByte = Int8(bitPattern: u8(result))
                    let signedExtended = Int32(signedByte)
                    result = u32(bitPattern: signedExtended)
                }
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
        
        // Initialize operands array with enough elements
        instruction.operands = Array(repeating: InstructionOperand(type: .none), count: 3)
        
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

        // Parse displacement and data separately, don't use |= to accumulate
        let dispValue = parseDataValue(
            memory: memory, access: &at, exists: hasDisplacement, wide: displacementIsW,
            signExtended: !displacementIsW)
        
        let dataValue = parseDataValue(
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

        // Use the parsed displacement value directly, ensuring it fits in Int16
        let displacement = Int16(bitPattern: UInt16(dispValue & 0xFFFF))

        let regOperandIndex = d ? 0 : 1
        let modOperandIndex = d ? 1 : 0

        // Handle register operand - now safe because we pre-allocated the array
        if hasBits & (1 << BitsUsage.reg.rawValue) != 0 {
            instruction.operands[regOperandIndex] = getRegOperand(
                intelRegIndex: bits[Int(BitsUsage.reg.rawValue)], wide: w != 0)
        }

        // Handle mod operand - now safe because we pre-allocated the array
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
        if instruction.operands[1].type != .none {
            lastOperandIndex = 2
        }

        if bits[Int(BitsUsage.relJMPDisp.rawValue)] != 0 {
            instruction.operands[lastOperandIndex].type = .relativeImmediate
            instruction.operands[lastOperandIndex].immediateS32 =
                Int32(displacement) + Int32(instruction.size)
        }

        if bits[Int(BitsUsage.hasData.rawValue)] != 0 {
            instruction.operands[lastOperandIndex].type = .immediate
            instruction.operands[lastOperandIndex].immediateU32 = dataValue
        }

        return instruction
    }
}
