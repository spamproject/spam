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

func compile() {
    mkdir("\(spamDirectory)/build")
    call("swiftc", "-emit-library", "-emit-object",
         ".spam/aclissold/Module/Module.swift", "-module-name", "Module", "-o",
         ".spam/build/Module.o")
    call("ar", "rcs", "libmodule.a", ".spam/build/Module.o")
    call("mv", "libmodule.a", ".spam/build/")
    call("swiftc", "-emit-module", ".spam/aclissold/Module/Module.swift",
         "-module-name", "Module", "-o", ".spam/build/")
    call("swiftc", "-I", ".spam/build", "-L", ".spam/build", "-lmodule",
         "example.swift")
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
