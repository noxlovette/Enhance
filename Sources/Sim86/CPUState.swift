//
//  CPUState.swift
//  Enhance
//
//  Created by Danila Volkov on 25.06.2025.
//


struct CPUState {
    // 16-bit registers
    var ax: u16 = 0
    var bx: u16 = 0
    var cx: u16 = 0
    var dx: u16 = 0
    var sp: u16 = 0
    var bp: u16 = 0
    var si: u16 = 0
    var di: u16 = 0
    
    // Segment registers
    var es: u16 = 0
    var cs: u16 = 0
    var ss: u16 = 0
    var ds: u16 = 0
    
    // Instruction pointer
    var ip: u16 = 0
    
    // Flags register (simplified)
    var flags: u16 = 0
    
    init() {
        // Initialize with default values (all zeros)
    }
    
    // Get 8-bit register values
    var al: u8 { 
        get { return u8(ax & 0xFF) }
        set { ax = (ax & 0xFF00) | u16(newValue) }
    }
    
    var ah: u8 { 
        get { return u8((ax >> 8) & 0xFF) }
        set { ax = (ax & 0x00FF) | (u16(newValue) << 8) }
    }
    
    var bl: u8 { 
        get { return u8(bx & 0xFF) }
        set { bx = (bx & 0xFF00) | u16(newValue) }
    }
    
    var bh: u8 { 
        get { return u8((bx >> 8) & 0xFF) }
        set { bx = (bx & 0x00FF) | (u16(newValue) << 8) }
    }
    
    var cl: u8 { 
        get { return u8(cx & 0xFF) }
        set { cx = (cx & 0xFF00) | u16(newValue) }
    }
    
    var ch: u8 { 
        get { return u8((cx >> 8) & 0xFF) }
        set { cx = (cx & 0x00FF) | (u16(newValue) << 8) }
    }
    
    var dl: u8 { 
        get { return u8(dx & 0xFF) }
        set { dx = (dx & 0xFF00) | u16(newValue) }
    }
    
    var dh: u8 { 
        get { return u8((dx >> 8) & 0xFF) }
        set { dx = (dx & 0x00FF) | (u16(newValue) << 8) }
    }
    
    // Get/Set register values by RegisterAccess
    mutating func getValue(for register: RegisterAccess) -> u32 {
        switch register.index {
        case .a:
            return register.count == 2 ? u32(ax) : 
                   (register.offset == 0 ? u32(al) : u32(ah))
        case .b:
            return register.count == 2 ? u32(bx) : 
                   (register.offset == 0 ? u32(bl) : u32(bh))
        case .c:
            return register.count == 2 ? u32(cx) : 
                   (register.offset == 0 ? u32(cl) : u32(ch))
        case .d:
            return register.count == 2 ? u32(dx) : 
                   (register.offset == 0 ? u32(dl) : u32(dh))
        case .sp:
            return u32(sp)
        case .bp:
            return u32(bp)
        case .si:
            return u32(si)
        case .di:
            return u32(di)
        case .es:
            return u32(es)
        case .cs:
            return u32(cs)
        case .ss:
            return u32(ss)
        case .ds:
            return u32(ds)
        case .ip:
            return u32(ip)
        case .flags:
            return u32(flags)
        case .none:
            return 0
        }
    }
    
    mutating func setValue(_ value: u32, for register: RegisterAccess) {
        switch register.index {
        case .a:
            if register.count == 2 {
                ax = u16(value & 0xFFFF)
            } else if register.offset == 0 {
                al = u8(value & 0xFF)
            } else {
                ah = u8(value & 0xFF)
            }
        case .b:
            if register.count == 2 {
                bx = u16(value & 0xFFFF)
            } else if register.offset == 0 {
                bl = u8(value & 0xFF)
            } else {
                bh = u8(value & 0xFF)
            }
        case .c:
            if register.count == 2 {
                cx = u16(value & 0xFFFF)
            } else if register.offset == 0 {
                cl = u8(value & 0xFF)
            } else {
                ch = u8(value & 0xFF)
            }
        case .d:
            if register.count == 2 {
                dx = u16(value & 0xFFFF)
            } else if register.offset == 0 {
                dl = u8(value & 0xFF)
            } else {
                dh = u8(value & 0xFF)
            }
        case .sp:
            sp = u16(value & 0xFFFF)
        case .bp:
            bp = u16(value & 0xFFFF)
        case .si:
            si = u16(value & 0xFFFF)
        case .di:
            di = u16(value & 0xFFFF)
        case .es:
            es = u16(value & 0xFFFF)
        case .cs:
            cs = u16(value & 0xFFFF)
        case .ss:
            ss = u16(value & 0xFFFF)
        case .ds:
            ds = u16(value & 0xFFFF)
        case .ip:
            ip = u16(value & 0xFFFF)
        case .flags:
            flags = u16(value & 0xFFFF)
        case .none:
            break
        }
    }
    
    // Print current register state
    func printState() {
        print("      ax: 0x\(String(format: "%04x", ax)) (\(ax))")
        print("      bx: 0x\(String(format: "%04x", bx)) (\(bx))")
        print("      cx: 0x\(String(format: "%04x", cx)) (\(cx))")
        print("      dx: 0x\(String(format: "%04x", dx)) (\(dx))")
        print("      sp: 0x\(String(format: "%04x", sp)) (\(sp))")
        print("      bp: 0x\(String(format: "%04x", bp)) (\(bp))")
        print("      si: 0x\(String(format: "%04x", si)) (\(si))")
        print("      di: 0x\(String(format: "%04x", di)) (\(di))")
        print("      ip: 0x\(String(format: "%04x", ip)) (\(ip))")
        print("   flags: 0x\(String(format: "%04x", flags))")
    }
}
