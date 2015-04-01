public enum AppleType {
    case RedDelicious, GrannySmith
}

public class Apple {
    public var type: AppleType
    public var isEaten = false

    public init(type: AppleType) {
        self.type = type
    }

    public func eat() {
        if !isEaten {
            isEaten = true
        } else {
            println("cannot eat eaten apple")
        }
    }
}
