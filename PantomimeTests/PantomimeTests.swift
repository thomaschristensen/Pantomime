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

    func testParseMediaPlaylist() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("media", ofType: "m3u8")!

        let manifestBuilder = ManifestBuilder()
        let mediaPlaylist = manifestBuilder.parseMediaPlaylist(path, onMediaSegment: {
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
        XCTAssert(mediaPlaylist.segments[2].path! == "http://media.example.com/third.ts")
        XCTAssert(mediaPlaylist.duration() == Float(21.021))

        if let path2 = bundle.pathForResource("media2", ofType: "m3u8") {
            let mediaPlaylist2 = manifestBuilder.parseMediaPlaylist(path2, onMediaSegment: {
                (segment: MediaSegment) -> Void in
                print("Segment found \(segment.sequence)")
            })
            XCTAssertEqual(12, mediaPlaylist2.targetDuration, "Should have been read as 12 seconds")
        }
    }

    func testParseMasterPlaylist() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let path = bundle.pathForResource("master", ofType: "m3u8")!

        let manifestBuilder = ManifestBuilder()

        let masterPlaylist = manifestBuilder.parseMasterPlaylist(path,
                onMediaPlaylist: {
                    (playlist: MediaPlaylist) -> Void in
                    print("Playlist found with program id = \(playlist.programId) and bandwidth = \(playlist.bandwidth) using path \(playlist.path)")
                })

        XCTAssert(masterPlaylist.playlists.count == 4)
    }

    /**
    * This would be the typical set up. Users will use Alomofire or similar libraries to
    * fetch the manifest files and then parse the text.
    */
    func testParseFromString() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let file = bundle.pathForResource("master", ofType: "m3u8")!
        let path = NSURL(fileURLWithPath: file)
        do {

            let manifestText = try String(contentsOfURL: path, encoding: NSUTF8StringEncoding)
            let manifestBuilder = ManifestBuilder()
            let masterPlaylist = manifestBuilder.parseMasterPlaylistFromString(manifestText)
            XCTAssert(masterPlaylist.playlists.count == 4)

        } catch {
            XCTFail("Failed to read master playlist file")
        }
    }

    func testReadWorldParsing() {
        let manifestBuilder = ManifestBuilder()

        // Keep baseURL separate to contruct the nested media playlist URL's
        let baseURL = "http://devimages.apple.com/iphone/samples/bipbop"
        let path = "bipbopall.m3u8"
        let URL = NSURL(string: baseURL + "/" + path)!
        XCTAssertEqual("http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8", URL.absoluteString)

        let expectation = expectationWithDescription("Testing parsing of the apple bipbop HTTP Live Stream sample")

        let session = NSURLSession.sharedSession()

        // Request master playlist
        let task = session.dataTaskWithURL(URL) {
            data, response, error in

            XCTAssertNotNil(data, "data should not be nil")
            XCTAssertNil(error, "error should be nil")

            if let httpResponse = response as? NSHTTPURLResponse,
            responseURL = httpResponse.URL,
            mimeType = httpResponse.MIMEType {

                XCTAssertEqual(responseURL.absoluteString, URL.absoluteString, "No redirect expected")
                XCTAssertEqual(httpResponse.statusCode, 200, "HTTP response status code should be 200")
                XCTAssertEqual(mimeType, "audio/x-mpegurl", "HTTP response content type should be text/html")

                // Parse master playlist and perform verification of it
                if let dataFound = data, manifestText = String(data: dataFound, encoding: NSUTF8StringEncoding) {

                    let masterPlaylist = manifestBuilder.parseMasterPlaylistFromString(manifestText,
                            onMediaPlaylist: {
                                (mep: MediaPlaylist) -> Void in

                                // Deduct full media playlist URL from path
                                if let path = mep.path, mepURL = NSURL(string: baseURL + "/" + path) {

                                    // Request each found media playlist
                                    let mepTask = session.dataTaskWithURL(mepURL) {
                                        mepData, mepResponse, mepError in

                                        XCTAssertNotNil(mepData, "data should not be nil")
                                        XCTAssertNil(mepError, "error should be nil")

                                        // Parse the media playlist and perform validation
                                        if let mepDataFound = mepData,
                                        mepManifest = String(data: mepDataFound, encoding: NSUTF8StringEncoding) {
                                            let mediaPlaylist = manifestBuilder.parseMediaPlaylistFromString(mepManifest)
                                            XCTAssertEqual(181,mediaPlaylist.segments.count)
                                        }

                                        // In case we have requested, parsed and validated the last one
                                        if path.containsString("gear4/prog_index.m3u8") {
                                            expectation.fulfill()
                                        }
                                    }

                                    mepTask.resume()
                                }
                            })

                    XCTAssertEqual(4, masterPlaylist.playlists.count)
                }
            } else {
                XCTFail("Response was not NSHTTPURLResponse")
            }
        }

        task.resume()

        waitForExpectationsWithTimeout(task.originalRequest!.timeoutInterval) {
            error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
            task.cancel()
        }
    }
}
