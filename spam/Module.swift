class Module {
    let username: String
    let moduleName: String
    var path: String {
        get {
            return "https://github.com/\(username)/\(moduleName).git"
        }
    }

    init(username: String, moduleName: String) {
        self.username = username
        self.moduleName = moduleName
    }

    convenience init?(importStatement: String) {
        if importStatement.rangeOfString("^import",
        options: .RegularExpressionSearch) != nil,
        let nameRange = importStatement.rangeOfString("[^\\s/]+/[^\\s/]+$",
        options: .RegularExpressionSearch) {
            let name = importStatement.substringWithRange(nameRange)
            let components = name.componentsSeparatedByString("/")
            if components.count == 2 {
                self.init(username: components[0], moduleName: components[1])
                return
            }
        }

        self.init(username: "", moduleName: "")
        return nil
    }
}
