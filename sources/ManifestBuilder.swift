//
// Created by Thomas Christensen on 25/08/16.
// Copyright (c) 2016 Nordija A/S. All rights reserved.
//

import Foundation

public class ManifestBuilder {
    
    public init() {
        
    }

    public func parseMediaPlaylist(path: String, onMediaSegment: ((segment:MediaSegment) -> Void)?) -> MediaPlaylist {

        var mediaPlaylist = MediaPlaylist()
        var currentSegment: MediaSegment?
        var currentURI: String?
        var currentSequence = 0

        if let aStreamReader = StreamReader(path: path) {
            defer {
                aStreamReader.close()
            }
            while let line = aStreamReader.nextLine() {
                if (line.isEmpty) {
                    // Skip empty lines

                } else if (line.hasPrefix("#EXT")) {

                    // Tags
                    if (line.hasPrefix("#EXTM3U")) {

                        // Ok Do nothing
                    } else if (line.hasPrefix("#EXT-X-VERSION")) {
                        let version = line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        mediaPlaylist.version = Int(version)

                    } else if (line.hasPrefix("#EXT-X-TARGETDURATION")) {
                        let durationString = line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        mediaPlaylist.targetDuration = Int(durationString)

                    } else if (line.hasPrefix("#EXT-X-MEDIA-SEQUENCE")) {
                        let mediaSequence = line.replace("(.*):(\\d+)(.*)", replacement: "$2")
                        if let mediaSequenceExtracted = Int(mediaSequence) {
                            mediaPlaylist.mediaSequence = mediaSequenceExtracted
                            currentSequence = mediaSequenceExtracted
                        }

                    } else if (line.hasPrefix("#EXTINF")) {
                        let segmentDurationString = line.replace("(.*):(\\d.*),(.*)", replacement: "$2")
                        let segmentTitle = line.replace("(.*):(\\d.*),(.*)", replacement: "$3")
                        currentSegment = MediaSegment()
                        currentSegment!.duration = Float(segmentDurationString)
                        currentSegment!.title = segmentTitle

                    } else if (line.hasPrefix("#EXT-X-BYTERANGE")) {
                        if (line.containsString("@")) {
                            let subrangeLength = line.replace("(.*):(\\d.*)@(.*)", replacement: "$2")
                            let subrangeStart = line.replace("(.*):(\\d.*)@(.*)", replacement: "$3")
                            currentSegment!.subrangeLength = Int(subrangeLength)
                            currentSegment!.subrangeStart = Int(subrangeStart)
                        } else {
                            let subrangeLength = line.replace("(.*):(\\d.*)", replacement: "$2")
                            currentSegment!.subrangeLength = Int(subrangeLength)
                            currentSegment!.subrangeStart = nil
                        }
                    } else if (line.hasPrefix("#EXT-X-DISCONTINUITY")) {
                        currentSegment!.discontinuity = true
                    }

                } else if (line.hasPrefix("#")) {
                    // Comments are ignored

                } else {
                    // URI - must be
                    if let currentSegmentExists = currentSegment {
                        currentSegmentExists.uri = NSURL(string: line)
                        currentSegmentExists.sequence = currentSequence
                        currentSequence += 1
                        mediaPlaylist.addSegment(currentSegmentExists)
                        if let callableOnMediaSegment = onMediaSegment {
                            callableOnMediaSegment(segment: currentSegmentExists)
                        }
                    }
                }
            }
        }

        return mediaPlaylist;
    }
}
