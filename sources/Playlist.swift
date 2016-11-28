//
//  Playlist.swift
//  Pantomime
//
//  Created by Joe Carroll on 9/21/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public protocol Playlist {

    var m3u8String: String { get }
    var m3u8Data: Data? { get }
}
