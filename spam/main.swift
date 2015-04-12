// MARK: subcommands

func install() {
    func install(repository: String) {
        mkdir(".spam")
        call("git", "clone", repository, ".spam/test")
    }

    let path = "example.swift"
    if let streamReader = StreamReader(path: path) {
        var line: String?
        while let line = streamReader.nextLine() {
            if let repository = repo(line) {
                install(repository)
            }
        }
    } else {
        error("could not read \(path)")
    }
}

func uninstall() {
    call("rm", "-rf", ".spam")
}

// MARK: entry point

if contains(Process.arguments, "install") {
    install()
} else if contains(Process.arguments, "uninstall") {
    uninstall()
} else {
    usage()
}
