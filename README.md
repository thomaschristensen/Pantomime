# Pantomime 

Pantomime is a lightweight framework for iOS, OSX and tvOS that can read, parse and write HTTP Live Streaming manifests.

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

let manifestBuilder = ManifestBuilder()
let mediaPlaylist = manifestBuilder.parseMediaPlaylist("mediaplaylist.m3u8", onMediaSegment:{
    (segment: MediaSegment) -> Void in
        print("Segment found \(segment.sequence)")
    })
```

You can use pick Manifest information from the MediaPlaylist object after parsing
and pick up the segments as they are discovered using the OnMediaSegment closure.

## License

The Pantomime Framework is released under the [MIT License](https://github.com/thomaschristensen/Pantomime/blob/master/LICENSE).  
