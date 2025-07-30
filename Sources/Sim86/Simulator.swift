//
//  File.swift
//  Enhance
//
//  Created by Danila Volkov on 25.06.2025.
//




func executeInstruction(_ instruction: inout Instruction, _ cpuState: inout CPUState, _ memory: Memory) -> Bool {
    var stateChanged = false
    
    switch instruction.op {
    case .mov:
        if instruction.operands.count >= 2 {
            let dest = instruction.operands[0]
            let src = instruction.operands[1]
            
            var value: u32 = 0
            
            // Get source value
            switch src.type {
            case .register:
                value = cpuState.getValue(for: src.register)
            case .immediate:
                value = src.immediateU32
            case .memory:
                // For now, just use 0 for memory reads
                value = memory.bytes[src.address.base]
            default:
                break
            }
            
            // Set destination value
            if dest.type == .register {
                cpuState.setValue(value, for: dest.register)
                stateChanged = true
            }
        }
        
    case .add:
        if instruction.operands.count >= 2 {
            let dest = instruction.operands[0]
            let src = instruction.operands[1]
            
            if dest.type == .register {
                let destValue = cpuState.getValue(for: dest.register)
                var srcValue: u32 = 0
                
                switch src.type {
                case .register:
                    srcValue = cpuState.getValue(for: src.register)
                case .immediate:
                    srcValue = src.immediateU32
                case .memory:
                    srcValue = 0 // Simplified
                default:
                    break
                }
                
                let result = destValue + srcValue
                cpuState.updateFlags(result: result, operandSize: dest.register.count)
                // Handle overflow based on register size
                let maskedResult = dest.register.count == 2 ? (result & 0xFFFF) : (result & 0xFF)
                cpuState.setValue(maskedResult, for: dest.register)
                stateChanged = true
            }
        }
        
    case .sub:
        if instruction.operands.count >= 2 {
            let dest = instruction.operands[0]
            let src = instruction.operands[1]
            
            if dest.type == .register {
                let destValue = cpuState.getValue(for: dest.register)
                var srcValue: u32 = 0
                
                switch src.type {
                case .register:
                    srcValue = cpuState.getValue(for: src.register)
                case .immediate:
                    srcValue = src.immediateU32
                case .memory:
                    srcValue = 0 // Simplified
                default:
                    break
                }
                
                let result = destValue &- srcValue // Use overflow subtraction
                cpuState
                    .updateFlags(
                        result: result,
                        operandSize: dest.register.count
                    )
                let maskedResult = dest.register.count == 2 ? (result & 0xFFFF) : (result & 0xFF)
                cpuState.setValue(maskedResult, for: dest.register)
                stateChanged = true
            }
        }
        
    case .cmp:
        if instruction.operands.count >= 2 {
            let left = instruction.operands[0]
            let right = instruction.operands[1]

            if left.type == .register {
                let leftValue = cpuState.getValue(for: left.register)
                var rightValue: u32 = 0

                switch right.type {
                case .register:
                    rightValue = cpuState.getValue(for: right.register)
                case .immediate:
                    rightValue = right.immediateU32
                case .memory:
                    rightValue = 0 // Simplified
                default:
                    break
                }

                // CMP is like SUB but doesn't store result - just sets flags
                let result = leftValue &- rightValue
                cpuState.updateFlags(result: result, operandSize: left.register.count)
                stateChanged = true // Flags changed even though register didn't
            }
        }

    default:
        // For other instructions, we don't simulate execution yet
        stateChanged = false
    }
    
    return stateChanged
}
