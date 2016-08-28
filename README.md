# Pantomime 

Pantomime is a lightweight framework for iOS, OSX and tvOS that can read and parse HTTP Live Streaming manifests.

## Latest build

[![Build Status](https://travis-ci.org/thomaschristensen/Pantomime.svg?branch=master)](https://travis-ci.org/thomaschristensen/Pantomime)

## Installation

You can use [Carthage](https://github.com/Carthage/Carthage) to install Pantomime by adding that to your Cartfile:

``` 
github "thomaschristensen/Pantomime"
```

#### via CocoaPods

To use [CocoaPods](https://cocoapods.org) just add this to your Podfile:

``` Ruby
pod 'Pantomime'
```

#### via Swift Package Manager

To use Pantomime as a [Swift Package Manager](https://swift.org/package-manager/) package just add the following in your Package.swift file.

``` Swift
import PackageDescription

let package = Package(
    name: "HelloWorld",
        dependencies: [
            .Package(url: "https://github.com/thomaschristensen/Pantomime", majorVersion: 0)
        ]
    )
```

<br/>

## Usage

To use the parser just do the following:

``` Swift
import Pantomime

let builder = ManifestBuilder()
if let url = NSURL(string: "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8") {
    let manifest = builder.parse(url)
}
```

The ManifestBuilder's parse method expects a master playlist manifest
 to be found at the other end of the URL. Once this has been parsed
 all Media Playlist Manifests referred to in the master will also
 be fetched and parsed. 
 
## Core Classes

#### ManifestBuilder
The manifest builder can parse both Master and Media playlist manifests.
You can choose to let ManifestBuilder parse master and it's media
playlists, or you can parse either the master or media playlists only.
  
#### MasterPlaylist
Represents a master playlist and it holds a reference to a list of 
media playlist objects

#### MediaPlaylist
The media playlist object contains a list of all video segments and
other properties like target duration (max duration of each segment),
path, version, bandwidth, program-id and the starting media sequence 
number.

#### MediaSegment
This object holds a reference to the actual video file (path), it's
actual duration, sequence number and optional title.

## Helper Classes

#### BufferedReader
This is a protocol that defines how these text manifest documents can
be read line by line. Various implementations of this protocol exist
helping reading the documents from a File, a URL or from a String.
These implementations are FileBufferedReader, URLBufferedReader and 
StringBufferedReader. 

#### ReaderBuilder
Is a utility class that can be used to construct the actual 
implementation of BufferedReader by specifying which type is required.
(This class is already deprecated. Use the implementations of 
BufferedReader directly)

#### NSURLExtension
An extension to the NSURL class has been made to assist in constructing
the right URL when given relative paths in the various manifest files.

``` Swift

let masterManifest = "http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"
let mediaManifest = "gear1/prog_index.m3u8"

if let masterManifestURL = NSURL(string: masterManifest) {
    let mediaManifestURL = masterManifestURL.URLByReplacingLastPathComponent(mediaManifest)
    // mediaManifestURL now = http://devimages.apple.com/iphone/samples/bipbop/gear1/prog_index.m3u8
}

```


## License

The Pantomime Framework is released under the [MIT License](https://github.com/thomaschristensen/Pantomime/blob/master/LICENSE).  

## Todo

* Construct Master and Media Playlist objects and write them as files