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

enum Type: Equatable {
    case bool
    case int
    case string
    case float
    indirect case list([Type])
}

struct TypeParser {
    func parse(_ substitution: String) -> Type? {
        if !substitution.hasPrefix("S") {
            return nil
        }
        
        switch substitution {
        case "Si":
            return .int
        case "Sb":
            return .bool
        case "SS":
            return .string
        case "Sf":
            return .float
        default:
            let typeRegexp = try! NSRegularExpression(pattern: "S[ibSf]", options: [])
            let results = typeRegexp.matches(in: substitution, options: [], range: NSRange(location: 0, length: substitution.utf16.count))
            let types = results.compactMap { result -> Type? in
                let range = substitution.swiftRange(from: result.range)
                return parse(String(substitution[range]))
            }
            return .list(types)
        }
    }
}
