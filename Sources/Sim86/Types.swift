// MARK: Aliases
typealias u8 = UInt8
typealias u16 = UInt16
typealias u32 = UInt32
typealias u64 = UInt64

typealias s8 = Int8
typealias s16 = Int16
typealias s32 = Int32
typealias s64 = Int64

typealias b32 = Int32

// MARK: - Enums and Basic Types
enum OpCode: UInt32 {
    case none, nop
    case mov, push, pop, xchg, `in`, out, xlat, lea, lds, les, lahf, sahf, pushf, popf
    case add, adc, inc, aaa, daa, sub, sbb, dec, neg, cmp, aas, das, mul, imul, aam, div, idiv, aad,
        cbw, cwd
    case not, shl, shr, sar, rol, ror, rcl, rcr
    case and, test, or, xor
    case rep, movs, cmps, scas, lods, stos
    case call, jmp, ret
    case je, jl, jle, jb, jbe, jp, jo, js, jne, jnl, jg, jnb, ja, jnp, jno, jns
    case loop, loopz, loopnz, jcxz
    case int, int3, into, iret
    case clc, cmc, stc, cld, std, cli, sti, hlt, wait, esc, lock, segment
    var mnemonic: String {
        switch self {
        case .none: return ""
        case .nop: return "nop"
        case .mov: return "mov"
        case .push: return "push"
        case .pop: return "pop"
        case .xchg: return "xchg"
        case .`in`: return "in"
        case .out: return "out"
        case .xlat: return "xlat"
        case .lea: return "lea"
        case .lds: return "lds"
        case .les: return "les"
        case .lahf: return "lahf"
        case .sahf: return "sahf"
        case .pushf: return "pushf"
        case .popf: return "popf"
        case .add: return "add"
        case .adc: return "adc"
        case .inc: return "inc"
        case .aaa: return "aaa"
        case .daa: return "daa"
        case .sub: return "sub"
        case .sbb: return "sbb"
        case .dec: return "dec"
        case .neg: return "neg"
        case .cmp: return "cmp"
        case .aas: return "aas"
        case .das: return "das"
        case .mul: return "mul"
        case .imul: return "imul"
        case .aam: return "aam"
        case .div: return "div"
        case .idiv: return "idiv"
        case .aad: return "aad"
        case .cbw: return "cbw"
        case .cwd: return "cwd"
        case .not: return "not"
        case .shl: return "shl"
        case .shr: return "shr"
        case .sar: return "sar"
        case .rol: return "rol"
        case .ror: return "ror"
        case .rcl: return "rcl"
        case .rcr: return "rcr"
        case .and: return "and"
        case .test: return "test"
        case .or: return "or"
        case .xor: return "xor"
        case .rep: return "rep"
        case .movs: return "movs"
        case .cmps: return "cmps"
        case .scas: return "scas"
        case .lods: return "lods"
        case .stos: return "stos"
        case .call: return "call"
        case .jmp: return "jmp"
        case .ret: return "ret"
        case .je: return "je"
        case .jl: return "jl"
        case .jle: return "jle"
        case .jb: return "jb"
        case .jbe: return "jbe"
        case .jp: return "jp"
        case .jo: return "jo"
        case .js: return "js"
        case .jne: return "jne"
        case .jnl: return "jnl"
        case .jg: return "jg"
        case .jnb: return "jnb"
        case .ja: return "ja"
        case .jnp: return "jnp"
        case .jno: return "jno"
        case .jns: return "jns"
        case .loop: return "loop"
        case .loopz: return "loopz"
        case .loopnz: return "loopnz"
        case .jcxz: return "jcxz"
        case .int: return "int"
        case .int3: return "int3"
        case .into: return "into"
        case .iret: return "iret"
        case .clc: return "clc"
        case .cmc: return "cmc"
        case .stc: return "stc"
        case .cld: return "cld"
        case .std: return "std"
        case .cli: return "cli"
        case .sti: return "sti"
        case .hlt: return "hlt"
        case .wait: return "wait"
        case .esc: return "esc"
        case .lock: return "lock"
        case .segment: return "segment"
        }
    }
}

