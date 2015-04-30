class Module {
    let username: String
    let repo: String
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

    init(username: String, repo: String) {
        self.username = username
        self.repo = repo
    }

    convenience init?(importStatement: String) {
        if importStatement.rangeOfString("^import",
        options: .RegularExpressionSearch) != nil,
        let nameRange = importStatement.rangeOfString("[^\\s/]+/[^\\s/]+$",
        options: .RegularExpressionSearch) {
            let name = importStatement.substringWithRange(nameRange)
            let components = name.componentsSeparatedByString("/")
            if components.count == 2 {
                self.init(username: components[0], repo: components[1])
                return
            }
        }

        self.init(username: "", repo: "")
        return nil
    }
}
