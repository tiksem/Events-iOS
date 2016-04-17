//
// Created by Semyon Tikhonenko on 1/10/16.
// Copyright (c) 2016 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

public extension String {

    /// Percent escape value to be added to a URL query value as specified in RFC 3986
    ///
    /// This percent-escapes all characters besize the alphanumeric character set and "-", ".", "_", and "~".
    ///
    /// http://www.ietf.org/rfc/rfc3986.txt
    ///
    /// :returns: Return precent escaped string.

    func stringByAddingPercentEncodingForURLQueryValue() -> String? {
        let characterSet = NSMutableCharacterSet.alphanumericCharacterSet()
        characterSet.addCharactersInString("-._~")

        return self.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
    }

    subscript (var r: Range<Int>) -> String {
        get {
            let count = self.characters.count
            if count <= r.startIndex {
                return ""
            }

            let startIndex = self.startIndex.advancedBy(r.startIndex)
            if r.endIndex > count {
                r.endIndex = count
            }

            let endIndex = self.startIndex.advancedBy(r.endIndex - r.startIndex)

            return self[Range(start: startIndex, end: endIndex)]
        }
    }
    
    func searchUrl() -> String? {
        let pattern = "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?"
        let regex = try! NSRegularExpression(pattern:pattern, options:[])
        if let result = regex.firstMatchInString(self, options: [], range: NSMakeRange(0, utf16.count)) {
            return (self as NSString).substringWithRange(result.range) as String
        }
        
        return nil
    }
}

public class StringWrapper : CustomStringConvertible {
    public var value:String

    public init(_ value:String) {
        self.value = value
    }

    public init?(_ value:String?) {
        if let value = value {
            self.value = value
        } else {
            self.value = ""
            return nil
        }
    }

    public var description: String {
        return value
    }
}