// MARK: Memory
enum BitsUsage: UInt32 {
    case literal = 0
    case d, s, w, v, z, data, rm, mod, reg, sr
    case hasDisp, dispAlwaysW, hasData, wMakesDataW, relJMPDisp, rmRegAlwaysW
    case disp
    case count  // Used for array sizing
}

enum EffectiveAddressBase: UInt32 {
    case direct = 0
    case bxSi, bxDi, bpSi, bpDi, si, di, bp, bx

    var expression: String {
        switch self {
        case .direct:
            return ""
        case .bxSi:
            return "BX + SI"
        case .bxDi:
            return "BX + DI"
        case .bpSi:
            return "BP + SI"
        case .bpDi:
            return "BP + DI"
        case .si:
            return "SI"
        case .di:
            return "DI"
        case .bp:
            return "BP"
        case .bx:
            return "BX"
        }
    }
}

// MARK: Registers
/// Listing of all the registers
enum RegisterIndex {
    case none

    // addressable as either 8 or 16 bit instructions
    case a, b, c, d

    // 16-bit
    case sp, bp, si, di

    // Segment registers
    case es, cs, ss, ds

    // Special registers
    case ip, flags

    // this method will create a string based on access values!
    func getName(count: u8, offset: u8) -> String {
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

        case .sp, .bp, .si, .di, .es, .cs, .ss, .ds, .ip, .flags:
            return rawName
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

enum OperandType {
    case none, register, memory, immediate, relativeImmediate
}

// MARK: - Structs
struct InstructionBits {
    let usage: BitsUsage
    let bitCount: UInt8
    let shift: UInt8
    let value: UInt32

    init(usage: BitsUsage, bitCount: UInt8, shift: UInt8 = 0, value: UInt32 = 0) {
        self.usage = usage
        self.bitCount = bitCount
        self.shift = shift
        self.value = value
    }

    // Helper constructors matching the original macros
    static func literal(_ bits: UInt32, bitCount: UInt8) -> InstructionBits {
        return InstructionBits(usage: .literal, bitCount: bitCount, value: bits)
    }

    static let d = InstructionBits(usage: .d, bitCount: 1)
    static let s = InstructionBits(usage: .s, bitCount: 1)
    static let w = InstructionBits(usage: .w, bitCount: 1)
    static let v = InstructionBits(usage: .v, bitCount: 1)
    static let z = InstructionBits(usage: .z, bitCount: 1)

    static let xxx = InstructionBits(usage: .data, bitCount: 3, shift: 0)
    static let yyy = InstructionBits(usage: .data, bitCount: 3, shift: 3)
    static let rm = InstructionBits(usage: .rm, bitCount: 3)
    static let mod = InstructionBits(usage: .mod, bitCount: 2)
    static let reg = InstructionBits(usage: .reg, bitCount: 3)
    static let sr = InstructionBits(usage: .sr, bitCount: 2)

    static func impW(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .w, bitCount: 0, value: value)
    }

    static func impREG(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .reg, bitCount: 0, value: value)
    }

    static func impMOD(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .mod, bitCount: 0, value: value)
    }

    static func impRM(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .rm, bitCount: 0, value: value)
    }

    static func impD(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .d, bitCount: 0, value: value)
    }

    static func impS(_ value: UInt32) -> InstructionBits {
        return InstructionBits(usage: .s, bitCount: 0, value: value)
    }

    static let disp = InstructionBits(usage: .hasDisp, bitCount: 0, value: 1)
    static let addr = [
        InstructionBits(usage: .hasDisp, bitCount: 0, value: 1),
        InstructionBits(usage: .dispAlwaysW, bitCount: 0, value: 1),
    ]
    static let data = InstructionBits(usage: .hasData, bitCount: 0, value: 1)
    static let dataIfW = InstructionBits(usage: .wMakesDataW, bitCount: 0, value: 1)

    static func flags(_ flag: BitsUsage) -> InstructionBits {
        return InstructionBits(usage: flag, bitCount: 0, value: 1)
    }
}

