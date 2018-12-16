import Foundation

public extension String {
    func swiftRange(from range: NSRange) -> ClosedRange<String.Index> {
        let start = index(startIndex, offsetBy: range.location)
        let end = index(startIndex, offsetBy: range.location + range.length - 1)
        return start...end
    }
}
