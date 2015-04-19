import Foundation

func call(command: String) {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = split(command) { $0 == " " }

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    let output = NSString(data: data, encoding: NSUTF8StringEncoding) as! String
    print(output)

    task.waitUntilExit()
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

// Returns a space-separated list of .type files at path.
func filesOfType(type: String, atPath path: String) -> String? {
    if let contents: [String] = fileManager.contentsOfDirectoryAtPath(path, error: nil) as? [String] {
        let predicate = NSPredicate(format: "pathExtension='\(type)'")
        let filesArray = contents.filter { predicate.evaluateWithObject($0) }

        var fullPathFilesArray = [String]()
        for file in filesArray {
            fullPathFilesArray.append("\(path)/\(file)")
        }
        let files = join(" ", fullPathFilesArray)
        return files
    }

    return nil
}

func lastIndexOf(target: UnicodeScalar, inString string: String) -> Int? {
    let character = Int32(bitPattern: target.value)
    return string.withCString { cString -> Int? in
        let position = strrchr(cString, character)
        return position - cString
    }
}

func isBlank(string: String) -> Bool {
    return string.stringByTrimmingCharactersInSet(
        .whitespaceAndNewlineCharacterSet()).isEmpty
}

@noreturn func error(message: String) {
    println("error: \(message)")
    exit(1)
}
