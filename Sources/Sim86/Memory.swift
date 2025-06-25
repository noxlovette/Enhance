import Foundation

// MARK: - Constants
/// 8086 had 1MB of memory
let MEMORY_SIZE: Int = 1024 * 1024
/// if I want to access these bytes, I can take any number, I will be inside of the legal range
let MEMORY_ACCESS_MASK: u32 = 0xFFFFF

// MARK: - Memory Model
struct Memory {
    var bytes: [u8] = Array(repeating: 0, count: MEMORY_SIZE)
    func readByte(at address: UInt32) -> UInt8 {
        return bytes[Int(address)]
    }
}

// MARK: - Segmented Addressing
/// How memory is accessed in 8086. Take the base, shift by 4, apply offset
struct SegmentedAccess {
    let segmentBase: u16
    var segmentOffset: u16
}

// MARK: - Address Calculation
/// way of getting whichever byte is there
func getAbsoluteAddress(of segmentBase: u16, _ segmentOffset: u16, _ additionalOffset: u16 = 0) -> u32 {
    // First do the segment calculation: (segmentBase << 4) + (segmentOffset + additionalOffset)
    // Then apply the memory mask
    let result = (((u32(segmentBase) << 4) + u32(segmentOffset + additionalOffset)) & MEMORY_ACCESS_MASK)
    return result
}

func getAbsoluteAddress(of access: SegmentedAccess, _ additionalOffset: u16 = 0) -> u32 {
    return getAbsoluteAddress(of: access.segmentBase, access.segmentOffset, additionalOffset)
}
// MARK: - Memory Access
/// Get the byte from memory
/// - Parameters:
///   - memory:
///   - absoluteAddress:
/// - Returns:
func readMemory(_ memory: Memory, absoluteAddress: u32) -> u8 {
    let maskedAddress = Int(absoluteAddress & MEMORY_ACCESS_MASK)
    return memory.bytes[maskedAddress]
}

// MARK: - Load Memory From File
func loadMemory(fromFile fileName: String, into memory: inout Memory, atOffset: u32) -> u32 {
    let offset = Int(atOffset)
    guard offset < memory.bytes.count else {
        return 0
    }

    let fileURL = URL(fileURLWithPath: fileName)
    guard let data = try? Data(contentsOf: fileURL) else {
        fputs("ERROR: Unable to open \(fileName).\n", stderr)
        return 0
    }

    let maxCopyCount = memory.bytes.count - offset
    let copyCount = min(data.count, maxCopyCount)

    data.copyBytes(to: &memory.bytes[offset], count: copyCount)
    return u32(copyCount)
}

func advanceSegmentedAddress(_ access: SegmentedAccess, by offset: u32) -> SegmentedAccess {
    let absolute = getAbsoluteAddress(of: access) + offset
    
    // Normalize to standard form where offset < 65536
    let newSegment = u16((absolute >> 4) & 0xFFFF)
    let newOffset = u16(absolute & 0xFFFF)
    
    return SegmentedAccess(segmentBase: newSegment, segmentOffset: newOffset)
}
