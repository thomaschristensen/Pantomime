//
// Created by Thomas Christensen on 29/08/16.
// Copyright (c) 2016 Sebastian Kreutzberger. All rights reserved.
//

import XCTest
import Pantomime

class PlaylistTests: XCTestCase {

    func testMasterPlaylist() {
        let master = MasterPlaylist()
        XCTAssertNil(master.getPlaylist(0))
        XCTAssertNil(master.getPlaylist(5))
        let media = MediaPlaylist()
        master.addPlaylist(media)
        XCTAssertEqual(1, master.getPlaylistCount())
        XCTAssertNotNil(master.getPlaylist(0))
        XCTAssert(media === master.getPlaylist(0))
        master.path = "hello"
        XCTAssertEqual("hello", master.path)
    }

    func testMediaPlaylist() {
        let media = MediaPlaylist()
        let segment = MediaSegment()
        XCTAssertNil(media.getSegment(0))
        XCTAssertNil(media.getSegment(2))
        media.addSegment(segment)
        XCTAssertEqual(1, media.getSegmentCount())
        XCTAssertNotNil(media.getSegment(0))
        XCTAssert(segment === media.getSegment(0))
    }
}
