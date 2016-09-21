//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class MediaSegment {

    weak var mediaPlaylist: MediaPlaylist?

    public internal(set) var duration: Float?
    public internal(set) var sequence: Int = 0
    public internal(set) var subrangeLength: Int?
    public internal(set) var subrangeStart: Int?
    public internal(set) var title: String?
    public internal(set) var discontinuity: Bool = false
    public internal(set) var path: String?

    public func getMediaPlaylist() -> MediaPlaylist? {
        return mediaPlaylist
    }
}
