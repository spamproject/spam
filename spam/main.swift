import Foundation

let spamDirectory = ".spam"
let swiftc = "xcrun -sdk macosx swiftc"

private extension Repo {
    var installPath: String {
        get {
            return spamDirectory + "/src/" + username + "/" + reponame
        }
    }
}

func findRepos(path: String) -> [Repo]? {
    var repos: [Repo]?
    if let streamReader = StreamReader(path: path) {
        var line: String?
        while let line = streamReader.nextLine() {
            if let repo = Repo(importStatement: line) {
                if repos == nil { repos = [Repo]() }
                repos!.append(repo)
            }
        }
    } else {
        error("could not read \(path)")
    }
    return repos
}

// MARK: subcommands

func install() {
    let fileManager = NSFileManager()

    func install(repo: Repo) {
        mkdir("\(spamDirectory)/src")
        call("git clone \(repo.path) \(repo.installPath)")
    }

    let path = "example.swift"
    if let repos = findRepos(path) {
        for repo in repos {
            if !fileManager.fileExistsAtPath(repo.installPath) {
                install(repo)
            }
        }
    } else {
        error("could not find any installable modules")
    }
}

func uninstall() {
    call("rm -rf \(spamDirectory)")
}

func compile(repos: [Repo]) {
    let s = spamDirectory
    mkdir("\(s)/lib")

    var command = "\(swiftc) -I \(s)/lib -L \(s)/lib "
    for repo in repos {
        compile(repo)
        command += "-l\(repo.reponame.lowercaseString) "
    }

    if let sourceFiles = filesOfType("swift", atPath: ".") {
        call("\(command) \(sourceFiles)")
    } else {
        error("could not find any Swift files in the current directory")
    }
}

func compile(repo: Repo) {
    let M = repo.reponame // Module
    let m = repo.reponame.lowercaseString // module
    let u = repo.username
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

func usage() {
    println("usage: spam [install|uninstall|compile]")
    println("")
    println("Specify a package with \"import Module // username/repo\".")
}

// MARK: entry point

if contains(Process.arguments, "install") || contains(Process.arguments, "i") {
    install()
} else if contains(Process.arguments, "uninstall") || contains(Process.arguments, "u") {
    uninstall()
} else if contains(Process.arguments, "compile") || contains(Process.arguments, "c") {
    if let repos = findRepos("example.swift") {
        compile(repos)
    } else {
        error("could not find any installable modules")
    }
} else {
    usage()
}
