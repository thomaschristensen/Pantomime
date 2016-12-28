//
// Created by Thomas Christensen on 25/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

/**
* Parses HTTP Live Streaming manifest files
* Use a BufferedReader to let the parser read from various sources.
*/
open class ManifestBuilder {

    public init() {}

    /**
    * Parses Master playlist manifests
    */
    fileprivate func parseMasterPlaylist(_ reader: BufferedReader, onMediaPlaylist:
            ((_ playlist: MediaPlaylist) -> Void)?) -> MasterPlaylist {
        var masterPlaylist = MasterPlaylist()
        var currentMediaPlaylist: MediaPlaylist?

        defer {
            reader.close()
        }
        while let line = reader.readLine() {
            if line.isEmpty {
                // Skip empty lines

            } else if line.hasPrefix("#EXT") {

                // Tags
                if line.hasPrefix("#EXTM3U") {
                    // Ok Do nothing

                } else if line.hasPrefix("#EXT-X-STREAM-INF") {
                    // #EXT-X-STREAM-INF:PROGRAM-ID=1, BANDWIDTH=200000
                    currentMediaPlaylist = MediaPlaylist()
                    do {
                        let programIdString = try line.replace("(.*)=(\\d+),(.*)", replacement: "$2")
                        let bandwidthString = try line.replace("(.*),(.*)=(\\d+)(.*)", replacement: "$3")
                        if let currentMediaPlaylistExist = currentMediaPlaylist {
                            currentMediaPlaylistExist.programId = Int(programIdString)!
                            currentMediaPlaylistExist.bandwidth = Int(bandwidthString)!
                        }
                    } catch {
                        print("Failed to parse program-id and bandwidth on master playlist. Line = \(line)")
                    }

                }
            } else if line.hasPrefix("#") {
                // Comments are ignored

            } else {
                // URI - must be
                if let currentMediaPlaylistExist = currentMediaPlaylist {
                    currentMediaPlaylistExist.path = line
                    currentMediaPlaylistExist.masterPlaylist = masterPlaylist
                    masterPlaylist.addPlaylist(currentMediaPlaylistExist)
                    if let callableOnMediaPlaylist = onMediaPlaylist {
                        callableOnMediaPlaylist(currentMediaPlaylistExist)
                    }
                }
            }
        }

        return masterPlaylist
    }

    /**
    * Parses Media Playlist manifests
    */
    fileprivate func parseMediaPlaylist(_ reader: BufferedReader, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                    onMediaSegment: ((_ segment: MediaSegment) -> Void)?) -> MediaPlaylist {
        var currentSegment: MediaSegment?
        var currentURI: String?
        var currentSequence = 0

        defer {
            reader.close()
        }

        while let line = reader.readLine() {
            if line.isEmpty {
                // Skip empty lines

            } else if line.hasPrefix("#EXT") {

                // Tags
                if line.hasPrefix("#EXTM3U") {

                    // Ok Do nothing
                } else if line.hasPrefix("#EXT-X-VERSION") {
                    do {
                        let version = try line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        mediaPlaylist.version = Int(version)
                    } catch {
                        print("Failed to parse the version of media playlist. Line = \(line)")
                    }

                } else if line.hasPrefix("#EXT-X-TARGETDURATION") {
                    do {
                        let durationString = try line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        mediaPlaylist.targetDuration = Int(durationString)
                    } catch {
                        print("Failed to parse the target duration of media playlist. Line = \(line)")
                    }

                } else if line.hasPrefix("#EXT-X-MEDIA-SEQUENCE") {
                    do {
                        let mediaSequence = try line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        if let mediaSequenceExtracted = Int(mediaSequence) {
                            mediaPlaylist.mediaSequence = mediaSequenceExtracted
                            currentSequence = mediaSequenceExtracted
                        }
                    } catch {
                        print("Failed to parse the media sequence in media playlist. Line = \(line)")
                    }

                } else if line.hasPrefix("#EXTINF") {
                    currentSegment = MediaSegment()
                    do {
                        let segmentDurationString = try line.replace("(.*):(\\d.*),(.*)", replacement: "$2")
                        let segmentTitle = try line.replace("(.*):(\\d.*),(.*)", replacement: "$3")
                        currentSegment!.duration = Float(segmentDurationString)
                        currentSegment!.title = segmentTitle
                    } catch {
                        print("Failed to parse the segment duration and title. Line = \(line)")
                    }
                } else if line.hasPrefix("#EXT-X-BYTERANGE") {
                    if line.contains("@") {
                        do {
                            let subrangeLength = try line.replace("(.*):(\\d.*)@(.*)", replacement: "$2")
                            let subrangeStart = try line.replace("(.*):(\\d.*)@(.*)", replacement: "$3")
                            currentSegment!.subrangeLength = Int(subrangeLength)
                            currentSegment!.subrangeStart = Int(subrangeStart)
                        } catch {
                            print("Failed to parse byte range. Line = \(line)")
                        }
                    } else {
                        do {
                            let subrangeLength = try line.replace("(.*):(\\d.*)", replacement: "$2")
                            currentSegment!.subrangeLength = Int(subrangeLength)
                            currentSegment!.subrangeStart = nil
                        } catch {
                            print("Failed to parse the byte range. Line = \(line)")
                        }
                    }
                } else if line.hasPrefix("#EXT-X-DISCONTINUITY") {
                    currentSegment!.discontinuity = true
                }

            } else if line.hasPrefix("#") {
                // Comments are ignored

            } else {
                // URI - must be
                if let currentSegmentExists = currentSegment {
                    currentSegmentExists.mediaPlaylist = mediaPlaylist
                    currentSegmentExists.path = line
                    currentSegmentExists.sequence = currentSequence
                    currentSequence += 1
                    mediaPlaylist.addSegment(currentSegmentExists)
                    if let callableOnMediaSegment = onMediaSegment {
                        callableOnMediaSegment(currentSegmentExists)
                    }
                }
            }
        }

        return mediaPlaylist
    }

