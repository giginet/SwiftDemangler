import XCTest
@testable import SwiftDemangler

final class SwiftDemanglerTests: XCTestCase {
    let example = "$S13ExampleNumber6isEven6numberSbSi_tF"
    
    func testParseIdentifiers() {
        let identifiers = parseSymbols(from: example)
        XCTAssertEqual(identifiers.count, 3)
        
        XCTAssertEqual(identifiers[0].identifier, "ExampleNumber")
        XCTAssertEqual(identifiers[0].length, 13)
        XCTAssertEqual(identifiers[1].identifier, "isEven")
        XCTAssertEqual(identifiers[1].length, 6)
        XCTAssertEqual(identifiers[2].identifier, "number")
        XCTAssertEqual(identifiers[2].length, 6)
    }
    
    func testTypeParser() {
        let parser = TypeParser()
        
        XCTAssertEqual(parser.parse("Si")!, .int)
        XCTAssertEqual(parser.parse("Sb")!, .bool)
        XCTAssertEqual(parser.parse("SS")!, .string)
        XCTAssertEqual(parser.parse("Sf")!, .float)
        XCTAssertEqual(parser.parse("Sf_SfSft")!, .list([.float, .float, .float]))
    }
    
    func testListTypeParser() {
        let parser = TypeParser()
        
        XCTAssertEqual(parser.parseList(from: "Sb_SbSbt"), .list([.bool, .bool, .bool]))
        XCTAssertEqual(parser.parseList(from: "Si_t"), .list([.int]))
    }
    
    func testParseFunctionSignature() {
        let parser = FunctionSignatureParser()
        
        XCTAssertEqual(parser.parse("SbSi_t"), FunctionSignature(returnType: .bool, argsType: .list([.int])))

        XCTAssertEqual(parser.parse("Sb_SbtSi_t"), FunctionSignature(returnType: .list([.bool, .bool]), argsType: .list([.int])))
    }
}
