//
//  MasterPlaylist.swift
//  Pantomime
//
//  Created by Thomas Christensen on 25/08/16.
//  Copyright © 2016 Sebastian Kreutzberger. All rights reserved.
//

import Foundation

public class MasterPlaylist {
    var path:String?
    var playlists = [MediaPlaylist]()
    
    public func addPlaylist(playlist: MediaPlaylist) {
        playlists.append(playlist)
    }

}
