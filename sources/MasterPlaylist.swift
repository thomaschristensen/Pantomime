//
//  MasterPlaylist.swift
//  Pantomime
//
//  Created by Thomas Christensen on 25/08/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

open class MasterPlaylist: Playlist {
    var playlists = [MediaPlaylist]()

    open internal(set) var path: String?

    // Raw data
    open internal(set) var m3u8String: String = ""
    open var m3u8Data: Data? {
        return m3u8String.data(using: String.Encoding.utf8)
    }

    func addPlaylist(_ playlist: MediaPlaylist) {
        playlist.masterPlaylist = self
        playlists.append(playlist)
    }
}

public extension MasterPlaylist {

    subscript(idx: Int) -> MediaPlaylist? {
        get {
            return getPlaylist(idx)
        }
    }

    func getPlaylist(_ index: Int) -> MediaPlaylist? {
        if index >= playlists.count {
            return nil
        }
        return playlists[index]
    }

    func getPlaylistCount() -> Int {
        return playlists.count
    }
}
