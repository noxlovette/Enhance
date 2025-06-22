import Foundation

let regNames16 = ["ax", "cx", "dx", "bx", "sp", "bp", "si", "di"]
let regNames8 = ["al", "cl", "dl", "bl", "ah", "ch", "dh", "bh"]

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

/// Supported operations: add
/// - Parameter bytes:
func decode(_ bytes: [UInt8]) {

    var pc = 0
    while pc < bytes.count {
        let opcode = bytes[pc]
        pc += 1

        switch opcode {
        case 0x89:  // literally: ok we are dealing with 16-bit mov!
            let modrm = bytes[pc]
            pc += 1  // we are looking at the next byte – who are the target and the source?
            let mod = (modrm & 0b11000000) >> 6  // take two first bits – the mod part of the byte, move them all the way back to cleanup
            let reg = (modrm & 0b00111000) >> 3  // same
            let rm = (modrm & 0b00000111)

            if mod == 0b11 {
                let dest = regNames16[Int(rm)]
                let src = regNames16[Int(reg)]
                print("mov \(dest), \(src)")
            } else {
                print("Memory addressing mode not implemented yet.")
            }
        case 0x88:
            let modrm = bytes[pc]
            pc += 1
            let mod = (modrm & 0b11000000) >> 6  // take two first bits – the mod part of the byte, move them all the way back to cleanup
            let reg = (modrm & 0b00111000) >> 3  // same
            let rm = (modrm & 0b00000111)

            if mod == 0b11 {
                let dest = regNames8[Int(rm)]
                let src = regNames8[Int(reg)]
                print("mov \(dest), \(src)")
            } else {
                print("Memory addressing mode not implemented yet.")
            }

        default:
            print(String(format: "Unknown opcode: 0x%02X", opcode))
            return
        }

    }
}
