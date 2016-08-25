//
//  PantomimeTests.swift
//  PantomimeTests
//
//  Created by Thomas Christensen on 24/08/16.
//  Copyright © 2016 Nordija A/S. All rights reserved.
//

import XCTest
@testable import Pantomime

class PantomimeTests: XCTestCase {
    
    func testReadMediaPlaylist() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("media", ofType: "m3u8")!

        let manifestBuilder = ManifestBuilder()
        let mediaPlaylist = manifestBuilder.parseMediaPlaylist(path, onMediaSegment:{
            (segment: MediaSegment) -> Void in
            print("Segment found \(segment.sequence)")
        })

        XCTAssert(mediaPlaylist.targetDuration == 10)
        XCTAssert(mediaPlaylist.mediaSequence == 0)
        XCTAssert(mediaPlaylist.segments.count == 3)
        XCTAssert(mediaPlaylist.segments[0].title == " no desc")
        XCTAssert(mediaPlaylist.segments[0].subrangeLength == 100)
        XCTAssert(mediaPlaylist.segments[0].subrangeStart == 40)
        XCTAssert(mediaPlaylist.segments[1].subrangeLength == 100)
        XCTAssert(mediaPlaylist.segments[1].subrangeStart == nil)
        XCTAssert(mediaPlaylist.segments[2].duration == Float(3.003))
        XCTAssert(mediaPlaylist.segments[2].uri! == NSURL(string:"http://media.example.com/third.ts"))
        XCTAssert(mediaPlaylist.duration() == Float(21.021))

        if let path2 = bundle.pathForResource("media2", ofType: "m3u8") {
            let mediaPlaylist2 = manifestBuilder.parseMediaPlaylist(path2, onMediaSegment: {(segment:MediaSegment)->Void in
                print("Segment found \(segment.sequence)")
            })
            XCTAssertEqual(12, mediaPlaylist2.targetDuration, "Should have been read as 12 seconds")
        }
    }
    
}
