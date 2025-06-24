import Foundation

let arguments = CommandLine.arguments

let memory: Memory

if arguments.count > 1 {
    for argument in arguments {
        let bytesRead: [UInt32] = loadMemory(fromFile: argument, into: &memory, atOffset: 0)

        print("Disassembly \(argument)\n")
        print("16 bits\n")
        disAsm8086(memory, bytesRead, {})
    }
} else {
    print("USAGE: [8086 machine code file]... \n")
}
