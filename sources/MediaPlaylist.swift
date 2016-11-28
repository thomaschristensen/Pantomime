//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

open class MediaPlaylist: Playlist {

    weak var masterPlaylist: MasterPlaylist?

    open internal(set) var programId: Int = 0
    open internal(set) var bandwidth: Int = 0
    open internal(set) var path: String?
    open internal(set) var version: Int?
    open internal(set) var targetDuration: Int?
    open internal(set) var mediaSequence: Int?

    // Raw data
    open internal(set) var m3u8String: String = ""
    open var m3u8Data: Data? {
        return m3u8String.data(using: String.Encoding.utf8)
    }

    // Advanced attributes
    open internal(set) var type: String?
    open internal(set) var language: String?

    var segments = [MediaSegment]()

    func addSegment(segment: MediaSegment) {
        segments.append(segment)
    }
}

public extension MediaPlaylist {

    subscript(idx: Int) -> MediaSegment? {
        get {
            return getSegment(index: idx)
        }
    }

    func getSegment(index: Int) -> MediaSegment? {
        if index >= segments.count {
            return nil
        }
        return segments[index]
    }

    func getSegmentCount() -> Int {
        return segments.count
    }

    func duration() -> Float {
        var dur: Float = 0.0
        for item in segments {
            dur = dur + item.duration!
        }
        return dur
    }

    func getMaster() -> MasterPlaylist? {
        return masterPlaylist
    }
}
