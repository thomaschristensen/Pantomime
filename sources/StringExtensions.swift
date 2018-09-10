//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

// Extend the String object with helpers
extension String {

    // String.replace(); similar to JavaScript's String.replace() and Ruby's String.gsub()
    func replace(_ pattern: String, replacement: String) throws -> String {

        let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])

        return regex.stringByReplacingMatches(
            in: self,
            options: [.withTransparentBounds],
            range: NSRange(location: 0, length: self.count),
            withTemplate: replacement
        )
    }
}
