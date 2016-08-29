//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

/**
* Reads the document found at the specified URL in one chunk synchonous
* and then lets the readLine function pick it line by line.
*/
public class URLBufferedReader: BufferedReader {
    var _uri: NSURL
    var _stringReader: StringBufferedReader

    public init(uri: NSURL) {
        _uri = uri
        _stringReader = StringBufferedReader(string: "")
        let request1: NSURLRequest = NSURLRequest(URL: _uri)
        let response: AutoreleasingUnsafeMutablePointer<NSURLResponse?> = nil
        do {
            let dataVal = try NSURLConnection.sendSynchronousRequest(request1, returningResponse: response)
            let text = String(data: dataVal, encoding: NSUTF8StringEncoding)!
            _stringReader = StringBufferedReader(string: text)
        } catch {
            print("Failed to make request for content at \(_uri)")
        }
    }

    public func close() {
        _stringReader.close()
    }

    public func readLine() -> String? {
        return _stringReader.readLine()
    }

}
