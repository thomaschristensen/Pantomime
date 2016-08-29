//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class MediaSegment {
    var mediaPlaylist: MediaPlaylist?
    public var duration: Float?
    public var sequence: Int = 0
    public var subrangeLength: Int?
    public var subrangeStart: Int?
    public var title: String?
    public var discontinuity: Bool = false
    public var path: String?

    public init() {

    }

    public func getMediaPlaylist() -> MediaPlaylist? {
        return self.mediaPlaylist
    }
}
