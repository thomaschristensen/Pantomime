//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

open class MediaSegment {
    var mediaPlaylist: MediaPlaylist?
    open var duration: Float?
    open var sequence: Int = 0
    open var subrangeLength: Int?
    open var subrangeStart: Int?
    open var title: String?
    open var discontinuity: Bool = false
    open var path: String?

    public init() {

    }

    open func getMediaPlaylist() -> MediaPlaylist? {
        return self.mediaPlaylist
    }
}
