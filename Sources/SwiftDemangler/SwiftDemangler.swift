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
    func parseTypes(from signiture: String) -> [Type] {
        let allSubstitutionPattern = "S[ibSf]_S[ibSf]*t|S[ibSf]"
        let regexp = try! NSRegularExpression(pattern: allSubstitutionPattern, options: [])
        let results = regexp.matches(in: signiture, options: [], range: NSRange(location: 0, length: signiture.utf16.count))
        return results.compactMap { result -> Type? in
            let substitution = signiture[signiture.swiftRange(from: result.range)]
            return parse(String(substitution))
        }
    }
    
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
    
    private let listRegexp = try! NSRegularExpression(pattern: "S[ibSf]_(S[ibSf])*t", options: [])
    func parseList(from substitution: String) -> Type? {
        let results = listRegexp.matches(in: substitution, options: [], range: NSRange(location: 0, length: substitution.utf16.count))
        guard let result = results.first else {
            return nil
        }
        
        let listSubstitution = String(substitution[substitution.swiftRange(from: result.range)])
        let listResults = typeRegexp.matches(in: listSubstitution, options: [], range: NSRange(location: 0, length: listSubstitution.utf16.count))
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

struct FunctionSignatureParser {
    func parse(_ functionSignature: String) -> FunctionSignature? {
        let typeParser = TypeParser()
        let result = typeParser.parseTypes(from: functionSignature)
        
        guard let returnType = result.first else {
            return nil
        }
        
        let argsTypes = Array(result.dropFirst())
        return FunctionSignature(returnType: returnType, argsType: .list(argsTypes))
    }
}

public struct NameBuilder {
    func build(_ string: String) -> String? {
        let symbols = parseSymbols(from: string)
        
        let module = symbols[0]
        let declName = symbols[1]
        let labels = symbols[2...]
        guard let functionSigniture = FunctionSignatureParser().parse(string) else {
            return nil
        }
        
        guard case .list(let argTypes) = functionSigniture.argsType else {
            return nil
        }
        
        let argments = zip(labels, argTypes).map { label, argType in
            return "\(label.identifier): \(buildTypeName(argType))"
        }.joined(separator: ", ")
        
        return "\(module.identifier).\(declName.identifier)(\(argments)) -> \(buildTypeName(functionSigniture.returnType))"
    }
    
    private func buildTypeName(_ type: Type) -> String {
        switch type {
        case .bool:
            return "Swift.Bool"
        case .float:
            return "Swift.Float"
        case .int:
            return "Swift.Int"
        case .string:
            return "Swift.String"
        case .list(let list):
            let types = list.map { buildTypeName($0) }
            return "(\(types.joined(separator: ", ")))"
        }
    }
}
