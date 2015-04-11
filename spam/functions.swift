import Foundation

// Call a shell command.
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

// mkdir -p
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

// Parse a GitHub repository from a commented import statement.
func repo(importStatement: String) -> String? {
    if let spaceIndex = lastIndexOf(" ", inString: importStatement) {
        let length = count(importStatement)
        let start = advance(importStatement.startIndex, spaceIndex + 1)
        let end = importStatement.endIndex
        let nameRange = Range<String.Index>(start: start, end: end)
        let name = importStatement.substringWithRange(nameRange)
        return "https://github.com/\(name).git"
    }

    return nil
}
