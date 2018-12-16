import Foundation

struct SwiftDemangler {
    var text = "Hello, World!"
}

internal func isSwiftSymbol(_ name: String) -> Bool {
    return name.hasPrefix("$S")
}

internal func isFunctionEntitySpec(_ name: String) -> Bool {
    return name.hasSuffix("F")
}

internal struct Symbol: Hashable {
    let identifier: String
    let length: Int
}

internal func parseSymbols(from name: String) -> [Symbol] {
    let regexp = try! NSRegularExpression(pattern: "((\\d+)([a-zA-Z]+))", options: [])
    let results = regexp.matches(in: name, options: [], range: NSRange(location: 0, length: name.utf16.count))
    return results.map { result -> Symbol in
        let lengthRange = name.swiftRange(from: result.range(at: 2))
        let length = Int(name[lengthRange])!
        let identifierRangeStart = name.index(after: lengthRange.upperBound)
        let identifierRangeEnd = name.index(identifierRangeStart, offsetBy: length)

        let identifier = name[identifierRangeStart..<identifierRangeEnd]
        return Symbol(identifier: String(identifier), length: identifier.count)
    }
}
