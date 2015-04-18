class Repo {
    let username: String
    let reponame: String
    var path: String {
        get {
            return "https://github.com/\(username)/\(reponame).git"
        }
    }

    init(username: String, reponame: String) {
        self.username = username
        self.reponame = reponame
    }

    convenience init?(importStatement: String) {
        if importStatement.rangeOfString("^import",
        options: .RegularExpressionSearch) != nil,
        let nameRange = importStatement.rangeOfString("[^\\s/]+/[^\\s/]+$",
        options: .RegularExpressionSearch) {
            let name = importStatement.substringWithRange(nameRange)
            let components = name.componentsSeparatedByString("/")
            if components.count == 2 {
                self.init(username: components[0], reponame: components[1])
                return
            }
        }

        self.init(username: "", reponame: "")
        return nil
    }
}