    /**
    * Parses the master playlist manifest from a string document.
    *
    * Convenience method that uses a StringBufferedReader as source for the manifest.
    */
    open func parseMasterPlaylistFromString(_ string: String, onMediaPlaylist:
                ((_ playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(StringBufferedReader(string: string), onMediaPlaylist: onMediaPlaylist)
    }

    /**
    * Parses the master playlist manifest from a file.
    *
    * Convenience method that uses a FileBufferedReader as source for the manifest.
    */
    open func parseMasterPlaylistFromFile(_ path: String, onMediaPlaylist:
                ((_ playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(FileBufferedReader(path: path), onMediaPlaylist: onMediaPlaylist)
    }

    /**
    * Parses the master playlist manifest requested synchronous from a URL
    *
    * Convenience method that uses a URLBufferedReader as source for the manifest.
    */
    open func parseMasterPlaylistFromURL(_ url: URL, onMediaPlaylist:
                ((_ playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(URLBufferedReader(uri: url), onMediaPlaylist: onMediaPlaylist)
    }

    /**
    * Parses the media playlist manifest from a string document.
    *
    * Convenience method that uses a StringBufferedReader as source for the manifest.
    */
    open func parseMediaPlaylistFromString(_ string: String, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                             onMediaSegment:((_ segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(StringBufferedReader(string: string),
                mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
    * Parses the media playlist manifest from a file document.
    *
    * Convenience method that uses a FileBufferedReader as source for the manifest.
    */
    open func parseMediaPlaylistFromFile(_ path: String, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                           onMediaSegment: ((_ segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(FileBufferedReader(path: path),
                mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
    * Parses the media playlist manifest requested synchronous from a URL
    *
    * Convenience method that uses a URLBufferedReader as source for the manifest.
    */
    open func parseMediaPlaylistFromURL(_ url: URL, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                          onMediaSegment: ((_ segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(URLBufferedReader(uri: url),
                mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
    * Parses the master manifest found at the URL and all the referenced media playlist manifests recursively.
    */
    open func parse(_ url: URL, onMediaPlaylist:
                    ((_ playlist: MediaPlaylist) -> Void)? = nil, onMediaSegment:
                    ((_ segment: MediaSegment) -> Void)? = nil) -> MasterPlaylist {
        // Parse master
        let master = parseMasterPlaylistFromURL(url, onMediaPlaylist: onMediaPlaylist)
        for playlist in master.playlists {
            if let path = playlist.path {

                // Detect if manifests are referred to with protocol
                if path.hasPrefix("http") || path.hasPrefix("file") {
                    // Full path used
                    if let mediaURL = URL(string: path) {
                        _ = parseMediaPlaylistFromURL(mediaURL,
                                mediaPlaylist: playlist, onMediaSegment: onMediaSegment)
                    }
                } else {
                    // Relative path used
                    if let mediaURL = url.URLByReplacingLastPathComponent(path) {
                        _ = parseMediaPlaylistFromURL(mediaURL,
                                mediaPlaylist: playlist, onMediaSegment: onMediaSegment)
                    }
                }
            }
        }
        return master
    }
}
