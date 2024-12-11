import Foundation

extension String {
    subscript(safe index: Int) -> Character? {
        if index < 0 || index >= count {
            return nil
        }
        let value = self[String.Index(utf16Offset: index, in: self)]
        return value
    }
    
    subscript(safe range: Range<Int>) -> Substring? {
        if range.lowerBound < 0 || range.upperBound >= count {
            return nil
        }
        let lowerBound = String.Index(utf16Offset: range.lowerBound, in: self)
        let upperBound = String.Index(utf16Offset: range.upperBound, in: self)
        return self[lowerBound..<upperBound]
    }
}

