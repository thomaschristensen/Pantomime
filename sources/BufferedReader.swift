//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public protocol BufferedReader {
    func close()

    // Return next line or nil if no more lines can be read
    func readLine() -> String?
}
