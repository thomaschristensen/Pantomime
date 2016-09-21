//
// Created by Thomas Christensen on 25/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

/**
* Parses HTTP Live Streaming manifest files
* Use a BufferedReader to let the parser read from various sources.
*/
public class ManifestBuilder {

    public init() {}

}

public extension ManifestBuilder {
    /**
     * Parses the master playlist manifest from a string document.
     *
     * Convenience method that uses a StringBufferedReader as source for the manifest.
     */
    func parseMasterPlaylistFromString(string: String, onMediaPlaylist:
        ((playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(StringBufferedReader(string: string), onMediaPlaylist: onMediaPlaylist)
    }

    /**
     * Parses the master playlist manifest from a file.
     *
     * Convenience method that uses a FileBufferedReader as source for the manifest.
     */
    func parseMasterPlaylistFromFile(path: String, onMediaPlaylist:
        ((playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(FileBufferedReader(path: path), onMediaPlaylist: onMediaPlaylist)
    }

    /**
     * Parses the master playlist manifest requested synchronous from a URL
     *
     * Convenience method that uses a URLBufferedReader as source for the manifest.
     */
    func parseMasterPlaylistFromURL(url: NSURL, onMediaPlaylist:
        ((playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(URLBufferedReader(uri: url), onMediaPlaylist: onMediaPlaylist)
    }

    /**
     * Parses the media playlist manifest from a string document.
     *
     * Convenience method that uses a StringBufferedReader as source for the manifest.
     */
    func parseMediaPlaylistFromString(string: String, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                      onMediaSegment:((segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(StringBufferedReader(string: string),
                                  mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
     * Parses the media playlist manifest from a file document.
     *
     * Convenience method that uses a FileBufferedReader as source for the manifest.
     */
    func parseMediaPlaylistFromFile(path: String, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                    onMediaSegment: ((segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(FileBufferedReader(path: path),
                                  mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
     * Parses the media playlist manifest requested synchronous from a URL
     *
     * Convenience method that uses a URLBufferedReader as source for the manifest.
     */
    func parseMediaPlaylistFromURL(url: NSURL, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                   onMediaSegment: ((segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(URLBufferedReader(uri: url),
                                  mediaPlaylist: mediaPlaylist, onMediaSegment: onMediaSegment)
    }

    /**
     * Parses the master manifest found at the URL and all the referenced media playlist manifests recursively.
     */
    func parse(url: NSURL, onMediaPlaylist:
        ((playlist: MediaPlaylist) -> Void)? = nil, onMediaSegment:
        ((segment: MediaSegment) -> Void)? = nil) -> MasterPlaylist {
        // Parse master
        let master = parseMasterPlaylistFromURL(url, onMediaPlaylist: onMediaPlaylist)
        for playlist in master.playlists {
            if let path = playlist.path {
                if let mediaURL = NSURL(string: path) ?? url.URLByReplacingLastPathComponent(path) {
                    parseMediaPlaylistFromURL(mediaURL,
                                              mediaPlaylist: playlist, onMediaSegment: onMediaSegment)
                }

            }
        }
        return master
    }
}

private extension ManifestBuilder {
    /**
     * Parses Master playlist manifests
     */
    func parseMasterPlaylist(reader: BufferedReader, onMediaPlaylist:
        ((playlist: MediaPlaylist) -> Void)?) -> MasterPlaylist {
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
                    // TODO: Can we guarentee the order of these attributes?
                    let mediaPlaylist = MediaPlaylist()
                    if let programIdString = try? line.replace("(.*)=(\\d+),(.*)", replacement: "$2") {
                        mediaPlaylist.programId = Int(programIdString)!
                    }
                    if let bandwidthString = try? line.replace("(.*),(.*)=(\\d+)(.*)", replacement: "$3") {
                        mediaPlaylist.bandwidth = Int(bandwidthString)!
                    }
                    currentMediaPlaylist = mediaPlaylist
                } else if line.hasPrefix("#EXT-X-MEDIA") {
                    let mediaPlaylist = MediaPlaylist()
                    // #EXT-X-MEDIA:TYPE=SUBTITLES,GROUP-ID="subs",NAME="English",DEFAULT=NO,AUTOSELECT=YES,FORCED=NO,LANGUAGE="eng",URI="..."
                    mediaPlaylist.language = try? line.replace("(.*)LANGUAGE=\"(.*?)\"(.*)", replacement: "$2")
                    mediaPlaylist.type = try? line.replace("(.*)TYPE=(.*?),(.*)", replacement: "$2")
                    mediaPlaylist.path = try? line.replace("(.*)URI=\"(.*?)\"(.*)", replacement: "$2")

                    masterPlaylist.addPlaylist(mediaPlaylist)
                    onMediaPlaylist?(playlist: mediaPlaylist)
                }
            } else if line.hasPrefix("#") {
                // Comments are ignored

            } else {
                // URI - must be
                if let playlist = currentMediaPlaylist {
                    // Update playlist
                    playlist.path = line
                    masterPlaylist.addPlaylist(playlist)

                    // Call handler
                    onMediaPlaylist?(playlist: playlist)

                    // Nil out in case there are more to find
                    currentMediaPlaylist = nil
                }
            }
        }

        return masterPlaylist
    }

    /**
     * Parses Media Playlist manifests
     */
    func parseMediaPlaylist(reader: BufferedReader, mediaPlaylist: MediaPlaylist = MediaPlaylist(),
                                    onMediaSegment: ((segment: MediaSegment) -> Void)?) -> MediaPlaylist {
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
                    if line.containsString("@") {
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
                        callableOnMediaSegment(segment: currentSegmentExists)
                    }
                }
            }
        }

        return mediaPlaylist
    }
}
