//
// Created by Thomas Christensen on 25/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class ManifestBuilder {
    private func parseMasterPlaylist(reader: BufferedReader, onMediaPlaylist:
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
                    masterPlaylist.addPlaylist(currentMediaPlaylistExist)
                    if let callableOnMediaPlaylist = onMediaPlaylist {
                        callableOnMediaPlaylist(playlist: currentMediaPlaylistExist)
                    }
                }
            }
        }

        return masterPlaylist
    }

    public func parseMasterPlaylistFromString(string: String, onMediaPlaylist:
                ((playlist: MediaPlaylist) -> Void)? = nil) -> MasterPlaylist {
        return parseMasterPlaylist(StringBufferedReader(string: string), onMediaPlaylist: onMediaPlaylist)
    }

    public func parseMasterPlaylist(path: String, onMediaPlaylist:
            ((playlist: MediaPlaylist) -> Void)?) -> MasterPlaylist {

        if let aStreamReader = ReaderBuilder.createFileReader(path) {
            return parseMasterPlaylist(aStreamReader, onMediaPlaylist: onMediaPlaylist)
        }
        return MasterPlaylist() // TODO: Throw exception
    }

    public func parseMediaPlaylistFromString(string: String, onMediaSegment:
                ((segment: MediaSegment) -> Void)? = nil) -> MediaPlaylist {
        return parseMediaPlaylist(StringBufferedReader(string: string), onMediaSegment: onMediaSegment)
    }

    public func parseMediaPlaylist(path: String, onMediaSegment: ((segment: MediaSegment) -> Void)?) -> MediaPlaylist {
        if let aStreamReader = ReaderBuilder.createFileReader(path) {
            return parseMediaPlaylist(aStreamReader, onMediaSegment: onMediaSegment)
        }
        return MediaPlaylist() // TODO: Throw exception
    }

    private func parseMediaPlaylist(reader: BufferedReader, onMediaSegment: ((segment: MediaSegment) -> Void)?) -> MediaPlaylist {
        var mediaPlaylist = MediaPlaylist()
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
