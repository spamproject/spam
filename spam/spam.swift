import Foundation

private let fileManager = NSFileManager()
private let spamDirectory = ".spam"
private let swiftc = "xcrun -sdk macosx swiftc"

private extension Module {
    var installPath: String {
        get {
            return spamDirectory + "/src/" + username + "/" + repo
        }
    }
}

// MARK: helper functions

func findModules(path: String) -> [Module] {
    guard let streamReader = StreamReader(path: path) else {
        error("could not read \(path)")
    }
    var modules = [Module]()
    while let line = streamReader.nextLine() {
        if let module = Module(importStatement: line) {
            modules.append(module)
        }
    }
    return modules
}

func compile(modules: [Module]) -> String {
    let s = spamDirectory
    mkdir("\(s)/lib")

    var command = "\(swiftc) -I \(s)/lib -L \(s)/lib "
    for module in modules {
        let modulePath = "\(spamDirectory)/lib/\(module.moduleName).swiftmodule"
        if !fileManager.fileExistsAtPath(modulePath) {
            compile(module)
        }
        command += "-l\(module.moduleName.lowercaseString) "
    }
    guard let sourceFiles = filesOfType("swift", atPath: ".") else {
        error("could not find any Swift files in the current directory")
    }
    return "\(command)\(sourceFiles)"
}

func compile(module: Module) {
    log("Compiling \(module.moduleName)…")
    let s = spamDirectory
    let u = module.username
    let r = module.repo
    let M = module.moduleName
    let m = module.moduleName.lowercaseString

    let path = "\(s)/src/\(u)/\(r)"
    guard let sourceFiles = filesOfType("swift", atPath: "\(path)/\(r)")
        ?? filesOfType("swift", atPath: "\(path)/\(m)")
        ?? filesOfType("swift", atPath: "\(path)/Source")
        ?? filesOfType("swift", atPath: "\(path)/src")
        ?? filesOfType("swift", atPath: "\(path)") else {
            error("could not find any Swift files in \(path)")
    }
    call("\(swiftc) -emit-library -emit-object " +
         "\(sourceFiles) -module-name \(M)")
    guard let objectFiles = filesOfType("o", atPath: ".") else {
        error("could not find object files")
    }
    call("ar rcs lib\(m).a \(objectFiles)")
    call("rm \(objectFiles)")
    call("mv lib\(m).a \(s)/lib/")
    call("\(swiftc) -parse-as-library -emit-module \(sourceFiles) " +
         "-module-name \(M) -o \(s)/lib/")
}

// MARK: subcommands

func install() {
    func install(module: Module) {
        mkdir("\(spamDirectory)/src")
        call("git clone \(module.path) \(module.installPath)")
        if let version = module.version {
            call("git --git-dir=\(module.installPath)/.git " +
                 "--work-tree=\(module.installPath) checkout \(version) -q")
        }
    }

    guard let sourceFiles = filesOfType("swift", atPath: ".")  else {
        error("could not find any Swift files in the current directory")
    }
    for file in (split(sourceFiles.characters) { $0 == " " }.map(String.init)) {
        let modules = findModules(file)
        for module in modules {
            if !fileManager.fileExistsAtPath(module.installPath) {
                install(module)
            }
        }
    }
}

func uninstall() {
    log("Removing .spam/ and its contents…")
    call("rm -rf \(spamDirectory)")
}

func compile(outputFile outputFile: String?) {
    guard let sourceFiles = filesOfType("swift", atPath: ".") else {
        error("could not find any Swift files in the current directory")
    }
    var modules = [Module]()
    for file in (split(sourceFiles.characters) { $0 == " " }.map(String.init)) {
        modules += findModules(file)
    }
    let finalCompilationCommand = compile(modules)
    if let outputFile = outputFile {
        log("Compiling \(outputFile)…")
        call("\(finalCompilationCommand) -o \(outputFile)")
    } else {
        log("Compiling project…")
        call(finalCompilationCommand)
    }
}

func build(outputFile outputFile: String?) {
    install()
    compile(outputFile: outputFile)
}
