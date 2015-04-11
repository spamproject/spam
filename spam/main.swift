import Foundation

let fileManager = NSFileManager.defaultManager()

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
