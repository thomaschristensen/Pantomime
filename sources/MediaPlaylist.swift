//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class MediaPlaylist {
    var programId:Int = 0
    var bandwidth:Int = 0
    var path:String?
    var version:Int?
    var targetDuration:Int?
    var mediaSequence:Int?
    var segments = [MediaSegment]()

    public func addSegment(segment: MediaSegment) {
        segments.append(segment)
    }

    public func duration() -> Float {
        var dur:Float = 0.0
        for item in segments {
            dur = dur + item.duration!
        }
        return dur
    }
}
