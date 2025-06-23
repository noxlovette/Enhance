import Foundation

let regNames16 = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"]
let regNames8 = ["al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"]

// note: bp in position 7 is only valid with displacement, if mod == 00 it's 16 displacemenet, direct address
let mod00 = [
    "bx + si", "bx + di", "bp + si", "bp + di", "si", "di", "bp", "bx",
]

func readBinaryFile(url: String) -> [UInt8]? {
    let fileURL = URL(fileURLWithPath: url)

    do {
        let data = try Data(contentsOf: fileURL)
        return [UInt8](data)
    } catch {
        return nil
    }
}

func readAllFiles(in directoryPath: String) {
    let fileManager = FileManager.default
    let dirURL = URL(fileURLWithPath: directoryPath)

    guard let enumerator = fileManager.enumerator(at: dirURL, includingPropertiesForKeys: nil)
    else {
        print("Failed to enumerate directory: \(directoryPath)")
        return
    }

    for case let fileURL as URL in enumerator {
        guard fileURL.hasDirectoryPath == false else { continue }

        let path = fileURL.path
        if let bytes = readBinaryFile(url: path) {
            print("Read \(bytes.count) bytes from \(path)")
            decode(bytes)
        }
    }
}

enum Direction {
    case regToRm
    case rmToReg
}

/// Supported operations: mov
/// - Parameter bytes:
func decode(_ bytes: [UInt8]) {
    var pc = 0
    while pc < bytes.count {
        let firstByte = bytes[pc]
        pc += 1

        // Check for immediate to register first (1011 wxxx pattern)
        let immToRegPattern = firstByte & 0b11110000  // Mask out last 4 bits
        if immToRegPattern == 0b10110000 {
            let is16Bit = (firstByte & 0b00001000) != 0  // w bit
            let reg = firstByte & 0b00000111  // reg bits
            let regNames = is16Bit ? regNames16 : regNames8
            let regName = regNames[Int(reg)]

            if is16Bit {
                let immediate = UInt16(bytes[pc]) | (UInt16(bytes[pc + 1]) << 8)
                pc += 2
                print("mov \(regName), \(immediate)")
            } else {
                let immediate = bytes[pc]
                pc += 1
                print("mov \(regName), \(immediate)")
            }
        } else {
            // Extract opcode (first 6 bits) for other instructions
            let opcode = firstByte & 0b11111100
            switch opcode {
            case 0b10001000:  // MOV reg/mem to/from reg
                let is16Bit = (firstByte & 0b00000001) != 0
                let direction: Direction = (firstByte & 0b00000010) != 0 ? .rmToReg : .regToRm
                let modrm = bytes[pc]
                let mod = (modrm & 0b11000000) >> 6
                let reg = (modrm & 0b00111000) >> 3
                let rm = (modrm & 0b00000111)
                let regNames = is16Bit ? regNames16 : regNames8
                let regName = regNames[Int(reg)]
                pc += 1

                if mod == 0b11 {  // register mode (no displacement)
                    let rmName = regNames[Int(rm)]
                    switch direction {
                    case .regToRm:
                        print("mov \(rmName), \(regName)")
                    case .rmToReg:
                        print("mov \(regName), \(rmName)")
                    }
                } else if mod == 0b10 {  // 16-bit displacement
                    let rmName = mod00[Int(rm)]
                    // Fixed: proper parentheses for bit shifting
                    let displacement = UInt16(bytes[pc]) | (UInt16(bytes[pc + 1]) << 8)
                    pc += 2

                    switch direction {
                    case .regToRm:
                        print("mov [\(rmName) + \(displacement)], \(regName)")
                    case .rmToReg:
                        print("mov \(regName), [\(rmName) + \(displacement)]")
                    }
                } else if mod == 0b01 {  // 8-bit displacement
                    let rmName = mod00[Int(rm)]
                    let displacement = bytes[pc]
                    pc += 1

                    switch direction {
                    case .regToRm:
                        print("mov [\(rmName) + \(displacement)], \(regName)")
                    case .rmToReg:
                        print("mov \(regName), [\(rmName) + \(displacement)]")
                    }
                } else if mod == 0b00 {  // memory, no displacement
                    if rm == 0b110 {
                        // Special case: direct address (16-bit immediate address)
                        let address = UInt16(bytes[pc]) | (UInt16(bytes[pc + 1]) << 8)
                        pc += 2
                        switch direction {
                        case .regToRm:
                            print("mov [\(address)], \(regName)")
                        case .rmToReg:
                            print("mov \(regName), [\(address)]")
                        }
                    } else {
                        let rmName = mod00[Int(rm)]
                        switch direction {
                        case .regToRm:
                            print("mov [\(rmName)], \(regName)")
                        case .rmToReg:
                            print("mov \(regName), [\(rmName)]")
                        }
                    }
                } else {
                    print("Error decoding mod")
                }
            default:
                print(String(format: "Unknown opcode: 0x%02X", firstByte))
                return
            }
        }
    }
}
