import Foundation

let fileManager = NSFileManager.defaultManager()

// call a shell command
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

mkdir(".spam")
let path = "example.swift"
if let streamReader = StreamReader(path: path) {
    if let line = streamReader.nextLine() {
        println(line)
    }
} else {
    println("fatal: could not read \(path)")
    exit(1)
}