struct MemoryAddress {
    var segment: RegisterIndex
    var base: EffectiveAddressBase
    var displacement: Int16

    init(
        segment: RegisterIndex = .ds, base: EffectiveAddressBase = .direct, displacement: Int16 = 0
    ) {
        self.segment = segment
        self.base = base
        self.displacement = displacement
    }
}

struct InstructionFormat {
    let op: OpCode
    let bits: [InstructionBits]

    init(_ op: OpCode, _ bits: [InstructionBits]) {
        self.op = op
        self.bits = bits
    }
}

/// Disassembly context with proper methods
struct DisasmContext {
    var additionalFlags: InstructionFlag = []
    var defaultSegment: RegisterIndex = .ds
    
    // Initialize with default values
    init() {
        self.additionalFlags = []
        self.defaultSegment = .ds
    }
    
    // Update context based on instruction
    mutating func update(with instruction: Instruction) {
        switch instruction.op {
        case .lock:
            // Lock prefix - affects the next instruction
            additionalFlags.insert(.lock)
            
        case .rep:
            // Repeat prefix - affects string instructions
            additionalFlags.insert(.rep)
            
        case .segment:
            // Segment override prefix - changes default segment for memory access
            additionalFlags.insert(.segment)
            // The segment register should be in operands[1] based on the C code
            if instruction.operands.count > 1 {
                defaultSegment = instruction.operands[1].register.index
            }
            
        default:
            // For any actual instruction (not a prefix), clear the context
            // The prefixes have been "consumed" by this instruction
            reset()
        }
    }
    
    // Apply accumulated flags to an instruction
    func applyFlags(to instruction: inout Instruction) {
        instruction.flags.formUnion(additionalFlags)
        
        // Apply segment override if needed
        if additionalFlags.contains(.segment) {
            // Apply default segment to memory operands
            for i in 0..<instruction.operands.count {
                if instruction.operands[i].type == .memory {
                    instruction.operands[i].address.segment = defaultSegment
                }
            }
        }
    }
    
    // Reset context to defaults
    private mutating func reset() {
        additionalFlags = []
        defaultSegment = .ds
    }
    
    // Check if context has pending flags
    var hasPendingFlags: Bool {
        return !additionalFlags.isEmpty
    }
}

/// Prefixes – look in the manual
struct InstructionFlag: OptionSet {
    let rawValue: u32

    static let lock = InstructionFlag(rawValue: 1 << 0)  // Inst_Lock
    static let rep = InstructionFlag(rawValue: 1 << 1)  // Inst_Rep
    static let segment = InstructionFlag(rawValue: 1 << 2)  // Inst_Segment
    static let wide = InstructionFlag(rawValue: 1 << 3)  // Inst_Wide
}

/// mod/reg fields in the case of not referring to the register
struct EffectiveAddressExpression {
    var segment: RegisterIndex
    var base: EffectiveAddressBase
    var displacement: s32

    func getExpression() -> String {
        return base.expression
    }
    
    init() {
        self.segment = .none
        self.base = .direct
        self.displacement = 0
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

    init() {
        self.index = .none
        self.offset = 0
        self.count = 0
    }
    
    init(index: RegisterIndex, offset: u8, count: u8) {
        self.index = index
        self.count = count
        self.offset = offset
    }
}

/// Cumulative instruction
struct InstructionOperand {
    var type: OperandType

    var address: EffectiveAddressExpression
    var register: RegisterAccess
    var immediateU32: u32
    var immediateS32: s32

    init(type: OperandType) {
        self.type = type
        self.register = RegisterAccess()
        self.address = EffectiveAddressExpression()
        self.immediateS32 = 0
        self.immediateU32 = 0
    }
}

/// The full instruction decode
struct Instruction {
    var address: u32
    var size: u32

    var op: OpCode
    var flags: InstructionFlag

    var operands: [InstructionOperand]
    
    init() {
        self.address = 0
        self.size = 0
        self.op = .none
        self.flags = []
        self.operands = []
    }
    
    var isPrintable: Bool {
        switch self.op {
        case .lock, .rep, .segment:
            return false
        default:
            return true
        }
    }
}
