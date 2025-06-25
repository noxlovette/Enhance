import Foundation

@main
struct App {
    static func main() {
        var memory = Memory()  // Make sure Memory has an initializer
        let arguments = CommandLine.arguments

        if arguments.count > 1 {
            for argument in arguments.dropFirst() { // Drop the executable path
                let bytesRead: u32 = loadMemory(fromFile: argument, into: &memory, atOffset: 0)

                print("Disassembly \(argument)\n")
                print("16 bits\n")
                disAsm8086(memory: memory, disAsmByteCount: bytesRead)
            }
        } else {
            print("USAGE: [8086 machine code file]... \n")
        }
    }
}
