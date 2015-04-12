import Foundation

func call(args: String...) {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    print(output)

    if task.terminationStatus != 0 {
        exit(task.terminationStatus)
    }
}

private let fileManager = NSFileManager()
func mkdir(path: String, withIntermediateDirectories: Bool = true) {
    var error: NSError?
    fileManager.createDirectoryAtPath(
        path,
        withIntermediateDirectories: withIntermediateDirectories,
        attributes: nil,
        error: &error)
    if error != nil {
        println(error)
        exit(1)
    }
}

func lastIndexOf(target: UnicodeScalar, inString string: String) -> Int? {
    let character = Int32(bitPattern: target.value)
    return string.withCString { cString -> Int? in
        let position = strrchr(cString, character)
        return position - cString
    }
}

// Attempt to parse a GitHub repository from a commented import statement.
func repo(importStatement: String) -> String? {
    if let nameRange = importStatement.rangeOfString("[^\\s/]+/[^\\s/]+$",
        options: .RegularExpressionSearch) {
            let name = importStatement.substringWithRange(nameRange)
            return "https://github.com/\(name).git"
    } else {
        return nil
    }
}

func isBlank(string: String) -> Bool {
    return string.stringByTrimmingCharactersInSet(
        .whitespaceAndNewlineCharacterSet()).isEmpty
}

func error(message: String) {
    println("error: \(message)")
    exit(1)
}

func usage() {
    println("usage: spam [install|uninstall]")
    println("")
    println("Specify a package with \"import Module // username/repo\".")
}
