//
// Created by Thomas Christensen on 24/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class MediaSegment {
    var mediaPlaylist: MediaPlaylist?
    var duration: Float?
    var sequence: Int = 0
    var subrangeLength: Int?
    var subrangeStart: Int?
    var title: String?
    var discontinuity: Bool = false
    var path: String?
}
