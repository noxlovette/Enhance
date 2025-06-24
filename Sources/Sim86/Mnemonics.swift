/// Mnemonics. Based on Intel 8086 instruction table
enum OperationType: UInt8, CaseIterable {
    // Data Transfer Instructions
    case none
    case mov
    case push
    case pop
    case xchg
    case `in`
    case out
    case xlat
    case lea
    case lds
    case les
    case lahf
    case sahf
    case pushf
    case popf

    // Arithmetic Instructions
    case add
    case adc
    case inc
    case aaa
    case daa
    case sub
    case sbb
    case dec
    case neg
    case cmp
    case aas
    case das
    case mul
    case imul
    case aam
    case div
    case idiv
    case aad
    case cbw
    case cwd

    // Logic Instructions
    case not
    case shl
    case shr
    case sar
    case rol
    case ror
    case rcl
    case rcr
    case and
    case test
    case or
    case xor

    // String Instructions
    case rep
    case movs
    case cmps
    case scas
    case lods
    case stos

    // Control Transfer Instructions
    case call
    case jmp
    case ret

    // Conditional Jump Instructions
    case je
    case jl
    case jle
    case jb
    case jbe
    case jp
    case jo
    case js
    case jne
    case jnl
    case jg
    case jnb
    case ja
    case jnp
    case jno
    case jns
    case loop
    case loopz
    case loopnz
    case jcxz

    // Interrupt Instructions
    case int
    case int3
    case into
    case iret

    // Processor Control Instructions
    case clc
    case cmc
    case stc
    case cld
    case std
    case cli
    case sti
    case hlt
    case wait
    case esc
    case lock
    case segment

    // Special case for NOP (which is actually XCHG AX, AX)
    case nop

    /// Returns the mnemonic string
    var mnemonic: String {
        switch self {
        case .none: return ""
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
        case .nop: return "nop"
        }
    }

    /// Returns the primary opcode byte
    var opcode: UInt8 {
        return rawValue
    }

    /// Create an instance from opcode
    static func from(opcode: UInt8) -> OperationType? {
        return OperationType(rawValue: opcode)
    }

    /// Returns the instruction category
    var category: InstructionCategory {
        switch self {
        case .none, .nop:
            return .misc
        case .mov, .push, .pop, .xchg, .`in`, .out, .xlat, .lea, .lds, .les, .lahf, .sahf, .pushf,
            .popf:
            return .dataTransfer
        case .add, .adc, .inc, .aaa, .daa, .sub, .sbb, .dec, .neg, .cmp, .aas, .das, .mul, .imul,
            .aam, .div, .idiv, .aad, .cbw, .cwd:
            return .arithmetic
        case .not, .shl, .shr, .sar, .rol, .ror, .rcl, .rcr, .and, .test, .or, .xor:
            return .logic
        case .rep, .movs, .cmps, .scas, .lods, .stos:
            return .string
        case .call, .jmp, .ret, .je, .jl, .jle, .jb, .jbe, .jp, .jo, .js, .jne, .jnl, .jg, .jnb,
            .ja, .jnp, .jno, .jns, .loop, .loopz, .loopnz, .jcxz:
            return .controlTransfer
        case .int, .int3, .into, .iret:
            return .interrupt
        case .clc, .cmc, .stc, .cld, .std, .cli, .sti, .hlt, .wait, .esc, .lock, .segment:
            return .processorControl
        }
    }
}

/// Instruction categories for better organization
enum InstructionCategory {
    case dataTransfer
    case arithmetic
    case logic
    case string
    case controlTransfer
    case interrupt
    case processorControl
    case misc
}
