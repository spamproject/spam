import Foundation

let spamDirectory = ".spam"
let swiftc = "xcrun -sdk macosx swiftc"

private extension Module {
    var installPath: String {
        get {
            return spamDirectory + "/src/" + username + "/" + moduleName
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
    let M = module.moduleName // Module
    let m = module.moduleName.lowercaseString // module
    let u = module.username
    let s = spamDirectory

    let path = "\(s)/src/\(u)/\(M)/\(M)"
    if let sourceFiles = filesOfType("swift", atPath: path) {
        call("\(swiftc) -emit-library -emit-object " +
             "\(sourceFiles) -module-name \(M)")
        if let objectFiles = filesOfType("o", atPath: ".") {
            call("ar rcs lib\(m).a \(objectFiles)")
            call("rm \(objectFiles)")
            call("mv lib\(m).a \(s)/lib/")
            call("\(swiftc) -emit-module \(sourceFiles) " +
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

func compile() {
    if let sourceFiles = filesOfType("swift", atPath: ".") {
        var modules = [Module]()
        for file in split(sourceFiles, isSeparator: { $0 == " " }) {
            modules += findModules(file)
        }
        if count(modules) > 0 {
            let finalCompilationCommand = compile(modules)
            println(finalCompilationCommand)
            call(finalCompilationCommand)
        } else {
            error("could not find any installable modules")
        }
    } else {
        error("could not find any Swift files in the current directory")
    }
}

func usage() {
    println("usage: spam [install|uninstall|compile]")
    println("")
    println("Specify a package with \"import Module // username/module\".")
}

// MARK: entry point

if contains(Process.arguments, "install") || contains(Process.arguments, "i") {
    install()
} else if contains(Process.arguments, "uninstall") || contains(Process.arguments, "u") {
    uninstall()
} else if contains(Process.arguments, "compile") || contains(Process.arguments, "c") {
    compile()
} else {
    usage()
}
