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

    public internal(set) var path: String?

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
