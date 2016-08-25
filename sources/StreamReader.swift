//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

class StreamReader {

    let encoding: UInt
    let chunkSize: Int

    var fileHandle: NSFileHandle!
    let buffer: NSMutableData!
    let delimData: NSData!
    var atEof: Bool = false

    init?(path: String, delimiter: String = "\n", encoding: UInt = NSUTF8StringEncoding, chunkSize: Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding

        if let fileHandle = NSFileHandle(forReadingAtPath: path),
        delimData = delimiter.dataUsingEncoding(encoding),
        buffer = NSMutableData(capacity: chunkSize) {
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

        var range = buffer.rangeOfData(delimData, options: [], range: NSRange(location: 0, length: buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEof = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding)

                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: [], range: NSRange(location: 0, length: buffer.length))
        }

        // Convert complete line (excluding the delimiter) to a string:
        let line = NSString(data: buffer.subdataWithRange(NSRange(location: 0, length: range.location)),
                encoding: encoding)
        // Remove line (and the delimiter) from the buffer:
        buffer.replaceBytesInRange( NSRange(location: 0, length: range.location + range.length),
                                    withBytes: nil, length: 0)

        return line as String?
    }

    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seekToFileOffset(0)
        buffer.length = 0
        atEof = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
