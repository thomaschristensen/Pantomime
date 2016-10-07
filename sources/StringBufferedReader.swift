//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

/**
* Uses a string as a stream and reads it line by line.
*/

open class StringBufferedReader: BufferedReader {
    var _buffer: [String]
    var _line: Int

    public init(string: String) {
        _line = 0
        _buffer = string.components(separatedBy: CharacterSet.newlines)
    }

    open func close() {
    }

    open func readLine() -> String? {
        if _buffer.isEmpty || _buffer.count <= _line {
            return nil
        }
        let result = _buffer[_line]
        _line = _line + 1
        return result
    }
}
