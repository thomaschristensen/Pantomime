//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

class StreamReader {

    let encoding: String.Encoding
    let chunkSize: Int

    var fileHandle: FileHandle!
    let buffer: NSMutableData!
    let delimData: Data!
    var atEof: Bool = false

    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = String.Encoding.utf8,
          chunkSize: Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding

        if let fileHandle = FileHandle(forReadingAtPath: path),
        let delimData = delimiter.data(using: encoding),
        let buffer = NSMutableData(capacity: chunkSize) {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = buffer
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }

    deinit {
        self.close()
    }

    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")

        if atEof {
            return nil
        }

        // Read data chunks from file until a line delimiter is found:

        var range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.isEmpty {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer as Data, encoding: encoding.rawValue)

                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        }

        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdata(with: NSRange(location: 0, length: range.location)),
                encoding: encoding.rawValue)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytes( in: NSRange(location: 0, length: range.location + range.length),
                                    withBytes: nil, length: 0)

        return line as String?
    }

    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.length = 0
        atEof = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
