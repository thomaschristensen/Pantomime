//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

open class MediaSegment {

    weak var mediaPlaylist: MediaPlaylist?

    open internal(set) var duration: Float?
    open internal(set) var sequence: Int = 0
    open internal(set) var subrangeLength: Int?
    open internal(set) var subrangeStart: Int?
    open internal(set) var title: String?
    open internal(set) var discontinuity: Bool = false
    open internal(set) var path: String?

    open func getMediaPlaylist() -> MediaPlaylist? {
        return mediaPlaylist
    }
}
