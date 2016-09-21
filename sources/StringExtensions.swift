//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

// Extend the String object with helpers
extension String {

    // String.replace(); similar to JavaScript's String.replace() and Ruby's String.gsub()
    func replace(pattern: String, replacement: String) throws -> String {

        let regex = try NSRegularExpression(pattern: pattern, options: [.CaseInsensitive])

        return regex.stringByReplacingMatchesInString(
            self,
            options: [.WithTransparentBounds],
            range: NSRange(location: 0, length: self.characters.count),
            withTemplate: replacement
        )
    }
}
