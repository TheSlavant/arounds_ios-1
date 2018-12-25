//
//  NSAttributes+Extension.swift
//  Arounds
//
//  Created by Samvel Pahlevanyan on 5/3/18.
//  Copyright © 2018 Samvel Pahlevanyan. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    static func atributesWith(strings: [(String, UIFont, UIColor)], attributeText: String) -> NSMutableAttributedString {
        let attrebuted = NSMutableAttributedString.init(string: attributeText)
        
        for attribut in strings {
            let attributesForName: [NSAttributedString.Key: Any] = [ .font : attribut.1, .foregroundColor : attribut.2]
            if let range = attributeText.nsRange(of: attribut.0)
            {
                attrebuted.addAttributes(attributesForName, range: range)
            }
        }
        return attrebuted
    }
    
}

extension StringProtocol where Index == String.Index {
    func nsRange<T: StringProtocol>(of string: T, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
        guard let range = self.range(of: string, options: options, range: range ?? startIndex..<endIndex, locale: locale ?? .current) else { return nil }
        return NSRange(range, in: self)
    }
    func nsRanges<T: StringProtocol>(of string: T, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> [NSRange] {
        var start = range?.lowerBound ?? startIndex
        let end = range?.upperBound ?? endIndex
        var ranges: [NSRange] = []
        while start < end, let range = self.range(of: string, options: options, range: start..<end, locale: locale ?? .current) {
            ranges.append(NSRange(range, in: self))
            start = range.upperBound
        }
        return ranges
    }
}

