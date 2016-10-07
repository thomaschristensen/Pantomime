//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

/**
* Reads the document found at the specified URL in one chunk synchonous
* and then lets the readLine function pick it line by line.
*/
open class URLBufferedReader: BufferedReader {
    var _uri: URL
    var _stringReader: StringBufferedReader

    public init(uri: URL) {
        _uri = uri
        _stringReader = StringBufferedReader(string: "")
        let request1: URLRequest = URLRequest(url: _uri)
        let response: AutoreleasingUnsafeMutablePointer<URLResponse?>? = nil
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returning: response)
            let text = String(data: dataVal, encoding: String.Encoding.utf8)!
            _stringReader = StringBufferedReader(string: text)
        } catch {
            print("Failed to make request for content at \(_uri)")
        }
    }

    open func close() {
        _stringReader.close()
    }

    open func readLine() -> String? {
        return _stringReader.readLine()
    }

}
