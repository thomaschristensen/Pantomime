//
// Created by Thomas Christensen on 26/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
@testable import Pantomime

class ReaderTests: XCTestCase {
    func testReaderBuilder() {
        do {
            let stringReader = try ReaderBuilder.createReader(.stringreader, reference: "This is a line\nThis is another")
            XCTAssert(stringReader is StringBufferedReader)
            XCTAssertEqual("This is a line", stringReader.readLine())
            XCTAssertEqual("This is another", stringReader.readLine())
            XCTAssertNil(stringReader.readLine())
            XCTAssertNil(stringReader.readLine())

            let bundle = Bundle(for: type(of: self))
            let path = bundle.path(forResource: "media", ofType: "m3u8")!
            let fileReader = try ReaderBuilder.createReader(.filereader, reference: path)
            XCTAssert(fileReader is FileBufferedReader)
            XCTAssertEqual("#EXTM3U", fileReader.readLine())
            XCTAssertEqual("#This is a comment", fileReader.readLine())
            for _ in 1...10 {
                _ = fileReader.readLine()
            }
            XCTAssertNil(fileReader.readLine())

            let httpReader = try ReaderBuilder.createReader(.httpreader, reference: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8")
            XCTAssert(httpReader is URLBufferedReader)
            XCTAssertEqual("#EXTM3U", httpReader.readLine())
            XCTAssertEqual("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000", httpReader.readLine())
            XCTAssertEqual("gear1/prog_index.m3u8", httpReader.readLine())
            XCTAssertEqual("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=311111", httpReader.readLine())
            XCTAssertEqual("gear2/prog_index.m3u8", httpReader.readLine())
            XCTAssertEqual("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=484444", httpReader.readLine())
            XCTAssertEqual("gear3/prog_index.m3u8", httpReader.readLine())
            XCTAssertEqual("#EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=737777", httpReader.readLine())
            XCTAssertEqual("gear4/prog_index.m3u8", httpReader.readLine())
        } catch {
            XCTFail("Not able to construct valid buffered reader instances")
        }
    }
    
    func testBuilder_WithoutProgramID_ShouldNotFail() {
        let builder = ManifestBuilder()
        _ = builder.parseMasterPlaylistFromString("#EXTM3U\n#EXT-X-VERSION:2\n#EXT-X-STREAM-INF:BANDWIDTH=300000\ntrack_0_300/playlist.m3u8?t=1482930352&h=VBNpRGL+iqMhSUWVV3IQ4w==\n")
    }
}
