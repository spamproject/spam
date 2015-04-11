// MARK: main function

func main(repository: String) {
    if contains(Process.arguments, "install") {
        install(repository)
    } else if contains(Process.arguments, "uninstall") {
        uninstall()
    } else {
        usage()
    }
}

// MARK: subcommands

func install(repository: String) {
    mkdir(".spam")
    call("git", "clone", repository, ".spam/test")
}

func uninstall() {
    call("rm", "-rf", ".spam")
}

// MARK: entry point

let path = "example.swift"
if let streamReader = StreamReader(path: path) {
    if let line = streamReader.nextLine() {
        if let repository = repo(line) {

            main(repository)

        } else {
            error("could not parse repository name")
        }
    } else {
        error("\(path) was empty")
    }
} else {
    error("could not read \(path)")
}
