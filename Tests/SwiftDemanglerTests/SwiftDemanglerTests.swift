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
}
