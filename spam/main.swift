// MARK: subcommands

let spamDirectory = ".spam"

func install() {
    func install(repo: Repo) {
        mkdir(spamDirectory)
        let dest = spamDirectory + "/" + repo.username + "/" + repo.reponame
        call("git", "clone", repo.path, dest)
    }

    let path = "example.swift"
    if let streamReader = StreamReader(path: path) {
        var line: String?
        while let line = streamReader.nextLine() {
            if let repo = Repo(importStatement: line) {
                install(repo)
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
