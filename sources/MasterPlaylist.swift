//
//  MasterPlaylist.swift
//  Pantomime
//
//  Created by Thomas Christensen on 25/08/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public class MasterPlaylist: Playlist {
    var playlists = [MediaPlaylist]()

    public internal(set) var path: String?

    // Raw data
    public internal(set) var m3u8String: String = ""
    public var m3u8Data: NSData? {
        return m3u8String.dataUsingEncoding(NSUTF8StringEncoding)
    }

    func addPlaylist(playlist: MediaPlaylist) {
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

    func getPlaylist(index: Int) -> MediaPlaylist? {
        if index >= playlists.count {
            return nil
        }
        return playlists[index]
    }

    func getPlaylistCount() -> Int {
        return playlists.count
    }
}
