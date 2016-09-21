//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class MediaPlaylist {

    weak var masterPlaylist: MasterPlaylist?

    public internal(set) var programId: Int = 0
    public internal(set) var bandwidth: Int = 0
    public internal(set) var path: String?
    public internal(set) var version: Int?
    public internal(set) var targetDuration: Int?
    public internal(set) var mediaSequence: Int?

    // Advanced attributes
    public internal(set) var type: String?
    public internal(set) var language: String?

    var segments = [MediaSegment]()

    func addSegment(segment: MediaSegment) {
        segments.append(segment)
    }
}

public extension MediaPlaylist {

    subscript(idx: Int) -> MediaSegment? {
        get {
            return getSegment(idx)
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
