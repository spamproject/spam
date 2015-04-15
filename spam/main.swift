import Foundation

let spamDirectory = ".spam"

private extension Repo {
    var installPath: String {
        get {
            return spamDirectory + "/" + username + "/" + reponame
        }
    }
}

// MARK: subcommands

func install() {
    let fileManager = NSFileManager()

    func install(repo: Repo) {
        mkdir(spamDirectory)
        call("git", "clone", repo.path, repo.installPath)
    }

    let path = "example.swift"
    if let streamReader = StreamReader(path: path) {
        var line: String?
        while let line = streamReader.nextLine() {
            if let repo = Repo(importStatement: line) {
                if !fileManager.fileExistsAtPath(repo.installPath) {
                    install(repo)
                }
            }
        }
    } else {
        error("could not read \(path)")
    }
}

func uninstall() {
    call("rm", "-rf", spamDirectory)
}

func compile(moduleName: String) {
    let M = moduleName
    let m = moduleName.lowercaseString
    let s = spamDirectory

    mkdir("\(s)/build")
    mkdir("\(s)/lib")

    call("swiftc", "-emit-library", "-emit-object",
         "\(s)/aclissold/\(M)/\(M).swift", "-module-name", M, "-o",
         "\(s)/build/\(M).o")
    call("ar", "rcs", "lib\(m).a", "\(s)/build/\(M).o")
    call("mv", "lib\(m).a", "\(s)/lib/")
    call("swiftc", "-emit-module", "\(s)/aclissold/\(M)/\(M).swift",
         "-module-name", "\(M)", "-o", "\(s)/lib/")
    call("swiftc", "-I", "\(s)/lib", "-L", "\(s)/lib", "-l\(m)",
         "example.swift")
}

// MARK: entry point

if contains(Process.arguments, "install") || contains(Process.arguments, "i") {
    install()
} else if contains(Process.arguments, "uninstall") || contains(Process.arguments, "u") {
    uninstall()
} else if contains(Process.arguments, "compile") || contains(Process.arguments, "c") {
    compile("Module")
} else {
    usage()
}
