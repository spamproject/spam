import Foundation

class Module {
    let username: String
    let repo: String
    var version: String?
    var moduleName: String {
        get {
            return repo.stringByReplacingOccurrencesOfString(".swift",
                withString: "", options: .LiteralSearch, range: nil)
        }
    }
    var path: String {
        get {
            return "https://github.com/\(username)/\(repo).git"
        }
    }

    init(username: String, repo: String, version: String? = nil) {
        self.username = username
        self.repo = repo
        self.version = version
    }

    convenience init?(importStatement: String) {
        if importStatement.rangeOfString("^import",
        options: .RegularExpressionSearch) != nil,
        let nameRange = importStatement.rangeOfString("[^\\s/]+/[^\\s/]+$",
        options: .RegularExpressionSearch) {
            let name = importStatement.substringWithRange(nameRange)
            let components = name.componentsSeparatedByCharactersInSet(
                NSCharacterSet(charactersInString:":/")) // 😕

            if components.count == 2 {
                self.init(username: components[0], repo: components[1])
                return
            } else if components.count == 3 {
                self.init(username: components[0],
                    repo: components[1],
                    version: components[2])
                return
            }
        }

        self.init(username: "", repo: "")
        return nil
    }
}
