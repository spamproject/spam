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

// MARK: entry point

if contains(Process.arguments, "install") {
    install()
} else if contains(Process.arguments, "uninstall") {
    uninstall()
} else {
    usage()
}
