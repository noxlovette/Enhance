typealias u8 = UInt8
typealias u16 = UInt16
typealias u32 = UInt32
typealias u64 = UInt64

typealias s8 = Int8
typealias s16 = Int16
typealias s32 = Int32
typealias s64 = Int64

typealias b32 = Int32

/// Prefixes – look in the manual
struct InstructionFlag: OptionSet {
    let rawValue: Int
    
    static let lock    = InstructionFlag(rawValue: 1 << 0)  // Inst_Lock
    static let rep     = InstructionFlag(rawValue: 1 << 1)  // Inst_Rep  
    static let segment = InstructionFlag(rawValue: 1 << 2)  // Inst_Segment
    static let wide    = InstructionFlag(rawValue: 1 << 3)  // Inst_Wide
}

/// Listing of all the registers
enum RegisterIndex {
    case none

    // addressable as either 8 or 16 bit instructions
    case a, b, c, d

    // 16-bit
    case sp, bp, si,di

    // Segment registers
    case es, cs, ss, ds

    // Special registers. Useless in this version
    case ip, flags

    // this method will create a string based on access values!
    func getName(count: Int, offset: u8) -> String {
        let column = count == 2 ? 2 : Int(offset) & 1

        switch self {
        case .none:
            return ""
        case .a:
            return ["al", "ah", "ax"][column]
        case .b:
            return ["bl", "bh", "bx"][column]
        case .c:
            return ["cl", "ch", "cx"][column]
        case .d:
            return ["dl", "dh", "dx"][column]
        }
        case .sp, .bp, .si, .di, .es, .cs, .ss, .ds, .ip, .flags:
            return rawName
    }

    func getSegmentName() -> String {
    switch self {
    case .es, .cs, .ss, .ds:
        return rawName
    default:
        return ""
    }
}
    // for registers that don't vary
    private var rawName: String { 
        switch self {
        case .none: return ""
        case .a: return "ax"  // default
        case .b: return "bx"  // default
        case .c: return "cx"  // default
        case .d: return "dx"  // default
        case .sp: return "sp"
        case .bp: return "bp"
        case .si: return "si"
        case .di: return "di"
        case .es: return "es"
        case .cs: return "cs"
        case .ss: return "ss"
        case .ds: return "ds"
        case .ip: return "ip"
        case .flags: return "flags"
        }
    }
}
enum EffectiveBaseAddress: String {
    case Direct = ""  // rm == 0b10, reg == 0b110

    case bxsi = "bx+si"
    case bxdi = "bx+di"
    case bpsi = "bp+si"
    case bpdi = "bp+di"
    case si = "si"
    case di = "di"
    case bp = "bp"
    case bx = "bx"

    var expression: String {
        return rawValue
    }
}

/// mod/reg fields in the case of not referring to the register
struct EffectiveAddressExpression {
    let segment: RegisterIndex
    let base: EffectiveBaseAddress
    let displacement: s32

    func getExpression() -> String {
        return base.expression
    }
}

/// reg field 0b11
struct RegisterAccess {
    let index: RegisterIndex
    // haha
    let offset: u8
    // how many bytes to access. 1 for 8-bit and 2 for 16-bit
    let count: u8

    func getName() -> String {
        return index.getName(count: count, offset: offset)
    }
}

enum OperandType {
    case none, register, memory, immediate, relativeImmediate
}

/// Cumulative instruction
struct InstructionOperand {
    let type: OperandType

    let address: EffectiveAddressExpression
    let register: RegisterAccess
    let immediateU32: u32
    let immediateS32: s32

    init(type: OperandType) {
        self.type = type
        self.register = RegisterAccess()
        self.address = EffectiveAddress(
            segment: RegisterAccess(),
            base: RegisterAccess(),
            displacement: 0
        )
        self.immediateS32 = 0
    }
}

/// The full instruction decode
struct Instruction {
    let address: u32
    let size: u32

    let op: OperationType
    let flags: InstructionFlag 

    var operands: [InstructionOperand]
}
