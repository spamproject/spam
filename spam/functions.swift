import Foundation

@inline(never) func log<T>(value: T, level: Int = 1) {
    if verboseOption.value == level {
        print(value)
    }
}

func call(command: String) {
    log(command, level: 2)

    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = split(command.characters) { $0 == " " }.map(String.init)

    let pipe = NSPipe()
    task.standardOutput = pipe
    task.launch()

    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    guard let output = NSString(data: data, encoding: NSUTF8StringEncoding) as? String else {
        error("could not get output of \(command)")
    }
    print(output, appendNewline: false)

    task.waitUntilExit()
    if task.terminationStatus != 0 {
        exit(task.terminationStatus)
    }
}

private let fileManager = NSFileManager()
func mkdir(path: String, withIntermediateDirectories: Bool = true) {
    log("mkdir -p \(path)", level: 2)

    do {
        try fileManager.createDirectoryAtPath(
            path,
            withIntermediateDirectories: withIntermediateDirectories,
            attributes: nil)
    } catch {
        print(error)
        exit(1)
    }
}

// Returns a space-separated list of .type files at path.
func filesOfType(type: String, atPath path: String) -> String? {
    let contents: [String]
    do {
        contents = try fileManager.contentsOfDirectoryAtPath(path)
    } catch {
        return nil
    }
    let predicate = NSPredicate(format: "pathExtension='\(type)'")
    let filesArray = contents.filter { predicate.evaluateWithObject($0) }

    var fullPathFilesArray = [String]()
    for file in filesArray {
        fullPathFilesArray.append("\(path)/\(file)")
    }
    let files = " ".join(fullPathFilesArray)
    return files
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
    print("error: \(message)")
    exit(1)
}
