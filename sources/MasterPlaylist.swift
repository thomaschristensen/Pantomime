//
//  MasterPlaylist.swift
//  Pantomime
//
//  Created by Thomas Christensen on 25/08/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public class MasterPlaylist {
    var playlists = [MediaPlaylist]()
    public var path: String?

    public init() {}

    public func addPlaylist(playlist: MediaPlaylist) {
        playlists.append(playlist)
    }

    public func getPlaylist(index: Int) -> MediaPlaylist? {
        if index >= playlists.count {
            return nil
        }
        return playlists[index]
    }

    public func getPlaylistCount() -> Int {
        return playlists.count
    }
}
