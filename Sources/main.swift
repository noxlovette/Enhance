import Foundation

@main
struct App {
    static func main() {
        var memory = Memory()  // Make sure Memory has an initializer
        let arguments = CommandLine.arguments
        var shouldExecute = false
        var filesToProceed = [String]()

        for i in 1..<arguments.count {
            if arguments[i] == "-exec" {
                shouldExecute = true
            } else {
                filesToProceed.append(arguments[i])
            }
        }
        
        if filesToProceed.isEmpty {
            print("USAGE: [8086 machine code file]... [-exec]")
            print("  -exec: Enable execution simulation with register state tracking")
            return
        }
        
        for fileName in filesToProceed {
                let bytesRead: u32 = loadMemory(fromFile: fileName, into: &memory, atOffset: 0)
                
                print("Disassembly \(fileName)\n")
            
            if shouldExecute {
                print("Executioner enabled")
            }
            
                print("16 bits\n")
            if !shouldExecute {
                disAsm8086(memory: memory, disAsmByteCount: bytesRead)
            } else {
                executeWithSimulation(memory: memory, disAsmByteCount: bytesRead)
            }
        }
        
    }
}
