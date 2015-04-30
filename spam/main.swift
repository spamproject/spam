import Foundation

import CommandLine // jatoben/CommandLine

let spamDirectory = ".spam"
let swiftc = "xcrun -sdk macosx swiftc"

private extension Module {
    var installPath: String {
        get {
            return spamDirectory + "/src/" + username + "/" + repo
        }
    }
}

// MARK: helper functions

func findModules(path: String) -> [Module] {
    var modules = [Module]()
    if let streamReader = StreamReader(path: path) {
        var line: String?
        while let line = streamReader.nextLine() {
            if let module = Module(importStatement: line) {
                modules.append(module)
            }
        }
    } else {
        error("could not read \(path)")
    }
    return modules
}

func compile(modules: [Module]) -> String {
    let s = spamDirectory
    mkdir("\(s)/lib")

    var command = "\(swiftc) -I \(s)/lib -L \(s)/lib "
    for module in modules {
        compile(module)
        command += "-l\(module.moduleName.lowercaseString) "
    }
    if let sourceFiles = filesOfType("swift", atPath: ".") {
        return "\(command) \(sourceFiles)"
    } else {
        error("could not find any Swift files in the current directory")
    }
}

func compile(module: Module) {
    let s = spamDirectory
    let u = module.username
    let r = module.repo
    let M = module.moduleName // Module
    let m = module.moduleName // module

    let path = "\(s)/src/\(u)/\(r)"
    var sourceFiles = filesOfType("swift", atPath: "\(path)/\(r)")
    ?? filesOfType("swift", atPath: "\(path)/\(m)")
    ?? filesOfType("swift", atPath: "\(path)/Source")
    ?? filesOfType("swift", atPath: "\(path)/src")
    if sourceFiles != nil {
        call("\(swiftc) -emit-library -emit-object " +
             "\(sourceFiles!) -module-name \(M)")
        if let objectFiles = filesOfType("o", atPath: ".") {
            call("ar rcs lib\(m).a \(objectFiles)")
            call("rm \(objectFiles)")
            call("mv lib\(m).a \(s)/lib/")
            call("\(swiftc) -emit-module \(sourceFiles!) " +
                 "-module-name \(M) -o \(s)/lib/")
        } else {
            error("could not find object files")
        }
    } else {
        error("could not find any Swift files in \(path)")
    }
}

// MARK: subcommands

func install() {
    let fileManager = NSFileManager()

    func install(module: Module) {
        mkdir("\(spamDirectory)/src")
        call("git clone \(module.path) \(module.installPath)")
    }

    if let sourceFiles = filesOfType("swift", atPath: ".") {
        for file in split(sourceFiles, isSeparator: { $0 == " " }) {
            let modules = findModules(file)
            for module in modules {
                if !fileManager.fileExistsAtPath(module.installPath) {
                    install(module)
                }
            }
        }
    } else {
        error("could not find any Swift files in the current directory")
    }
}

func uninstall() {
    call("rm -rf \(spamDirectory)")
}

func compile(#outputFile: String?) {
    if let sourceFiles = filesOfType("swift", atPath: ".") {
        var modules = [Module]()
        for file in split(sourceFiles, isSeparator: { $0 == " " }) {
            modules += findModules(file)
        }
        if count(modules) > 0 {
            let finalCompilationCommand = compile(modules)
            if outputFile != nil {
                call("\(finalCompilationCommand) -o \(outputFile!)")
            } else {
                call(finalCompilationCommand)
            }
        } else {
            error("could not find any installable modules")
        }
    } else {
        error("could not find any Swift files in the current directory")
    }
}

// MARK: entry point

let cli = CommandLine()
let installOption = BoolOption(shortFlag: "i", longFlag: "install", helpMessage:
          "Download all imported modules. For spam to detect the module's URL, it must be\n" +
    "      specified in the following manner:\n" +
    "          import ModuleName // username/ModuleName\n" +
    "      This will automatically clone the module from github.com/username/ModuleName.")
let compileOption = BoolOption(shortFlag: "c", longFlag: "compile",
    helpMessage: "Compile downloaded modules and local sources.")
let outputOption = StringOption(shortFlag: "o", longFlag: "output", required: false,
    helpMessage: "Write output to <file>.")
let uninstallOption = BoolOption(shortFlag: "u", longFlag: "uninstall",
    helpMessage: "Completely remove the .spam directory.")
let helpOption = BoolOption(shortFlag: "h", longFlag: "help",
    helpMessage: "Display this help message and exit.")
cli.addOptions(installOption, compileOption, outputOption, uninstallOption, helpOption)

let (success, error) = cli.parse()
if (!success) {
    println(error!)
    cli.printUsage()
    exit(EX_USAGE)
}

if installOption.value {
    install()
} else if uninstallOption.value {
    uninstall()
} else if compileOption.value {
    compile(outputFile: outputOption.value)
} else {
    cli.printUsage()
    exit(EX_USAGE)
}
