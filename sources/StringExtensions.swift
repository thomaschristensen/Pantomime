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
        let options: NSRegularExpression.MatchingOptions = [.withTransparentBounds]
        let range = NSRange(location: 0, length: self.characters.count)
        let matches = regex.matches(in: self, options: options, range: range)
        guard matches.count > 0 else {
            throw NSError(domain: "Pantomime", code: 123, userInfo: ["description": "Couldn't find matches with RegEx"])
        }
        
        return regex.stringByReplacingMatches(
            in: self,
            options: options,
            range: range,
            withTemplate: replacement
        )
    }
}
