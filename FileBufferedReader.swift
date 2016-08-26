//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

class FileBufferedReader: BufferedReader {
    var _fileName: String
    var streamReader: StreamReader

    init(path: String) {
        _fileName = path
        streamReader = StreamReader(path: _fileName)!
    }

    func close() {
        streamReader.close()
    }

    func readLine() -> String? {
        return streamReader.nextLine()
    }
}
