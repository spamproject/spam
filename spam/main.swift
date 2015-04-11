let path = "example.swift"
if let streamReader = StreamReader(path: path) {
    if let line = streamReader.nextLine() {
        if let repository = repo(line) {
            mkdir(".spam")
            if (contains(Process.arguments, "install")) {
                call("git", "clone", repository, ".spam/test")
            } else if (contains(Process.arguments, "uninstall")) {
                call("rm", "-rf", ".spam")
            } else {
                usage()
            }
        } else {
            error("could not parse repository name")
        }
    } else {
        error("\(path) was empty")
    }
} else {
    error("could not read \(path)")
}
