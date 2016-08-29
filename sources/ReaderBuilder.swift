//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public class ReaderBuilder {

    enum ReaderBuilderError: ErrorType {
        case IllegalReference(reference:String)
    }

    enum ReaderTypes {
        case STRINGREADER, HTTPREADER, FILEREADER
    }

    static func createURLReader(reference: NSURL) -> BufferedReader {
        return URLBufferedReader(uri: reference)
    }

    static func createStringReader(reference: String) -> BufferedReader {
        return StringBufferedReader(string: reference)
    }

    static func createFileReader(reference: String) -> BufferedReader? {
        return FileBufferedReader(path: reference)
    }

    static func createReader(reader: ReaderTypes, reference: String) throws -> BufferedReader {

        switch reader {
        case .STRINGREADER:
            return StringBufferedReader(string: reference)
        case .FILEREADER:
            return FileBufferedReader(path: reference)
        case .HTTPREADER:
            if let uriOK = NSURL(string: reference) {
                return URLBufferedReader(uri: uriOK)
            } else {
                throw ReaderBuilderError.IllegalReference(reference: reference)
            }
        }
    }
}
