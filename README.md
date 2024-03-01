# BandUp-IOS
## Installation
- Open project with Xcode
- Add a Secrets.swift file with the following enum:
```swift
import Foundation

enum Secrets {
    static let baseApiURL = "example url"
    static let s3BucketURL = "example aws bucket url"
}
```
- Pick a device/simulator on which to run the app
- Run the app
