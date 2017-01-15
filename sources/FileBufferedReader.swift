//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

open class FileBufferedReader: BufferedReader {
    var _fileName: String
    var streamReader: StreamReader

    public init(path: String) {
        _fileName = path
        streamReader = StreamReader(path: _fileName)!
    }

    open func close() {
        streamReader.close()
    }

    open func readLine() -> String? {
        return streamReader.nextLine()
    }
}
