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

private let typeRegexp = try! NSRegularExpression(pattern: "S[ibSf]", options: [])

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
            return parseList(from: substitution)
        }
    }
    
    private let listRegexp = try! NSRegularExpression(pattern: "S._(S.)+t", options: [])
    func parseList(from substitution: String) -> Type? {
        let results = listRegexp.matches(in: substitution, options: [], range: NSRange(location: 0, length: substitution.utf16.count))
        guard let result = results.first else {
            return nil
        }
        
        let listSubstitution = String(substitution[substitution.swiftRange(from: result.range)])
        let listResults = typeRegexp.matches(in: listSubstitution, options: [], range: NSRange(location: 0, length: substitution.utf16.count))
        let types = listResults.compactMap { listResult -> Type? in
            let range = listSubstitution.swiftRange(from: listResult.range)
            return parse(String(listSubstitution[range]))
        }
        return .list(types)
    }
}

struct FunctionSignature: Equatable {
    let returnType: Type
    let argsType: Type
}

struct FunctionSignitureParser {
    func parse(_ functionSigniture: String) {
    }
}
